import 'package:flutter/foundation.dart';

import '../../shared/services/favorite_ids_store/favorite_ids_store.dart';

/// Source de vérité unique des objets favoris.
class ItemFavoritesService {
  static final _store = FavoriteIdsStore('favorite_items');

  static ValueNotifier<Set<String>> get favorites => _store.favorites;

  static Future<void> ensureLoaded() => _store.ensureLoaded();

  static bool isFavorite(String itemId) => _store.isFavorite(itemId);

  static Future<void> toggleFavorite(String itemId) => _store.toggle(itemId);
}
