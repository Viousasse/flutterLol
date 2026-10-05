# Contrat : filtre de rôle

## ChampionRoleFilter

```dart
class ChampionRoleFilter {
  final Map<String, String> roles;                          // libellé -> voie, ordre d'affichage
  final bool Function(String championId, String lane) fits;
  final String? initialLane;                                // null = « Tous »
  const ChampionRoleFilter({required roles, required fits, initialLane});
}
```

## ChampionPickerSheet

```dart
ChampionPickerSheet.show(
  BuildContext context, {
  required List<Champion> champions,
  Set<String> excludedIds = const {},
  ChampionRoleFilter? roleFilter,     // null : aucune puce
}) -> Future<Champion?>;
```

Comportement : puces « Tous » puis une par entrée de `roles` ; la liste applique exclusions, recherche et `fits` ; « Aucun champion ne correspond. » si vide.

## RoleFilters (`lib/team/services/role_filters.dart`)

```dart
static Future<LaneProfile?> loadProfile();   // null si le jeu de matchups ne se charge pas
static ChampionRoleFilter? forProfile(LaneProfile? profile, {int? roleIndex});
// null sans profil ; roleIndex = rang dans teamRoles pour la voie de départ
```

## LaneProfile

```dart
static const minShare = 0.15;
factory LaneProfile.fromDataset(MatchupDataset dataset);
bool fits(String championId, String lane);
```

Consommateurs : `DraftPage`, `TeamPage`, `CountersPage`, `StrengthsPage`, `ComparePage`, `BuildEditorPage`, `DraftBot`, `DraftAdvisor`.
