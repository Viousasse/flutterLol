import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Source de vérité unique des champions favoris.
///
/// Les écrans écoutent [favorites] plutôt que de garder chacun leur copie :
/// mettre un champion en favori depuis sa fiche met à jour la carte qui l'a
/// ouverte, sans que l'une ait à connaître l'autre.
class FavoritesService {
  static const _key = 'favorite_champions';

  static final ValueNotifier<Set<String>> favorites = ValueNotifier(
    const <String>{},
  );

  static Future<void>? _loading;
  static Future<void> _writeQueue = Future.value();

  /// Le futur est mis en cache, pas seulement son résultat : plusieurs écrans
  /// ouverts en même temps ne relisent pas le disque chacun de leur côté.
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
      favorites.value = (prefs.getStringList(_key) ?? const []).toSet();
    } catch (_) {
      // Stockage indisponible : on démarre sans favoris plutôt que de faire
      // planter l'app, et le prochain appel pourra retenter.
      _loading = null;
    }
  }

  static bool isFavorite(String championId) {
    return favorites.value.contains(championId);
  }

  static Future<void> toggleFavorite(String championId) async {
    await ensureLoaded();

    final updated = Set<String>.from(favorites.value);
    if (!updated.remove(championId)) {
      updated.add(championId);
    }
    favorites.value = updated;

    await _persist(updated);
  }

  /// Les écritures s'enchaînent pour ne pas se doubler.
  ///
  /// Une écriture en échec ne doit pas rompre la file : sans le `catchError`,
  /// toutes les écritures suivantes échoueraient à leur tour et les favoris
  /// cesseraient silencieusement d'être enregistrés.
  static Future<void> _persist(Set<String> championIds) {
    final write = _writeQueue.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, championIds.toList());
    });

    _writeQueue = write.catchError((_) {});

    return _writeQueue;
  }
}
