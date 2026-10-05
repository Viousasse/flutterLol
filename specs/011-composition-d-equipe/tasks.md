---
description: "Liste de tâches de la fonctionnalité 011 (rédigée après coup, tout est livré)"
---

# Tasks: Composition d'équipe

**Input**: Design documents from `/specs/011-composition-d-equipe/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: les tests sont inclus (principe VI de la constitution).

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup

- [x] T001 Créer l'arborescence `lib/team/{constants,models,services,widgets}` et `test/team/`

## Phase 2: Foundational

- [x] T002 [P] Définir les rôles et leurs voies dans `lib/team/constants/team_roles.dart`
- [x] T003 [P] Modèles `InsightKind`, `TeamInsight`, `TeamAnalysis` dans `lib/team/models/team_insight.dart`
- [x] T004 [P] Modèle `TeamMember` dans `lib/team/models/team_member.dart`
- [x] T005 [P] Repérage du contrôle par mots-clés dans `lib/team/services/crowd_control.dart`
- [x] T006 Analyse d'équipe dans `lib/team/services/team_analyzer.dart` (dépend de T003 à T005)
- [x] T007 [P] Tests de `CrowdControl` et de `TeamAnalyzer` (une équipe vide, répartition, équipe incomplète, manques de dégâts, première ligne, contrôle, précision) dans `test/team/team_analyzer_test.dart`

## Phase 3: User Story 1 - Composer une équipe (Priority: P1) MVP

**Goal**: placer, remplacer, retirer, vider.

**Independent Test**: quickstart.md, scénarios 1, 2, 7 et 8.

- [x] T008 [P] [US1] Ligne d'équipe `TeamSlot` dans `lib/team/widgets/team_slot/team_slot.dart`
- [x] T009 [US1] Écran `TeamPage` (cinq places, feuille de choix, exclusion des champions placés, croix, bouton « Vider l'équipe », erreur avec « Réessayer ») dans `lib/team/team_page.dart`
- [x] T010 [US1] Entrée « Composition » dans `lib/tools/widgets/tools_section/tools_section.dart`
- [x] T011 [P] [US1] Filtre de rôle de la feuille de choix dans `lib/team/services/role_filters.dart`
- [x] T012 [P] [US1] Tests du filtre de rôle dans `test/team/role_filters_test.dart`

## Phase 4: User Story 2 - Équilibre des dégâts (Priority: P1)

**Goal**: barre et constat sur les dégâts physiques et magiques.

**Independent Test**: quickstart.md, scénario 5.

- [x] T013 [P] [US2] Barre de répartition `DamageSplitBar` dans `lib/team/widgets/damage_split_bar/damage_split_bar.dart`
- [x] T014 [P] [US2] Constat `InsightTile` dans `lib/team/widgets/insight_tile/insight_tile.dart`
- [x] T015 [US2] Afficher la barre et les constats dans `lib/team/team_page.dart` (méthode `_analysis`)
- [x] T016 [P] [US2] Tests de la barre (pourcentages, 100 % physique, sans dégâts) et du constat (titre, message, icône) dans `test/team/team_widgets_test.dart`

## Phase 5: User Story 3 - Première ligne et contrôle (Priority: P2)

**Goal**: constats « première ligne » et « contrôle ».

**Independent Test**: quickstart.md, scénario 6.

- [x] T017 [US3] Constats de première ligne et de contrôle (avec la mention « estimation ») dans `lib/team/services/team_analyzer.dart`
- [x] T018 [P] [US3] Tests `compte la première ligne par le rôle Tank ou la défense`, `signale l absence de première ligne`, `mesure le contrôle de l équipe` dans `test/team/team_analyzer_test.dart`

## Phase 6: User Story 4 - Ne pas conclure trop tôt (Priority: P3)

**Goal**: pas de verdict sous trois champions ; précision sur les manquants.

**Independent Test**: quickstart.md, scénarios 3 et 4.

- [x] T019 [US4] Constats « Équipe incomplète » dans `lib/team/services/team_analyzer.dart`
- [x] T020 [P] [US4] Tests `invite à compléter l équipe avant de donner un avis` et `ajoute une précision tant que l équipe n est pas complète` dans `test/team/team_analyzer_test.dart`
- [x] T021 [US4] Ne pas compter dans le bilan un champion dont la fiche n'est pas arrivée, et garder les fiches téléchargées (`loadDetail`) dans `lib/team/team_page.dart`

## Phase 7: Polish

- [x] T022 [P] Libellés d'accessibilité des places et de la barre dans `lib/team/widgets/team_slot/team_slot.dart` et `lib/team/widgets/damage_split_bar/damage_split_bar.dart`
- [x] T023 Vérification manuelle des scénarios de quickstart.md
