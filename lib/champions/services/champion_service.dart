import '../../data_dragon/data_dragon_service.dart';
import '../models/champion.dart';
import '../models/champion_detail.dart';

class ChampionService {
  static List<Champion>? _cache;

  static Future<List<Champion>> fetchAll() async {
    final cached = _cache;
    if (cached != null) return cached;

    final version = await DataDragonService.latestVersion();
    final data = await DataDragonService.fetchJson(
      DataDragonService.dataUrl(version, 'champion.json'),
    );
    final championsMap = data['data'] as Map<String, dynamic>;

    final champions = championsMap.values
        .map((json) => Champion.fromJson(json, version))
        .toList();

    // Le cache n'est renseigné qu'une fois le parsing réussi : un échec doit
    // laisser le service dans l'état où un « Réessayer » retélécharge tout.
    _cache = champions;

    return champions;
  }

  static Future<ChampionDetail> fetchDetail(String championId) async {
    final version = await DataDragonService.latestVersion();

    final data = await DataDragonService.fetchJson(
      DataDragonService.dataUrl(version, 'champion/$championId.json'),
    );
    final championJson = data['data'][championId];

    return ChampionDetail.fromJson(championJson, version);
  }
}
