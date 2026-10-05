import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/draft_record.dart';

/// Les drafts jouées, conservées entre deux lancements.
///
/// Même forme que les builds : un [ValueNotifier] que les écrans écoutent, pour
/// qu'une draft terminée apparaisse dans l'historique sans rechargement.
class DraftHistoryStore {
  static const _key = 'draft_history';

  /// Au-delà, les plus anciennes sont oubliées : l'historique ne doit pas
  /// grossir sans fin dans le stockage de l'appareil.
  static const maxRecords = 50;

  static final ValueNotifier<List<DraftRecord>> records = ValueNotifier(
    const <DraftRecord>[],
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
      records.value = (prefs.getStringList(_key) ?? const [])
          .map(_decode)
          .whereType<DraftRecord>()
          .toList();
    } catch (_) {
      // Stockage indisponible : on démarre sans historique plutôt que de
      // planter, et le prochain appel pourra retenter.
      _loading = null;
    }
  }

  static DraftRecord? _decode(String raw) {
    try {
      return DraftRecord.tryFromJson(jsonDecode(raw));
    } on FormatException {
      return null;
    }
  }

  static String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  /// Ajoute la draft en tête de liste, ou remplace celle de même identifiant.
  static Future<void> add(DraftRecord record) async {
    await ensureLoaded();

    final others = records.value.where((saved) => saved.id != record.id);
    final updated = [record, ...others].take(maxRecords).toList();
    records.value = updated;

    await _persist(updated);
  }

  static Future<void> delete(String id) async {
    await ensureLoaded();

    final updated = records.value.where((saved) => saved.id != id).toList();
    records.value = updated;

    await _persist(updated);
  }

  static Future<void> clear() async {
    await ensureLoaded();

    records.value = const [];
    await _persist(const []);
  }

  /// Les écritures s'enchaînent pour ne pas se doubler, et une écriture en
  /// échec ne rompt pas la file.
  static Future<void> _persist(List<DraftRecord> updated) {
    final encoded = updated
        .map((record) => jsonEncode(record.toJson()))
        .toList();

    _writeQueue = _writeQueue.then((_) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_key, encoded);
      } catch (_) {
        // La liste en mémoire reste juste ; seule la sauvegarde est perdue.
      }
    });

    return _writeQueue;
  }
}
