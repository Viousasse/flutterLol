import 'dart:convert';

import 'package:http/http.dart' as http;

class DataDragonService {
  static const _baseUrl = 'https://ddragon.leagueoflegends.com';

  static Future<String>? _pendingVersion;

  /// Le futur est mis en cache, pas seulement son résultat : sans ça, deux
  /// écrans ouverts en même temps au démarrage interrogeaient chacun
  /// versions.json avant que le premier ait répondu.
  static Future<String> latestVersion() {
    final pending = _pendingVersion;
    if (pending != null) return pending;

    final request = _fetchLatestVersion();
    _pendingVersion = request;

    return request;
  }

  static Future<String> _fetchLatestVersion() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/versions.json'));
      final versions = jsonDecode(response.body) as List;

      return versions.first as String;
    } catch (error) {
      _pendingVersion = null;
      rethrow;
    }
  }

  static String dataUrl(String version, String fileName) {
    return '$_baseUrl/cdn/$version/data/fr_FR/$fileName';
  }

  static String mapImageUrl(String version, String mapId) {
    return '$_baseUrl/cdn/$version/img/map/map$mapId.png';
  }

  /// Les icônes de runes ne sont pas versionnées comme le reste des assets :
  /// Riot les sert directement sous `cdn/img/`.
  static String perkIconUrl(String iconPath) {
    return '$_baseUrl/cdn/img/$iconPath';
  }
}
