import 'package:shared_preferences/shared_preferences.dart';

/// Dernière copie lisible d'un document Data Dragon, gardée pour ouvrir
/// l'application sans connexion.
///
/// La clé est un nom logique (« champions », « items »…) et non l'URL : l'URL
/// change à chaque patch, et chaque version resterait stockée à côté de la
/// précédente jusqu'à saturer le stockage du navigateur.
class OfflineJsonCache {
  static const _prefix = 'ddragon_offline_';
  static const _recencyPrefix = 'ddragon_recent_';

  /// Écrit la copie de [key]. Avec [keepLast], la clé doit être de la forme
  /// `famille:nom` : seules les [keepLast] copies les plus récemment écrites de
  /// la famille sont gardées, les autres sont effacées.
  static Future<void> write(String key, String body, {int? keepLast}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefix$key', body);

      if (keepLast != null) await _trim(prefs, key, keepLast);
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

  /// Tient à jour, par famille, la liste des clés de la plus ancienne à la plus
  /// récente, et supprime l'excédent.
  static Future<void> _trim(
    SharedPreferences prefs,
    String key,
    int keepLast,
  ) async {
    final family = key.split(':').first;
    final indexKey = '$_recencyPrefix$family';

    final recent = [...?prefs.getStringList(indexKey)]
      ..remove(key)
      ..add(key);

    while (recent.length > keepLast) {
      await prefs.remove('$_prefix${recent.removeAt(0)}');
    }

    await prefs.setStringList(indexKey, recent);
  }
}
