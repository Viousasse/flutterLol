import 'package:shared_preferences/shared_preferences.dart';

/// Dernière copie lisible d'un document Data Dragon, gardée pour ouvrir
/// l'application sans connexion.
///
/// La clé est un nom logique (« champions », « items »…) et non l'URL : l'URL
/// change à chaque patch, et chaque version resterait stockée à côté de la
/// précédente jusqu'à saturer le stockage du navigateur.
class OfflineJsonCache {
  static const _prefix = 'ddragon_offline_';

  static Future<void> write(String key, String body) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefix$key', body);
    } catch (_) {
      // Stockage plein ou indisponible : la copie hors ligne est un bonus,
      // son absence ne doit jamais faire échouer un chargement réussi.
    }
  }

  static Future<String?> read(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return prefs.getString('$_prefix$key');
    } catch (_) {
      return null;
    }
  }
}
