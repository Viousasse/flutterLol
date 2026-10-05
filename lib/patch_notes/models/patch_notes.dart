/// Les notes de patch officielles du dernier patch du jeu.
///
/// Riot ne publie pas le contenu des notes dans une API : on ne retient que le
/// numéro de patch et l'adresse de la page officielle.
class PatchNotes {
  static const _baseUrl =
      'https://www.leagueoflegends.com/fr-fr/news/game-updates';

  /// Les numéros de patch publiés sur le site portent l'année de la saison
  /// (26.19), alors que Data Dragon garde le numéro de saison seul (16.19).
  static const _seasonOffset = 10;

  /// Numéro tel qu'affiché sur le site, par exemple « 26.19 ».
  final String label;

  /// Page officielle des notes de ce patch.
  final String url;

  const PatchNotes({required this.label, required this.url});

  /// Déduit le patch de la version Data Dragon (« 16.19.1 »), ou `null` si la
  /// version n'a pas la forme attendue.
  static PatchNotes? fromVersion(String version) {
    final parts = version.split('.');
    if (parts.length < 2) return null;

    final season = int.tryParse(parts[0]);
    final patch = int.tryParse(parts[1]);
    if (season == null || patch == null) return null;

    final year = season + _seasonOffset;

    return PatchNotes(
      label: '$year.$patch',
      url: '$_baseUrl/league-of-legends-patch-$year-$patch-notes',
    );
  }
}
