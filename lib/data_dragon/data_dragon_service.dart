import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'data_dragon_exception.dart';
import 'offline_json_cache.dart';

class DataDragonService {
  static const _baseUrl = 'https://ddragon.leagueoflegends.com';

  /// Au-delà, on considère le CDN injoignable : mieux vaut rendre la main à
  /// l'utilisateur avec un « Réessayer » que de le laisser attendre.
  static const _timeout = Duration(seconds: 15);

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
      final versions =
          await fetchJson(
                '$_baseUrl/api/versions.json',
                offlineKey: 'versions',
              )
              as List;
      if (versions.isEmpty) {
        throw const DataDragonException('Aucune version de jeu publiée.');
      }

      return versions.first as String;
    } catch (_) {
      // Un échec ne doit pas se figer dans le cache : le prochain appel doit
      // pouvoir retenter, sinon le « Réessayer » des écrans ne sert à rien.
      _pendingVersion = null;
      rethrow;
    }
  }

  /// Récupère et décode un document JSON de Data Dragon.
  ///
  /// Toute panne — réseau coupé, CDN en erreur, corps illisible — ressort en
  /// [DataDragonException] portant un message affichable.
  ///
  /// Avec un [offlineKey], le dernier document reçu est gardé sur l'appareil et
  /// resservi quand Riot est injoignable : l'application s'ouvre alors sans
  /// connexion, avec les données du dernier lancement réussi.
  static Future<dynamic> fetchJson(String url, {String? offlineKey}) async {
    try {
      final body = await _download(url);
      final decoded = _decode(body);

      // La copie n'est écrite qu'une fois le document décodé : un corps
      // illisible ne doit pas écraser la dernière bonne version.
      if (offlineKey != null) await OfflineJsonCache.write(offlineKey, body);

      return decoded;
    } on DataDragonException {
      if (offlineKey == null) rethrow;

      final saved = await OfflineJsonCache.read(offlineKey);
      if (saved == null) rethrow;

      try {
        return jsonDecode(saved);
      } on FormatException {
        // Copie corrompue : on remonte la vraie panne réseau, pas celle-ci.
        rethrow;
      }
    }
  }

  static Future<String> _download(String url) async {
    final http.Response response;

    try {
      response = await http.get(Uri.parse(url)).timeout(_timeout);
    } on TimeoutException {
      throw const DataDragonException(
        'Le serveur de Riot met trop de temps à répondre.',
      );
    } catch (_) {
      throw const DataDragonException(
        'Connexion au serveur de Riot impossible. Vérifie ta connexion.',
      );
    }

    if (response.statusCode != 200) {
      throw DataDragonException(
        'Le serveur de Riot a répondu ${response.statusCode}.',
      );
    }

    return response.body;
  }

  static dynamic _decode(String body) {
    try {
      return jsonDecode(body);
    } on FormatException {
      throw const DataDragonException('Réponse illisible du serveur de Riot.');
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
