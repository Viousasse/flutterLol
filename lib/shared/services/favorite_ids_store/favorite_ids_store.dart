import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ensemble d'identifiants mis en favori, conservé entre deux lancements.
///
/// Les écrans écoutent [favorites] plutôt que de garder chacun leur copie :
/// basculer un favori depuis une fiche met à jour la carte qui l'a ouverte,
/// sans que l'une ait à connaître l'autre. Champions et objets partagent cette
/// mécanique et ne diffèrent que par leur clé de stockage.
class FavoriteIdsStore {
  final String storageKey;

  final ValueNotifier<Set<String>> favorites = ValueNotifier(
    const <String>{},
  );

  Future<void>? _loading;
  Future<void> _writeQueue = Future.value();

  FavoriteIdsStore(this.storageKey);

  /// Le futur est mis en cache, pas seulement son résultat : plusieurs écrans
  /// ouverts en même temps ne relisent pas le disque chacun de leur côté.
  Future<void> ensureLoaded() {
    final loading = _loading;
    if (loading != null) return loading;

    final request = _load();
    _loading = request;

    return request;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      favorites.value = (prefs.getStringList(storageKey) ?? const []).toSet();
    } catch (_) {
      // Stockage indisponible : on démarre sans favoris plutôt que de faire
      // planter l'app, et le prochain appel pourra retenter.
      _loading = null;
    }
  }

  bool isFavorite(String id) => favorites.value.contains(id);

  Future<void> toggle(String id) async {
    await ensureLoaded();

    final updated = Set<String>.from(favorites.value);
    if (!updated.remove(id)) {
      updated.add(id);
    }
    favorites.value = updated;

    await _persist(updated);
  }

  /// Les écritures s'enchaînent pour ne pas se doubler.
  ///
  /// Une écriture en échec ne doit pas rompre la file : sans le `catchError`,
  /// toutes les écritures suivantes échoueraient à leur tour et les favoris
  /// cesseraient silencieusement d'être enregistrés.
  Future<void> _persist(Set<String> ids) {
    final write = _writeQueue.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(storageKey, ids.toList());
    });

    _writeQueue = write.catchError((_) {});

    return _writeQueue;
  }
}
