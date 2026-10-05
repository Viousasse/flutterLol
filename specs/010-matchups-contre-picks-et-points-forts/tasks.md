---
description: "Liste de tâches de la fonctionnalité 010 (rédigée après coup, tout est livré)"
---

# Tasks: Matchups, contre-picks et points forts

**Input**: Design documents from `/specs/010-matchups-contre-picks-et-points-forts/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: les tests sont inclus (principe VI de la constitution).

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup

- [x] T001 Déclarer l'asset dans `pubspec.yaml` (ligne `assets/data/champion_matchups.json`)
- [x] T002 [P] Fournir le fichier de données `assets/data/champion_matchups.json` (7 600 parties, patchs 16.16–16.19 après le commit `55b4700`)

## Phase 2: Foundational

**Purpose**: modèles, chargement et note de provenance communs aux deux écrans.

- [x] T003 [P] Modèles `Matchup`, `MatchupDataset`, `OverallRecord` dans `lib/matchups/models/matchup.dart`
- [x] T004 [P] Libellés des voies dans `lib/matchups/constants/lane_labels.dart`
- [x] T005 Chargement de l'asset en cache unique et requêtes par champion dans `lib/matchups/services/matchup_service.dart`
- [x] T006 [P] Modèle `CounterPick` avec `isReliable` et `smoothedWinRate` dans `lib/counters/models/counter_pick.dart`
- [x] T007 [P] Ligne de résultat `CounterTile` dans `lib/shared/widgets/counter_tile/counter_tile.dart`
- [x] T008 [P] Barre de voies `LaneFilterBar` dans `lib/shared/widgets/lane_filter_bar/lane_filter_bar.dart`
- [x] T009 [P] [US4] Note de provenance `DataSourceNote` dans `lib/shared/widgets/data_source_note/data_source_note.dart`
- [x] T010 [P] Tests de `MatchupService` (classements, seuils, fichier vide, bilan global, duel) dans `test/matchups/matchup_service_test.dart`
- [x] T011 [P] Test de la voie principale dans `test/matchups/main_lane_test.dart`

## Phase 3: User Story 1 - Contre-picks (Priority: P1) MVP

**Goal**: choisir un adversaire et obtenir les champions qui le battent.

**Independent Test**: quickstart.md, scénarios 1, 2 et 5.

- [x] T012 [US1] `CounterService.counters` et `lanesFor` dans `lib/counters/services/counter_service.dart`
- [x] T013 [US1] Écran `CountersPage` dans `lib/counters/counters_page.dart`
- [x] T014 [P] [US1] Tests du classement, du cumul de voies et de la limite dans `test/counters/counter_service_test.dart`
- [x] T015 [P] [US1] Tests d'écran (chargement, Réessayer, invite, liste, filtre de voie, aucun résultat) dans `test/counters/counters_page_test.dart`
- [x] T016 [P] [US1] Aides de test (faux champions, écran haut, feuille de choix) dans `test/counters/counter_pages_support.dart`

## Phase 4: User Story 2 - Toujours des propositions (Priority: P1)

**Goal**: aucune liste vide, bilans peu fiables marqués.

**Independent Test**: quickstart.md, scénario 3.

- [x] T017 [US2] Repli sur les bilans peu fiables et taux tempéré (`includeLowConfidence`, `_rank`) dans `lib/counters/services/counter_service.dart`
- [x] T018 [US2] Mention « peu de données » et phrase de prudence dans `lib/shared/widgets/counter_tile/counter_tile.dart` et `lib/counters/counters_page.dart`
- [x] T019 [P] [US2] Tests du repli, du taux tempéré et des vraies données dans `test/counters/counter_service_test.dart`
- [x] T020 [P] [US2] Tests d'écran « signale les bilans peu fiables » et « pas de mention de prudence » dans `test/counters/counters_page_test.dart`
- [x] T021 [US2] Agrandir les données à 7 600 parties dans `assets/data/champion_matchups.json` (outil `tool/generate_matchups.dart`, spécification 019)
- [x] T022 [US2] Garder la draft sans repli (`includeLowConfidence: false`) dans `lib/draft/services/draft_evaluator.dart`

## Phase 5: User Story 3 - Points forts (Priority: P2)

**Goal**: « FORT CONTRE » et « DIFFICILE CONTRE » pour mon champion.

**Independent Test**: quickstart.md, scénario 6.

- [x] T023 [US3] `strongAgainst`, `weakAgainst`, `lanesPlayedBy` dans `lib/counters/services/counter_service.dart`
- [x] T024 [US3] Écran `StrengthsPage` dans `lib/strengths/strengths_page.dart`
- [x] T025 [US3] Entrée « Points forts » dans `lib/tools/widgets/tools_section/tools_section.dart`
- [x] T026 [P] [US3] Tests du groupe « points forts » dans `test/counters/counter_service_test.dart`
- [x] T027 [P] [US3] Tests d'écran (sections, filtre, vide) dans `test/strengths/strengths_page_test.dart`

## Phase 6: User Story 4 - Provenance des données (Priority: P2)

**Goal**: même note de provenance sur chaque écran.

**Independent Test**: quickstart.md, scénario 4.

- [x] T028 [US4] Afficher `DataSourceNote` sous les résultats dans `lib/counters/counters_page.dart` et `lib/strengths/strengths_page.dart`
- [x] T029 [P] [US4] Tests de la note (plage, singulier, vide, accessibilité) dans `test/shared/widgets/data_source_note_test.dart`
- [x] T030 [P] [US4] Tests d'écran « affiche la provenance des données » dans `test/counters/counters_page_test.dart` et `test/strengths/strengths_page_test.dart`

## Phase 7: User Story 5 - Liens depuis la fiche champion (Priority: P3)

**Goal**: ouvrir les deux outils avec le champion déjà choisi.

**Independent Test**: quickstart.md, scénario 7.

- [x] T031 [US5] Liens « Contre qui est-il fort ? » et « Qui jouer contre lui ? » dans `lib/champion_detail/champion_detail_page.dart`
- [x] T032 [US5] Entrée « Contre-picks » dans `lib/tools/widgets/tools_section/tools_section.dart`
- [x] T033 [P] [US5] Test « ouvre directement l adversaire demandé par la fiche » dans `test/counters/counters_page_test.dart`

## Phase 8: Polish

- [x] T034 Sélecteurs de champion annoncés comme boutons (`Semantics`) dans `lib/counters/counters_page.dart` et `lib/strengths/strengths_page.dart`
- [x] T035 [P] Test de la section matchups de la fiche sur de vraies données dans `test/matchups/matchup_section_test.dart`
- [x] T036 Vérification manuelle des scénarios de quickstart.md
