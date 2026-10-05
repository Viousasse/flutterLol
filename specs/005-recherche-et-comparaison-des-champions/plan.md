# Implementation Plan: Recherche et comparaison des champions

**Branch**: `005-recherche-et-comparaison-des-champions` (travail livré sur `main`) | **Date**: 2026-10-05 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/005-recherche-et-comparaison-des-champions/spec.md`

**Note**: plan rédigé après coup d'après le code livré (commits `033ca39`, `32fac77`, `ae4c0c2` pour la grille, `a30c9fc`).

## Summary

Comparer deux champions à un niveau et avec des objets choisis (écran `ComparePage`), avec un bilan en duel issu des parties Master+ embarquées ; retrouver un champion ou un objet par une recherche unique depuis l'accueil (`SearchPage`) ; filtrer et trier la liste des champions (nom, rôle, région, difficulté, taux de victoire). Approche : le calcul des caractéristiques (`CombatStatsCalculator`), la fabrication des lignes (`ComparisonBuilder`), le filtre/tri (`ChampionFilter`) et la recherche (`GlobalSearch`, `normalizeSearchText`) sont des classes statiques sans dépendance Flutter, testées sans réseau ; les écrans les assemblent avec `setState`.

## Technical Context

**Language/Version**: Dart 3 / Flutter, SDK `^3.13.3` (`pubspec.yaml`)

**Primary Dependencies**: `http` (via `DataDragonService`), `shared_preferences` (via `BuildStore` pour les builds chargées), `cached_network_image` (via `RemoteImage`). Aucune dépendance ajoutée par cette fonctionnalité.

**Storage**: aucun stockage propre. Lit le fichier embarqué `assets/data/champion_matchups.json` (via `MatchupService`) et les builds enregistrées (`BuildStore`, `shared_preferences`). L'état de la comparaison (champions, niveau, objets) n'est pas persisté.

**Testing**: `flutter_test`, données de test construites sur place, aucun appel réseau (`test/compare/`, `test/search/`, `test/champions/services/champion_filter_test.dart`, `test/shared/text/search_text_test.dart`, `test/shared/widgets/expandable_text_test.dart`, `test/matchups/matchup_service_test.dart`).

**Target Platform**: mobile et web (Flutter) ; aucune API spécifique à une plateforme.

**Project Type**: application mobile/web Flutter, projet unique.

**Performance Goals**: aucun objectif chiffré ; les fiches détaillées ne sont téléchargées qu'à la demande pour les deux champions comparés (et non pour les ~170), les objets ne le sont qu'au premier ajout.

**Constraints**: les fiches et le catalogue passent par `DataDragonService` (timeout, cache hors-ligne). La comparaison reste utilisable sans le fichier de matchups.

**Scale/Scope**: 3 écrans touchés (`ComparePage`, `SearchPage`, `ChampionsPage`) plus la fiche d'un champion et l'accueil ; 6 widgets de comparaison.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principe | Verdict | Preuve / remarque |
|----------|---------|-------------------|
| I. Organisation par fonctionnalité | Respecté | `lib/compare/{models,services,widgets/<nom>/<nom>.dart}`, `lib/search/{services}`, `lib/champions/{services,widgets}`. Un seul widget public par fichier. Les imports inter-fonctionnalités se limitent à des services, modèles ou pages (`compare_page.dart` importe `builds/services/build_store.dart`, `team/services/role_filters.dart`), jamais à des widgets internes. Le code partagé est dans `lib/shared/` (`ChampionPickerSheet`, `ItemPickerSheet`, `ExpandableText`, `normalizeSearchText`). |
| II. Données Riot via Data Dragon, erreurs affichables | Respecté | `ComparePage`, `SearchPage` utilisent `ChampionService`/`ItemService`, `userMessageFor` et `ErrorRetryView` (`lib/compare/compare_page.dart`, `lib/search/search_page.dart`). Pas de clé API. La panne du fichier de matchups est absorbée (`_loadDatasetOrEmpty`). |
| III. Images uniquement via RemoteImage | Respecté | `compare_slot.dart` (portrait), `compare_item_slots.dart` (objets), `search_page.dart` (vignettes) utilisent `RemoteImage` ; le portrait est celui de grande taille (`portraitUrl`) pour la carte large. |
| IV. Thème centralisé | Respecté | Couleurs et polices via `AppColors`, `AppTheme`. Seule exception : `Colors.transparent` dans le dégradé de `compare_slot.dart` (couleur sans valeur propre). |
| V. État simple et local | Respecté | `StatefulWidget` + `setState` partout ; état partagé des builds via `BuildStore.builds` (`ValueNotifier`). Aucun paquet d'état ajouté. Pas de contrôleur à libérer dans cette fonctionnalité (le champ de recherche de `SearchPage` n'utilise pas de `TextEditingController`). |
| VI. Tests de la logique et des widgets clés | Respecté en partie | Logique testée : `combat_stats_calculator_test.dart`, `comparison_builder_test.dart`, `champion_filter_test.dart`, `global_search_test.dart`, `search_text_test.dart`, `matchup_service_test.dart` (duel), `expandable_text_test.dart`, `champion_picker_sheet_test.dart`. Aucun test de widget pour `ComparePage`, `SearchPage`, `CompareItemSlots`, `SavedBuildPickerSheet` (voir Complexity Tracking). |
| VII. Lisibilité, français, tutoiement | Entorse | Textes en français et commentaires « pourquoi », mais plusieurs messages vouvoient (voir Complexity Tracking). |

## Project Structure

### Documentation (this feature)

```text
specs/005-recherche-et-comparaison-des-champions/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── comparison-services.md
│   └── search-and-filter.md
├── checklists/
│   └── requirements.md
└── tasks.md
```

### Source Code (repository root)

```text
lib/
├── compare/
│   ├── compare_page.dart
│   ├── models/
│   │   ├── combat_stats.dart
│   │   └── stat_comparison.dart
│   ├── services/
│   │   ├── combat_stats_calculator.dart
│   │   └── comparison_builder.dart
│   └── widgets/
│       ├── compare_item_slots/compare_item_slots.dart
│       ├── compare_level_slider/compare_level_slider.dart
│       ├── compare_slot/compare_slot.dart
│       ├── head_to_head_card/head_to_head_card.dart
│       ├── saved_build_picker_sheet/saved_build_picker_sheet.dart
│       └── stat_compare_row/stat_compare_row.dart
├── search/
│   ├── search_page.dart
│   └── services/global_search.dart
├── champions/
│   ├── champions_page.dart
│   ├── models/{champion_sort.dart, champion_stats.dart}
│   ├── services/champion_filter.dart
│   └── widgets/{champion_sort_button, region_filter_bar}/…
├── matchups/services/matchup_service.dart      # headToHead, overallFor (ajoutés ici)
├── shared/
│   ├── text/search_text.dart
│   └── widgets/{champion_picker_sheet, item_picker_sheet, expandable_text}/…
├── champion_detail/champion_detail_page.dart   # lien « Comparer », histoire repliable
└── home/{home_page.dart, widgets/home_greeting/home_greeting.dart}  # loupe vers la recherche

test/
├── compare/{combat_stats_calculator_test.dart, comparison_builder_test.dart}
├── search/global_search_test.dart
├── champions/services/champion_filter_test.dart
├── matchups/matchup_service_test.dart
└── shared/{text/search_text_test.dart, widgets/{expandable_text_test.dart, champion_picker_sheet_test.dart}}
```

**Structure Decision**: projet Flutter unique ; un dossier par fonctionnalité (`compare`, `search`) et du code partagé dans `lib/shared`. Les feuilles de choix de champion et d'objet, d'abord rangées dans `lib/compare/widgets/` et `lib/builds/widgets/`, ont été déplacées dans `lib/shared/widgets/` quand une seconde fonctionnalité en a eu besoin.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Principe VII : textes qui vouvoient (« Choisissez deux champions… », « Créez-en une depuis l'onglet Objets », « Tapez le nom… ») alors que la constitution demande le tutoiement | Aucune justification : écart de style non voulu, repéré à la rédaction de ce plan | Corriger les textes (hors périmètre d'une rédaction documentaire) ; à traiter dans une tâche de code ou à amender la constitution |
| Principe VI : pas de test de widget pour `ComparePage`, `SearchPage`, `CompareItemSlots`, `SavedBuildPickerSheet` | La logique qu'elles portent est dans des services testés ; aucun test d assemblage n existe (la constitution demande une vérification dans l application, dont il ne reste pas de trace écrite) | Écrire des tests d'écran avec des sources de données injectables ; `ComparePage` et `SearchPage` appellent directement `ChampionService`/`ItemService`, ce qui les rend difficiles à tester sans injection |
| Feuille `ChampionPickerSheet` : recherche par `toLowerCase()` et non par `normalizeSearchText` | Non voulu : l'écart avec la recherche globale est une incohérence résiduelle | Réutiliser `normalizeSearchText` dans la feuille (petite correction de code) |
