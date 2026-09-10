import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const _key = 'favorite_champions';
  static Set<String>? _cache;
  static Future<void> _writeQueue = Future.value();

  static Future<void> _ensureLoaded() async {
    if (_cache != null) return;
    final prefs = await SharedPreferences.getInstance();
    _cache = (prefs.getStringList(_key) ?? []).toSet();
  }

  static Future<Set<String>> getFavorites() async {
    await _ensureLoaded();
    return Set.from(_cache!);
  }

  static Future<void> toggleFavorite(String championId) async {
    await _ensureLoaded();

    if (_cache!.contains(championId)) {
      _cache!.remove(championId);
    } else {
      _cache!.add(championId);
    }

    _writeQueue = _writeQueue.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, _cache!.toList());
    });

    await _writeQueue;
  }

  static Future<bool> isFavorite(String championId) async {
    await _ensureLoaded();
    return _cache!.contains(championId);
  }
}
