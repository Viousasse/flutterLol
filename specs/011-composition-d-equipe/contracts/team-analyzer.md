# Contrat : analyse d'équipe et widgets

## `TeamAnalyzer` (`lib/team/services/team_analyzer.dart`)

```dart
class TeamAnalyzer {
  static const fullTeamSize = 5;
  static const minMembersForVerdict = 3;
  static const minDamageShare = 0.2;
  static const frontlineDefense = 7;
  static const minControlSpells = 3;

  static TeamAnalysis analyze(List<TeamMember> members);
}
```

Pure et déterministe, sans E/S. Entrée vide : parts à 0, aucun constat. Les messages sont en français.

## `CrowdControl` (`lib/team/services/crowd_control.dart`)

```dart
class CrowdControl {
  static const List<String> keywords;
  static bool controls(String description);      // insensible à la casse
  static int spellCount(ChampionDetail detail);  // sorts A/Z/E/R, hors passif
}
```

## Modèles

```dart
enum InsightKind { good, warning, info }
class TeamInsight { final InsightKind kind; final String title; final String message; }
class TeamAnalysis {
  final double physicalShare, magicShare;
  final int frontlineCount, controlSpellCount, memberCount;
  final List<TeamInsight> insights;
}
class TeamMember { final Champion champion; final ChampionDetail detail; }
```

## Constantes de rôles (`lib/team/constants/team_roles.dart`)

```dart
const teamRoles = ['Top', 'Jungle', 'Milieu', 'Bot', 'Support'];
const teamRoleLanes = ['TOP', 'JUNGLE', 'MIDDLE', 'BOTTOM', 'UTILITY'];
```

Réutilisées hors de la fonctionnalité (filtre de rôle des contre-picks, points forts, builds, draft).

## `RoleFilters` (`lib/team/services/role_filters.dart`)

```dart
static Future<LaneProfile?> loadProfile();   // null si les matchups ne chargent pas
static ChampionRoleFilter? forProfile(LaneProfile? profile, {int? roleIndex}); // null sans profil
```

## Widgets

```dart
TeamPage({Key? key,
  Future<List<Champion>> Function() loadChampions = ChampionService.fetchAll,
  Future<ChampionDetail> Function(String championId) loadDetail = ChampionService.fetchDetail,
  Future<LaneProfile?> Function() loadProfile = RoleFilters.loadProfile});

TeamSlot({required String role, required Champion? champion, required bool isLoading,
          required VoidCallback onTap, required VoidCallback onClear});
DamageSplitBar({required double physicalShare, required double magicShare});
InsightTile({required TeamInsight insight});
```

Les trois paramètres de chargement de `TeamPage` sont injectables pour les tests (ajout présent dans l'arbre de travail non commité).
