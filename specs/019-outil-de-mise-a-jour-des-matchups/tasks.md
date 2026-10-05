---

description: "Liste des tâches livrées : outil de mise à jour des matchups"
---

# Tasks: Outil de mise à jour des matchups

**Input**: Design documents from `/specs/019-outil-de-mise-a-jour-des-matchups/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: inclus pour la logique pure (principe VI).

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup (Shared Infrastructure)

- [x] T001 Déclarer l'asset `assets/data/champion_matchups.json` dans `pubspec.yaml`
- [x] T002 [P] Créer le modèle `MatchupDataset` / `Matchup` dans `lib/matchups/models/matchup.dart`
- [x] T003 [P] Créer le service de lecture (cache du futur, seuil de 8 parties) dans `lib/matchups/services/matchup_service.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

- [x] T004 Créer le client Riot minimal (limite de débit, reprise sur 429) dans `tool/generate_matchups.dart`
- [x] T005 [P] Tests de lecture du fichier dans `test/matchups/matchup_service_test.dart`

---

## Phase 3: User Story 1 - Générer le fichier (Priority: P1) 🎯 MVP

**Independent Test**: quickstart 1 et 2.

- [x] T006 [US1] Lecture du classement Master, collecte des parties, comptage par voie, alias de noms et rendu JSON dans `tool/generate_matchups.dart`
- [x] T007 [US1] Premier calcul réel (2 500 parties, patch 16.18) dans `assets/data/champion_matchups.json` (commit `d26e563`)
- [x] T008 [P] [US1] Section de contre-picks de la fiche champion dans `lib/champion_detail/widgets/matchup_section/matchup_section.dart`
- [x] T009 [P] [US1] Test de la section avec le vrai fichier dans `test/matchups/matchup_section_test.dart`

---

## Phase 4: User Story 2 - Reprendre un long calcul (Priority: P1)

**Independent Test**: quickstart 3.

- [x] T010 [US2] Progression sauvegardée toutes les 100 parties, écriture atomique, option `--resume` et `--output` dans `tool/generate_matchups.dart`
- [x] T011 [US2] Ignorer les parties 404 et sauvegarder avant de relancer toute autre erreur HTTP dans `tool/generate_matchups.dart`

---

## Phase 5: User Story 3 - Mise à jour par patch (Priority: P2)

**Independent Test**: tests de `test/tool/matchup_tally_test.dart` ; quickstart 4 et 5.

- [x] T012 [P] [US3] Créer la logique pure (`Tally`, `parsePatch`, `comparePatches`, `isBeforePatch`, `decayTally`, `decayPatches`, `mergeTally`, `mergePatches`, `patchRange`) dans `tool/matchup_tally.dart`
- [x] T013 [P] [US3] Tests de la logique pure dans `test/tool/matchup_tally_test.dart`
- [x] T014 [US3] Options `--merge-with`, `--decay`, `--min-patch`, validation des arguments, champ `patches` et plage de patch dans `tool/generate_matchups.dart`
- [x] T015 [US3] Test « MatchupDataset ignore le champ informatif patches » dans `test/tool/matchup_tally_test.dart`
- [x] T016 [US3] Rédiger le guide d'exploitation dans `tool/README.md`

---

## Phase 6: User Story 4 - Données plus fiables (Priority: P2)

**Independent Test**: `flutter test test/counters/counter_service_test.dart`.

- [x] T017 [US4] Régénérer le fichier à 7 600 parties, patchs 16.16 à 16.19, dans `assets/data/champion_matchups.json` (commit `55b4700`)
- [x] T018 [P] [US4] Test « chaque champion des vraies données reçoit des contre-picks » et « a des points forts » dans `test/counters/counter_service_test.dart`
- [x] T019 [P] [US4] Test du quiz sur le vrai fichier dans `test/quiz/quiz_generator_test.dart`

---

## Phase 7: Polish & Cross-Cutting Concerns

- [x] T020 Vérifier qu'aucune clé Riot réelle n'est écrite dans le code, le guide ou les données (`tool/README.md`, `tool/generate_matchups.dart`)
- [x] T021 Afficher la provenance des données (patch ou plage) dans `lib/shared/widgets/data_source_note/data_source_note.dart`

## Dependencies & Execution Order

T004 avant T006. T010 et T014 modifient le même fichier : à faire dans l'ordre. T017 suppose T006 à T014.
