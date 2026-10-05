import 'package:flutter/foundation.dart';

import '../../shared/services/favorite_ids_store/favorite_ids_store.dart';

/// Source de vérité unique des champions favoris.
class FavoritesService {
  static final _store = FavoriteIdsStore('favorite_champions');

  static ValueNotifier<Set<String>> get favorites => _store.favorites;

  static Future<void> ensureLoaded() => _store.ensureLoaded();

  static bool isFavorite(String championId) => _store.isFavorite(championId);

  static Future<void> toggleFavorite(String championId) =>
      _store.toggle(championId);
}
