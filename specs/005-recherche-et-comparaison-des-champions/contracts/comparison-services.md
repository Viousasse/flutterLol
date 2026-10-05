# Contrat : services et widgets de comparaison

Interfaces publiques de `lib/compare/` utilisées par d'autres modules ou par les tests.

## `ComparePage` — `lib/compare/compare_page.dart`

```dart
class ComparePage extends StatefulWidget {
  /// Champion déjà placé à gauche, quand on arrive depuis sa fiche.
  final String? initialChampionId;
  const ComparePage({super.key, this.initialChampionId});
}
```

Appelants : `ToolsSection` (`lib/tools/widgets/tools_section/tools_section.dart`), `ChampionsPage` (bouton « Comparer »), `ChampionDetailPage` (lien « Comparer avec un autre champion », avec `initialChampionId`). Charge elle-même `ChampionService`, `MatchupService`, `ItemService` et `BuildStore` : pas d'injection de source de données.

## `CombatStatsCalculator` — `lib/compare/services/combat_stats_calculator.dart`

```dart
class CombatStatsCalculator {
  static const minLevel = 1;
  static const maxLevel = 18;
  static const attackSpeedCap = 2.5;
  static double growthFactor(int level);            // 0 au niveau 1, 17 au niveau 18
  static CombatStats compute(ChampionStats base, int level, List<Item> items);
}
```

Un `level` hors de 1 à 18 est ramené dans les bornes. Les objets sont lus par `item.stats[clé]` (clés Data Dragon : `FlatHPPoolMod`, `FlatPhysicalDamageMod`, `FlatMagicDamageMod`, `FlatArmorMod`, `FlatSpellBlockMod`, `PercentAttackSpeedMod`, `FlatMovementSpeedMod`, `PercentMovementSpeedMod`, `FlatCritChanceMod`, `PercentLifeStealMod`). Pure, sans E/S.

## `ComparisonBuilder` — `lib/compare/services/comparison_builder.dart`

```dart
class ComparisonBuilder {
  static List<StatComparison> build(CombatStats left, CombatStats right);
}
```

Renvoie les lignes dans l'ordre d'affichage ; voir `data-model.md` pour les lignes conditionnelles.

## Modèles

```dart
enum ComparisonWinner { left, right, tie }

class StatComparison {
  final String label;
  final double left;
  final double right;
  final int decimals;                 // 0 par défaut
  ComparisonWinner get winner;
  double get leftFraction;            // 0..1
  double get rightFraction;           // 0..1
}

class CombatStats { /* 11 champs : health, attackDamage, abilityPower, attackSpeed,
  armor, magicResist, moveSpeed, attackRange, critChance, lifeSteal, difficulty */ }
```

## Widgets (usage interne à la page)

| Widget | Fichier | Paramètres |
|--------|---------|------------|
| `CompareSlot` | `lib/compare/widgets/compare_slot/compare_slot.dart` | `champion`, `emptyLabel`, `onTap` |
| `CompareItemSlots` | `lib/compare/widgets/compare_item_slots/compare_item_slots.dart` | `items`, `onAdd`, `onRemoveAt(int)` ; case « + » masquée à 6 objets (`maxItemSlots`) |
| `CompareLevelSlider` | `lib/compare/widgets/compare_level_slider/compare_level_slider.dart` | `level`, `onChanged(int)` ; 18 crans de 1 à 18 |
| `StatCompareRow` | `lib/compare/widgets/stat_compare_row/stat_compare_row.dart` | `stat` |
| `HeadToHeadCard` | `lib/compare/widgets/head_to_head_card/head_to_head_card.dart` | `left`, `right`, `dataset` |
| `SavedBuildPickerSheet` | `lib/compare/widgets/saved_build_picker_sheet/saved_build_picker_sheet.dart` | `static Future<Build?> show(context, {required List<Build> builds})` |

## Feuilles partagées réutilisées

- `ChampionPickerSheet.show(context, {required champions, excludedIds = const {}, roleFilter})` → `Future<Champion?>` (`lib/shared/widgets/champion_picker_sheet/champion_picker_sheet.dart`).
- `ItemPickerSheet.show(context, {required items})` → `Future<Item?>` (`lib/shared/widgets/item_picker_sheet/item_picker_sheet.dart`).

## Services de matchups ajoutés pour cette fonctionnalité — `lib/matchups/services/matchup_service.dart`

```dart
static const minGames = 8;
static OverallRecord overallFor(String championId, MatchupDataset dataset);
static Matchup? headToHead(String championId, String opponentId, MatchupDataset dataset);
```

`OverallRecord.minReliableGames = 100` (`lib/matchups/models/matchup.dart`).
