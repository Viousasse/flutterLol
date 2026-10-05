---

description: "Liste des tâches livrées : filtre de rôle"
---

# Tasks: Filtre de rôle dans le choix d'un champion

**Input**: Design documents from `/specs/018-filtre-de-role/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: inclus (principe VI).

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup (Shared Infrastructure)

- [x] T001 [P] Définir les rôles et leurs voies dans `lib/team/constants/team_roles.dart`
- [x] T002 [P] Créer `LaneProfile` (parties par voie, seuils 8 parties / 15 %) dans `lib/matchups/services/lane_profile.dart` (créé à l origine dans `lib/draft/services/`, déplacé par le commit `0afb3b1`)

---

## Phase 2: Foundational (Blocking Prerequisites)

- [x] T003 Créer le modèle `ChampionRoleFilter` dans `lib/shared/widgets/champion_picker_sheet/champion_role_filter.dart`

---

## Phase 3: User Story 1 - Choisir par rôle dans la draft (Priority: P1) 🎯 MVP

**Independent Test**: quickstart 1 à 4.

### Tests for User Story 1

- [x] T004 [P] [US1] Tests de la feuille (démarre sur le rôle, « Tous », changement de puce, champion polyvalent, sans filtre) dans `test/shared/widgets/champion_picker_sheet_test.dart`

### Implementation for User Story 1

- [x] T005 [US1] Ajouter `roleFilter`, la rangée de puces défilante et le filtrage dans `lib/shared/widgets/champion_picker_sheet/champion_picker_sheet.dart`
- [x] T006 [US1] Construire le filtre (voie de la case touchée, aucun pour un bannissement) dans `lib/draft/draft_page.dart`

---

## Phase 4: User Story 2 - Combiner avec recherche et exclusions (Priority: P2)

### Tests for User Story 2

- [x] T007 [P] [US2] Tests « se combine avec la recherche » et « les champions exclus restent absents » dans `test/shared/widgets/champion_picker_sheet_test.dart`

### Implementation for User Story 2

- [x] T008 [US2] Cumuler exclusion, recherche et `fits` dans `lib/shared/widgets/champion_picker_sheet/champion_picker_sheet.dart`

---

## Phase 5: User Story 3 - Le même filtre partout (Priority: P2)

**Independent Test**: quickstart 5 et 6.

### Tests for User Story 3

- [x] T009 [P] [US3] Tests du constructeur de filtre (sans profil, ordre des rôles, voie de départ, appartenance) dans `test/team/role_filters_test.dart`

### Implementation for User Story 3

- [x] T010 [US3] Créer `RoleFilters` (`loadProfile` tolérant, `forProfile`) dans `lib/team/services/role_filters.dart`
- [x] T011 [P] [US3] Câbler le filtre dans `lib/team/team_page.dart` (avec le rang de la case)
- [x] T012 [P] [US3] Câbler le filtre dans `lib/counters/counters_page.dart`
- [x] T013 [P] [US3] Câbler le filtre dans `lib/strengths/strengths_page.dart`
- [x] T014 [P] [US3] Câbler le filtre dans `lib/compare/compare_page.dart`
- [x] T015 [P] [US3] Câbler le filtre dans `lib/builds/build_editor_page.dart` (profil chargé en arrière-plan)

---

## Phase 6: Polish & Cross-Cutting Concerns

- [x] T016 Mettre à jour les imports de `LaneProfile` dans `lib/draft/services/draft_bot.dart` et `lib/draft/services/draft_advisor.dart`
- [x] T017 Vérifier `flutter analyze` sur `lib/shared/widgets/champion_picker_sheet`, `lib/team/services`, `lib/matchups/services/lane_profile.dart`
