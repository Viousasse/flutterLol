import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const _key = 'favorite_champions';

  static Future<Set<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? []).toSet();
  }

  static Future<void> toggleFavorite(String championId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = (prefs.getStringList(_key) ?? []).toSet();

    if (favorites.contains(championId)) {
      favorites.remove(championId);
    } else {
      favorites.add(championId);
    }

    await prefs.setStringList(_key, favorites.toList());
  }

  static Future<bool> isFavorite(String championId) async {
    final favorites = await getFavorites();
    return favorites.contains(championId);
  }
}
