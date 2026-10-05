import '../../data_dragon/data_dragon_service.dart';
import '../models/summoner_spell.dart';

class SummonerSpellService {
  static Map<String, SummonerSpell>? _cache;
  static Future<Map<String, SummonerSpell>>? _pending;

  /// Les sorts de la partie classique, indexés par identifiant Riot.
  ///
  /// Le futur en cours est mis en cache, pas seulement son résultat : plusieurs
  /// fiches champion ouvertes coup sur coup ne retéléchargent pas le fichier.
  static Future<Map<String, SummonerSpell>> fetchAll() {
    final cached = _cache;
    if (cached != null) return Future.value(cached);

    final pending = _pending;
    if (pending != null) return pending;

    final request = _fetchAll();
    _pending = request;

    return request;
  }

  static Future<Map<String, SummonerSpell>> _fetchAll() async {
    try {
      final version = await DataDragonService.latestVersion();
      final data = await DataDragonService.fetchJson(
        DataDragonService.dataUrl(version, 'summoner.json'),
        offlineKey: 'summoners',
        isValid: DataDragonService.hasDataMap,
      );
      final raw = data['data'] as Map<String, dynamic>;

      final spells = {
        for (final entry in raw.entries)
          if (SummonerSpell.isClassic(entry.value as Map<String, dynamic>))
            entry.key: SummonerSpell.fromJson(
              entry.value as Map<String, dynamic>,
              version,
            ),
      };

      // Le cache n'est renseigné qu'une fois le parsing réussi : un échec doit
      // laisser le service dans l'état où un nouvel appel retélécharge tout.
      _cache = spells;

      return spells;
    } finally {
      _pending = null;
    }
  }

  /// Résout des identifiants en sorts, dans l'ordre donné. Un identifiant que
  /// Riot ne publie plus est ignoré plutôt que de faire échouer l'affichage.
  static Future<List<SummonerSpell>> byIds(List<String> ids) async {
    final all = await fetchAll();

    return [for (final id in ids) ?all[id]];
  }
}
