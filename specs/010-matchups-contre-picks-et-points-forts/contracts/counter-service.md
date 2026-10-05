# Contrat : `CounterService`, `CounterPick` et widgets partagés

## `CounterService` (`lib/counters/services/counter_service.dart`)

```dart
class CounterService {
  static const maxPicks = 15;
  static const minReliablePicks = 5;
  static const maxWeaknesses = 5;

  /// Champions qui s'en sortent le mieux face à opponentId.
  static List<CounterPick> counters(String opponentId, MatchupDataset dataset,
      {String? lane, bool includeLowConfidence = true});

  /// Adversaires contre lesquels championId gagne le plus. championId de la
  /// proposition = l'adversaire ; taux = ceux de championId.
  static List<CounterPick> strongAgainst(String championId, MatchupDataset dataset,
      {String? lane, bool includeLowConfidence = true});

  /// Adversaires contre lesquels championId perd (fiables, taux < 0,5), max 5.
  static List<CounterPick> weakAgainst(String championId, MatchupDataset dataset,
      {String? lane});

  static List<String> lanesFor(String opponentId, MatchupDataset dataset);
  static List<String> lanesPlayedBy(String championId, MatchupDataset dataset);
}
```

Garanties : `lane == null` additionne les voies ; résultat déterministe (taux, puis parties, puis identifiant) ; `includeLowConfidence: false` ne renvoie que les bilans fiables (utilisé par `lib/draft/services/draft_evaluator.dart`) ; jamais plus de 15 éléments.

## `CounterPick` (`lib/counters/models/counter_pick.dart`)

```dart
const CounterPick({required String championId, required int games, required int wins});
double get winRate;
bool get isReliable;          // games >= MatchupService.minGames
double get smoothedWinRate;   // (wins + 5) / (games + 10)
static const priorGames = 10;
```

## Pages

```dart
CountersPage({Key? key, String? initialOpponentId,
  Future<List<Champion>> Function() loadChampions = ChampionService.fetchAll,
  Future<MatchupDataset> Function() loadDataset = MatchupService.load});

StrengthsPage({Key? key, String? initialChampionId,
  Future<List<Champion>> Function() loadChampions = ChampionService.fetchAll,
  Future<MatchupDataset> Function() loadDataset = MatchupService.load});
```

Les deux fonctions de chargement sont injectables pour tester sans réseau (ajout de la phase tests, présent dans l'arbre de travail non commité).

## Widgets partagés

```dart
// lib/shared/widgets/counter_tile/counter_tile.dart
CounterTile({required CounterPick pick, required Champion champion,
             required int rank, required VoidCallback onTap});

// lib/shared/widgets/lane_filter_bar/lane_filter_bar.dart
LaneFilterBar({required List<String> lanes, required String? selectedLane,
               required ValueChanged<String?> onSelect}); // null = « Toutes les voies »

// lib/shared/widgets/data_source_note/data_source_note.dart
DataSourceNote({required MatchupDataset dataset});
static String DataSourceNote.textFor(MatchupDataset dataset);
static const DataSourceNote.emptyText = 'Aucune donnée de matchups disponible.';
```

`textFor` : « Données : 7 600 parties classées Master+ (EUW), patchs 16.16–16.19. » ; « partie » au singulier pour 1 ; « patch » au singulier sans plage ; `emptyText` si 0 partie ou patch absent ou vide.
