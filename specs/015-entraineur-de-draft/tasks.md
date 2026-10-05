---
description: "Liste des tâches de la fonctionnalité 015 (livrée)"
---

# Tasks: Entraîneur de draft

**Input**: Design documents from `/specs/015-entraineur-de-draft/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: inclus (principe VI de la constitution).

**Organization**: tâches groupées par parcours utilisateur. Toutes sont livrées (`[x]`). Commits : `d260ea6` (entraîneur), `57ca610` (bannissements), `23ea5c6` (filtre de rôle, spec 018), `a0cec9e` (analyse des bannissements, test de bout en bout), `0afb3b1` (conseils).

## Phase 1: Setup

- [x] T001 Créer `lib/draft/{models,services,widgets}/` et `test/draft/`
- [x] T002 [P] Écrire les fabriques de test (champions, fiches, matchups) dans `test/draft/draft_support.dart`
- [x] T003 [P] Déplacer `LaneProfile` dans `lib/matchups/services/lane_profile.dart` (partagé avec d'autres écrans)

## Phase 2: Foundational

- [x] T004 Définir `DraftSide`, `draftPickOrder`, `draftBanOrder`, `bansPerSide` et l'état immuable `DraftState` (choix, bans, refus des coups illégaux) dans `lib/draft/models/draft_state.dart`
- [x] T005 [P] Définir `DraftWinner`, `DraftCriterion`, `DraftPlayers`, `DraftReport` dans `lib/draft/models/draft_report.dart`
- [x] T006 [P] Définir `DraftMode` dans `lib/draft/models/draft_mode.dart`
- [x] T007 [P] Tests de l'ordre et de l'immuabilité de l'état dans `test/draft/draft_state_test.dart`
- [x] T008 [P] Tests des bannissements (alternance, refus, immuabilité) dans `test/draft/draft_ban_test.dart`

## Phase 3: User Story 1 - Faire une draft contre le site (Priority: P1) MVP

**Goal**: jouer dix choix contre un site qui répond.

**Independent Test**: scénario 2 de `quickstart.md`, `test/draft/draft_page_flow_test.dart`.

- [x] T009 [P] [US1] Tests du site (poste, doublons, contre de rôle, repli) dans `test/draft/draft_bot_test.dart`
- [x] T010 [US1] Implémenter `DraftBot.choose` et `LaneProfile` utilisé dans `lib/draft/services/draft_bot.dart`
- [x] T011 [P] [US1] Créer la case de rôle `DraftSlot` dans `lib/draft/widgets/draft_slot/draft_slot.dart`
- [x] T012 [US1] Écrire `DraftPage` (chargement, statut, tour du site avec attente, grille, « Recommencer ») dans `lib/draft/draft_page.dart`
- [x] T013 [US1] Brancher « Entraîneur de draft : jouer contre le site » dans `lib/team/team_page.dart`

## Phase 4: User Story 2 - Comprendre quelle draft est meilleure (Priority: P1)

**Goal**: bilan à cinq critères, verdict, forces et conseils.

**Independent Test**: scénario 3 de `quickstart.md`.

- [x] T014 [P] [US2] Tests du bilan (critères, tolérances, verdict, contre-pick libre, message de repli) dans `test/draft/draft_evaluator_test.dart`
- [x] T015 [US2] Implémenter `DraftEvaluator` dans `lib/draft/services/draft_evaluator.dart`
- [x] T016 [P] [US2] Créer `CriterionTile` dans `lib/draft/widgets/criterion_tile/criterion_tile.dart`
- [x] T017 [US2] Créer `DraftReportView` dans `lib/draft/widgets/draft_report_view/draft_report_view.dart`
- [x] T018 [P] [US2] Test du bilan contre le site dans `test/draft/draft_report_view_test.dart`
- [x] T019 [US2] Afficher analyse, erreur avec « Réessayer », bilan, note de source et « Refaire une draft » dans `lib/draft/draft_page.dart`

## Phase 5: User Story 3 - Jouer avec des bannissements (Priority: P2)

**Goal**: phase de bannissements avant les choix.

**Independent Test**: scénario 1 de `quickstart.md`.

- [x] T020 [P] [US3] Test du site qui bannit (libre, fort et très joué, jamais un banni) dans `test/draft/draft_ban_test.dart`
- [x] T021 [US3] Implémenter `DraftBot.chooseBan` dans `lib/draft/services/draft_bot.dart`
- [x] T022 [P] [US3] Créer la rangée `BanRow` dans `lib/draft/widgets/ban_row/ban_row.dart`
- [x] T023 [US3] Ajouter l'interrupteur « Bannissements », la phase de bannissements et la feuille de ban dans `lib/draft/draft_page.dart`
- [x] T024 [US3] Brancher la feuille de choix filtrée par rôle (`_roleFilter`, filtre décrit par la spec 018) dans `lib/draft/draft_page.dart`

## Phase 6: User Story 4 - Savoir si ses bannissements ont servi (Priority: P2)

**Goal**: remarques sur les bannissements dans le bilan.

**Independent Test**: `test/draft/ban_analyzer_test.dart`, `test/draft/draft_page_flow_test.dart`.

- [x] T025 [P] [US4] Tests de l'analyse des bans et de leur présence dans le bilan dans `test/draft/ban_analyzer_test.dart`
- [x] T026 [US4] Implémenter `BanAnalyzer` dans `lib/draft/services/ban_analyzer.dart`
- [x] T027 [US4] Relier `BanAnalyzer` au bilan (`banNotes`, `redBanNotes`) dans `lib/draft/services/draft_evaluator.dart` et `lib/draft/models/draft_report.dart`
- [x] T028 [US4] Afficher la section « BANNISSEMENTS » dans `lib/draft/widgets/draft_report_view/draft_report_view.dart`
- [x] T029 [P] [US4] Test de bout en bout d'une draft (avec et sans bans, « Refaire une draft », historique) dans `test/draft/draft_page_flow_test.dart`

## Phase 7: User Story 5 - Aide au choix (Priority: P3)

**Goal**: trois conseils motivés au tour du joueur.

**Independent Test**: scénario 4 de `quickstart.md`.

- [x] T030 [P] [US5] Tests du conseiller (déterminisme, diversité, honnêteté, nombre) dans `test/draft/draft_advisor_test.dart`
- [x] T031 [US5] Implémenter `DraftAdvisor` et exposer `DraftBot.needBonusFor` / `needsFilledBy` dans `lib/draft/services/draft_advisor.dart` et `lib/draft/services/draft_bot.dart`
- [x] T032 [P] [US5] Créer `SuggestionCard` dans `lib/draft/widgets/suggestion_card/suggestion_card.dart`
- [x] T033 [P] [US5] Tests de la carte (contenu, tap, libellé sémantique) dans `test/draft/suggestion_card_test.dart`
- [x] T034 [US5] Ajouter l'interrupteur « Aide au choix », le panneau SUGGESTIONS, `playSuggestion` et le marquage `assisted` dans `lib/draft/draft_page.dart`
- [x] T035 [P] [US5] Tests d'écran de l'aide (visibilité, tour, jeu d'une carte, marquage) dans `test/draft/draft_page_advice_test.dart`

## Phase 8: Polish & Cross-Cutting Concerns

- [x] T036 [P] Garantir des conseils de contre-pick fiables (`includeLowConfidence: false`) dans `lib/draft/services/draft_evaluator.dart`
- [x] T037 [P] Annoncer les titres du bilan et des suggestions comme en-têtes et le statut comme zone vive dans `lib/draft/widgets/draft_report_view/draft_report_view.dart` et `lib/draft/draft_page.dart`
- [x] T038 [P] Test d'accessibilité des titres du bilan dans `test/draft/draft_a11y_test.dart`
- [x] T039 Faire passer `flutter analyze` et `flutter test test/draft`
