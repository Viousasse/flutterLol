# Contrat : services et widgets de la draft

Interfaces publiques de `lib/draft/` utilisées par d'autres modules (la page d'équipe, l'historique 017, le mode à deux 016, les tests).

## Point d'entrée : `DraftPage` (`lib/draft/draft_page.dart`)

```dart
const DraftPage({
  Key? key,
  DraftMode mode = DraftMode.vsSite,
  DraftRecord? replayOf,                                   // rejeu : voir 017
  Future<List<Champion>> Function() loadChampions = ChampionService.fetchAll,
  Future<MatchupDataset> Function() loadDataset = MatchupService.load,
  Future<ChampionDetail> Function(String championId) loadDetail = ChampionService.fetchDetail,
  Duration botThinkingDelay = const Duration(milliseconds: 900),
});
```

- Ouverte par `lib/team/team_page.dart` (`DraftPage()` et `DraftPage(mode: DraftMode.vsFriend)`) et par la page de détail d'une draft (`replayOf:`).
- Les trois chargeurs et le délai sont remplaçables pour jouer sans réseau (tests).

## `DraftState` (`lib/draft/models/draft_state.dart`)

```dart
factory DraftState.empty({bool withBans = false});
DraftState pick(DraftSide side, int roleIndex, Champion champion); // StateError si illégal
DraftState ban(DraftSide side, Champion champion);                // StateError si illégal
List<Champion?> teamOf(DraftSide side);
List<Champion?> bansOf(DraftSide side);
DraftSide? get nextSide;
bool get isBanPhase;  bool get isComplete;  bool get hasBans;
int get pickCount;  int get banCount;  int get totalBans;
Set<String> get pickedIds;  Set<String> get unavailableIds;
```

Constantes : `draftPickOrder`, `draftBanOrder`, `bansPerSide`.

## `DraftBot` (`lib/draft/services/draft_bot.dart`)

```dart
DraftBot({required MatchupDataset dataset, Random? random});
final LaneProfile profile;                        // aussi lu par la page pour le filtre de rôle
DraftChoice choose({required DraftState state, required DraftSide side, required List<Champion> pool});
Champion chooseBan({required DraftState state, required List<Champion> pool});
static double needBonusFor(Champion candidate, Iterable<Champion> teammates);
static ({bool magic, bool physical, bool frontline}) needsFilledBy(Champion candidate, Iterable<Champion> teammates);
static bool isFrontliner(Champion champion);
```

`Random` est injectable pour des tests déterministes. `DraftChoice { int roleIndex; Champion champion; }`.

## `DraftAdvisor` (`lib/draft/services/draft_advisor.dart`)

```dart
DraftAdvisor({required MatchupDataset dataset});
List<DraftSuggestion> suggest({
  required DraftState state,
  required DraftSide side,
  required List<Champion> pool,
  int count = 3,
});
static const fallbackReason = 'Se joue régulièrement à ce poste.';
```

Renvoie une liste vide pendant les bannissements, quand la draft est terminée, quand `count <= 0` ou quand le camp n'a plus de rôle libre. Déterministe.

## `DraftEvaluator` (`lib/draft/services/draft_evaluator.dart`)

```dart
static DraftReport evaluate({
  required List<TeamMember> blue,        // cinq membres, dans l'ordre de teamRoles
  required List<TeamMember> red,
  required MatchupDataset dataset,
  Map<String, String> championNames = const {},   // id -> nom, pour les conseils et les bans
  DraftPlayers? players,                          // null : bilan adressé au joueur
  List<String> blueBans = const [],
  List<String> redBans = const [],
});
```

Constantes publiques : `balanceTolerance` (0,05), `laneWinThreshold` (0,53), `laneLossThreshold` (0,47), `winRateTolerance` (0,01), `tieScoreGap` (0,5).

## `BanAnalyzer` (`lib/draft/services/ban_analyzer.dart`)

```dart
static BanAnalysis analyze({
  required List<String> blueBans, required List<String> redBans,
  required List<String> bluePicks, required List<String> redPicks,
  required MatchupDataset dataset,
  required Map<String, String> names,
  DraftPlayers? players,
});
```

Constantes : `strongWinRate` 0,52, `weakWinRate` 0,5, `maxMissed` 2. Les identifiants vides sont ignorés ; sans aucun ban, renvoie `BanAnalysis.none()`.

## Widgets (`lib/draft/widgets/`)

| Widget | Paramètres | Rôle |
|--------|-----------|------|
| `DraftSlot` | `role`, `champion?`, `onTap?` | case d'un rôle ; bouton seulement si libre et `onTap` fourni |
| `BanRow` | `owner`, `bans`, `onTap?` | rangée de bans ; vide si `bans` est vide |
| `CriterionTile` | `criterion`, `players?` | un critère du bilan |
| `DraftReportView` | `report` | verdict, critères, bannissements, forces et conseils (un bloc par joueur en duel) |
| `SuggestionCard` | `champion`, `role`, `reasons`, `onTap` | carte de conseil, un seul bouton sémantique |

## Dépendances sortantes

- `LaneProfile.fromDataset(dataset)` / `fits(championId, lane)` (`lib/matchups/services/lane_profile.dart`).
- `MatchupService.overallFor`, `headToHead` ; `CounterService.counters(…, includeLowConfidence: false)`.
- `TeamAnalyzer.analyze(List<TeamMember>)` et `teamRoles` / `teamRoleLanes` (outil « Composition »).
- `ChampionPickerSheet.show(context, champions:, excludedIds:, roleFilter:)` et `ChampionRoleFilter` (spec 018).
- `DraftHistoryStore.add(DraftRecord)` et `DraftRecord.from(…)` (spec 017).
