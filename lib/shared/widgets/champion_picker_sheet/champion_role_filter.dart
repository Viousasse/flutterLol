/// Un filtre par rôle pour la feuille de choix d'un champion.
///
/// La feuille ne sait pas ce qu'est un rôle : l'écran qui l'ouvre lui donne les
/// rôles à proposer et la façon de savoir si un champion s'y joue.
class ChampionRoleFilter {
  /// Les rôles proposés, du libellé affiché vers la voie qui le désigne, dans
  /// l'ordre d'affichage.
  final Map<String, String> roles;

  /// Vrai si [championId] se joue régulièrement dans [lane].
  final bool Function(String championId, String lane) fits;

  /// Voie sélectionnée à l'ouverture, ou `null` pour afficher tous les
  /// champions.
  final String? initialLane;

  const ChampionRoleFilter({
    required this.roles,
    required this.fits,
    this.initialLane,
  });
}
