import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/build.dart';

/// Les builds enregistrées, conservées entre deux lancements.
///
/// Même forme que les favoris : un [ValueNotifier] que les écrans écoutent,
/// pour qu'une build enregistrée apparaisse dans la liste sans rechargement.
class BuildStore {
  static const _key = 'saved_builds';

  static final ValueNotifier<List<Build>> builds = ValueNotifier(
    const <Build>[],
  );

  static Future<void>? _loading;
  static Future<void> _writeQueue = Future.value();

  static Future<void> ensureLoaded() {
    final loading = _loading;
    if (loading != null) return loading;

    final request = _load();
    _loading = request;

    return request;
  }

  static Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      builds.value = (prefs.getStringList(_key) ?? const [])
          .map(_decode)
          .whereType<Build>()
          .toList();
    } catch (_) {
      // Stockage indisponible : on démarre sans builds plutôt que de planter,
      // et le prochain appel pourra retenter.
      _loading = null;
    }
  }

  static Build? _decode(String raw) {
    try {
      return Build.tryFromJson(jsonDecode(raw));
    } on FormatException {
      return null;
    }
  }

  /// Nouvel identifiant, unique tant que deux builds ne sont pas créées dans
  /// la même microseconde.
  static String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  /// Ajoute la build, ou remplace celle qui porte le même identifiant. Les plus
  /// récemment enregistrées passent en tête de liste.
  static Future<void> save(Build build) async {
    await ensureLoaded();

    final others = builds.value.where((saved) => saved.id != build.id);
    final updated = [build, ...others];
    builds.value = updated;

    await _persist(updated);
  }

  static Future<void> delete(String id) async {
    await ensureLoaded();

    final updated = builds.value.where((saved) => saved.id != id).toList();
    builds.value = updated;

    await _persist(updated);
  }

  /// Les écritures s'enchaînent pour ne pas se doubler, et une écriture en échec
  /// ne rompt pas la file.
  static Future<void> _persist(List<Build> toSave) {
    final write = _writeQueue.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _key,
        toSave.map((build) => jsonEncode(build.toJson())).toList(),
      );
    });

    _writeQueue = write.catchError((_) {});

    return _writeQueue;
  }
}
