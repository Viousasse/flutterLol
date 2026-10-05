/// Une apparence d'un champion, telle que Data Dragon la décrit.
class ChampionSkin {
  static const _baseUrl = 'https://ddragon.leagueoflegends.com/cdn/img/champion';

  /// Nom affiché pour l'apparence d'origine, que Riot nomme « default ».
  static const defaultName = 'Apparence classique';

  final String championId;

  /// Numéro de l'apparence dans les adresses des images ; 0 pour l'apparence
  /// d'origine.
  final int number;
  final String name;

  const ChampionSkin({
    required this.championId,
    required this.number,
    required this.name,
  });

  /// Grande illustration horizontale, pour le plein écran.
  String get splashUrl => '$_baseUrl/splash/${championId}_$number.jpg';

  /// Illustration verticale plus légère, pour les vignettes.
  String get loadingUrl => '$_baseUrl/loading/${championId}_$number.jpg';

  /// Les apparences listées par Riot, sans les variantes de couleur (chromas)
  /// qui n'ont pas d'illustration propre : elles portent un `parentSkin`.
  static List<ChampionSkin> listFromJson(String championId, dynamic rawSkins) {
    if (rawSkins is! List) return const [];

    return [
      for (final raw in rawSkins.whereType<Map<String, dynamic>>())
        if (raw['parentSkin'] == null)
          ChampionSkin(
            championId: championId,
            number: (raw['num'] as num).toInt(),
            name: raw['name'] == 'default'
                ? defaultName
                : raw['name'] as String,
          ),
    ];
  }
}
