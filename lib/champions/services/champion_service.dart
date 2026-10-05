import '../../data_dragon/data_dragon_service.dart';
import '../models/champion.dart';
import '../models/champion_detail.dart';

class ChampionService {
  static const _detailCopiesKept = 12;

  static List<Champion>? _cache;
  static Future<List<Champion>>? _pending;

  /// Le futur en cours est mis en cache, pas seulement son résultat : l'accueil,
  /// la liste des champions et les rôles demandent la liste en même temps au
  /// démarrage, et téléchargeaient sinon champion.json chacun de leur côté.
  static Future<List<Champion>> fetchAll() {
    final cached = _cache;
    if (cached != null) return Future.value(cached);

    final pending = _pending;
    if (pending != null) return pending;

    final request = _fetchAll();
    _pending = request;

    return request;
  }

  static Future<List<Champion>> _fetchAll() async {
    try {
      final version = await DataDragonService.latestVersion();
      final data = await DataDragonService.fetchJson(
        DataDragonService.dataUrl(version, 'champion.json'),
        offlineKey: 'champions',
        isValid: DataDragonService.hasDataMap,
      );
      final championsMap = data['data'] as Map<String, dynamic>;

      final champions = championsMap.values
          .map((json) => Champion.fromJson(json, version))
          .toList();

      // Le cache n'est renseigné qu'une fois le parsing réussi : un échec doit
      // laisser le service dans l'état où un « Réessayer » retélécharge tout.
      _cache = champions;

      return champions;
    } finally {
      _pending = null;
    }
  }

  static Future<ChampionDetail> fetchDetail(String championId) async {
    final version = await DataDragonService.latestVersion();

    final data = await DataDragonService.fetchJson(
      DataDragonService.dataUrl(version, 'champion/$championId.json'),
      // La fiche d'un champion déjà consulté reste lisible sans réseau ; on
      // ne garde que les plus récentes pour ne pas remplir le stockage.
      offlineKey: 'champion:$championId',
      offlineKeepLast: _detailCopiesKept,
      isValid: DataDragonService.hasDataMap,
    );
    final championJson = data['data'][championId];

    return ChampionDetail.fromJson(championJson, version);
  }
}
