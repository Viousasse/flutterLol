---

description: "Liste des tâches de la fonctionnalité 005 (rédigée après coup, tout est livré)"
---

# Tasks: Recherche et comparaison des champions

**Input**: Design documents from `/specs/005-recherche-et-comparaison-des-champions/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: inclus (la constitution exige des tests de la logique).

**Organization**: tâches groupées par parcours utilisateur. Commits d'origine : `033ca39` (comparaison, recherche, filtres), `32fac77` (niveau et objets), `ae4c0c2` (grilles larges), `a30c9fc` (build enregistrée).

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup (Shared Infrastructure)

- [x] T001 [P] Créer l'utilitaire de normalisation de texte dans `lib/shared/text/search_text.dart`
- [x] T002 [P] Ajouter `difficulty` à `lib/champions/models/champion.dart` et les caractéristiques de base dans `lib/champions/models/champion_stats.dart`, exposées par `lib/champions/models/champion_detail.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

- [x] T003 [P] Ajouter `headToHead` et `overallFor` dans `lib/matchups/services/matchup_service.dart` et le modèle `OverallRecord` dans `lib/matchups/models/matchup.dart`
- [x] T004 [P] Créer la feuille de choix de champion avec recherche dans `lib/shared/widgets/champion_picker_sheet/champion_picker_sheet.dart` (filtre de rôle : `champion_role_filter.dart` dans le même dossier)
- [x] T005 [P] Créer la feuille de choix d'objet dans `lib/shared/widgets/item_picker_sheet/item_picker_sheet.dart`
- [x] T006 [P] Test du duel et du bilan global dans `test/matchups/matchup_service_test.dart`
- [x] T007 [P] Test de la normalisation dans `test/shared/text/search_text_test.dart`

**Checkpoint**: les briques communes existent.

---

## Phase 3: User Story 1 - Comparer deux champions, niveau et objets compris (Priority: P1) 🎯 MVP

**Goal**: comparer deux champions à un niveau de 1 à 18 avec jusqu'à six objets chacun.

**Independent Test**: `flutter test test/compare` puis scénarios 1 à 3 de `quickstart.md`.

### Tests for User Story 1

- [x] T008 [P] [US1] Test du calcul de niveau, d'objets et des plafonds dans `test/compare/combat_stats_calculator_test.dart`
- [x] T009 [P] [US1] Test des lignes, gagnants, barres et lignes conditionnelles dans `test/compare/comparison_builder_test.dart`

### Implementation for User Story 1

- [x] T010 [P] [US1] Créer le modèle `CombatStats` dans `lib/compare/models/combat_stats.dart`
- [x] T011 [P] [US1] Créer le modèle `StatComparison` dans `lib/compare/models/stat_comparison.dart`
- [x] T012 [US1] Implémenter `CombatStatsCalculator` dans `lib/compare/services/combat_stats_calculator.dart`
- [x] T013 [US1] Implémenter `ComparisonBuilder` dans `lib/compare/services/comparison_builder.dart`
- [x] T014 [P] [US1] Créer l'emplacement de champion dans `lib/compare/widgets/compare_slot/compare_slot.dart`
- [x] T015 [P] [US1] Créer la ligne de caractéristique à barres face à face dans `lib/compare/widgets/stat_compare_row/stat_compare_row.dart`
- [x] T016 [P] [US1] Créer le curseur de niveau dans `lib/compare/widgets/compare_level_slider/compare_level_slider.dart`
- [x] T017 [P] [US1] Créer les emplacements d'objets dans `lib/compare/widgets/compare_item_slots/compare_item_slots.dart`
- [x] T018 [US1] Assembler l'écran, le chargement à la demande des fiches, l'état d'erreur et « Réessayer » dans `lib/compare/compare_page.dart`
- [x] T019 [US1] Ajouter l'entrée « Comparer » de l'onglet Outils dans `lib/tools/widgets/tools_section/tools_section.dart`

**Checkpoint**: la comparaison par niveau et avec objets fonctionne seule.

---

## Phase 4: User Story 2 - Bilan en duel et taux global (Priority: P2)

**Goal**: afficher qui l'emporte en duel et le taux de victoire global.

**Independent Test**: scénario 5 de `quickstart.md`, `flutter test test/matchups/matchup_service_test.dart`.

- [x] T020 [US2] Créer la carte « En duel » dans `lib/compare/widgets/head_to_head_card/head_to_head_card.dart`
- [x] T021 [US2] Charger le fichier de matchups sans bloquer la comparaison (`_loadDatasetOrEmpty`) dans `lib/compare/compare_page.dart`

---

## Phase 5: User Story 3 - Équiper une build enregistrée (Priority: P2)

**Goal**: remplacer les objets d'un champion par ceux d'une build enregistrée.

**Independent Test**: scénario 4 de `quickstart.md`.

- [x] T022 [P] [US3] Créer la feuille de choix de build dans `lib/compare/widgets/saved_build_picker_sheet/saved_build_picker_sheet.dart`
- [x] T023 [US3] Ajouter `loadSavedBuild` et le lien « Charger une build » dans `lib/compare/compare_page.dart`
- [x] T024 [P] [US3] Ajouter `ItemService.byIds` (objets disparus ignorés) dans `lib/items/services/item_service.dart`
- [x] T025 [P] [US3] Créer le lien d'action réutilisable dans `lib/shared/widgets/action_link/action_link.dart`

---

## Phase 6: User Story 4 - Recherche globale depuis l'accueil (Priority: P2)

**Goal**: une barre unique pour champions et objets.

**Independent Test**: `flutter test test/search`, scénario 7 de `quickstart.md`.

- [x] T026 [P] [US4] Test du classement, des accents, de la limite et de la requête vide dans `test/search/global_search_test.dart`
- [x] T027 [US4] Implémenter `GlobalSearch` dans `lib/search/services/global_search.dart`
- [x] T028 [US4] Créer `SearchPage` (invite, aucun résultat, erreur et « Réessayer ») dans `lib/search/search_page.dart`
- [x] T029 [US4] Ajouter la loupe de l'accueil dans `lib/home/widgets/home_greeting/home_greeting.dart` et la route dans `lib/home/home_page.dart`
- [x] T030 [US4] Appliquer la normalisation à la recherche d'objets dans `lib/items/items_page.dart`

---

## Phase 7: User Story 5 - Filtrer et trier la liste des champions (Priority: P3)

**Goal**: filtres nom/rôle/région et quatre tris.

**Independent Test**: `flutter test test/champions/services/champion_filter_test.dart`, scénario 8.

- [x] T031 [P] [US5] Test des filtres, des tris et de l'immutabilité dans `test/champions/services/champion_filter_test.dart`
- [x] T032 [US5] Implémenter `ChampionFilter` dans `lib/champions/services/champion_filter.dart` et `ChampionSort` dans `lib/champions/models/champion_sort.dart`
- [x] T033 [P] [US5] Créer le bouton de tri dans `lib/champions/widgets/champion_sort_button/champion_sort_button.dart`
- [x] T034 [P] [US5] Créer la barre de régions dans `lib/champions/widgets/region_filter_bar/region_filter_bar.dart`
- [x] T035 [US5] Brancher recherche, rôle, région, tri, compteur et bouton « Comparer » dans `lib/champions/champions_page.dart`
- [x] T036 [US5] Adapter la grille aux écrans larges dans `lib/champions/constants/champion_grid.dart`

---

## Phase 8: User Story 6 - Histoire repliable et lien depuis la fiche (Priority: P3)

**Goal**: relier la fiche d'un champion à la comparaison et replier l'histoire.

**Independent Test**: `flutter test test/shared/widgets/expandable_text_test.dart`, scénario 6.

- [x] T037 [P] [US6] Test du texte repliable dans `test/shared/widgets/expandable_text_test.dart`
- [x] T038 [US6] Créer `ExpandableText` dans `lib/shared/widgets/expandable_text/expandable_text.dart`
- [x] T039 [US6] Utiliser `ExpandableText` et ajouter le lien « Comparer avec un autre champion » dans `lib/champion_detail/champion_detail_page.dart`

---

## Phase N: Polish & Cross-Cutting Concerns

- [x] T040 [P] Filtre de rôle de la feuille de choix de champion dans la comparaison, via `lib/team/services/role_filters.dart` (câblé dans `lib/compare/compare_page.dart`)
- [x] T041 [P] Test du filtre de rôle de la feuille dans `test/shared/widgets/champion_picker_sheet_test.dart`
- [x] T042 Exécuter les scénarios de `specs/005-recherche-et-comparaison-des-champions/quickstart.md`

---

## Dependencies & Execution Order

- Setup → Foundational → US1 (MVP) → US2, US3, US4 (indépendantes entre elles, US2 et US3 étendent `compare_page.dart`) → US5, US6 → Polish.
- US3 dépend de la fonctionnalité `008-constructeur-de-builds` (le magasin `BuildStore`).

## Notes

- Toutes les tâches sont livrées (`[x]`) ; cette liste reconstitue le travail d'après le code et `git log`.
- Aucun test de widget n'existe pour `compare_page.dart`, `search_page.dart`, `compare_item_slots.dart` ni `saved_build_picker_sheet.dart` (voir Complexity Tracking dans `plan.md`).
