---

description: "Liste des tâches de la fonctionnalité 002, rédigée après coup d'après le code livré"
---

# Tasks: Données hors ligne

**Input**: Design documents from `/specs/002-donnees-hors-ligne/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: inclus (livrés avec le code).

**Organization**: groupé par parcours. Commits : `284ebd7` (US1) puis `0afb3b1` (US2, US3, US4).

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup (Shared Infrastructure)

- [x] T001 Vérifier que `http` et `shared_preferences` sont déclarés dans `pubspec.yaml`
- [x] T002 [P] Créer l'exception à message affichable dans `lib/data_dragon/data_dragon_exception.dart` (existait avant la fonctionnalité)

---

## Phase 2: Foundational (Blocking Prerequisites)

- [x] T003 Créer `OfflineJsonCache` (`write`, `read`, préfixe `ddragon_offline_`) dans `lib/data_dragon/offline_json_cache.dart`
- [x] T004 Séparer `fetchJson` en `_download` et `_decode` dans `lib/data_dragon/data_dragon_service.dart`

**Checkpoint**: le service sait télécharger, décoder et lire/écrire une copie.

---

## Phase 3: User Story 1 - Ouvrir l'application sans connexion (Priority: P1) 🎯 MVP

**Goal**: resservir le dernier document reçu quand Riot est injoignable.

**Independent Test**: `flutter test test/data_dragon/data_dragon_service_test.dart`

### Tests for User Story 1

- [x] T005 [P] [US1] Tests `resert la derniere copie…`, `sans copie enregistree…`, `sans offlineKey…` dans `test/data_dragon/data_dragon_service_test.dart`

### Implementation for User Story 1

- [x] T006 [US1] Ajouter le paramètre `offlineKey` à `fetchJson` et le repli sur la copie dans `lib/data_dragon/data_dragon_service.dart`
- [x] T007 [P] [US1] Demander la copie `versions` dans `DataDragonService._fetchLatestVersion` (`lib/data_dragon/data_dragon_service.dart`)
- [x] T008 [P] [US1] Demander la copie `champions` dans `lib/champions/services/champion_service.dart`
- [x] T009 [P] [US1] Demander la copie `items` dans `lib/items/services/item_service.dart`
- [x] T010 [P] [US1] Demander la copie `runes` dans `lib/runes/services/rune_service.dart`
- [x] T011 [P] [US1] Demander la copie `summoners` dans `lib/summoner_spells/services/summoner_spell_service.dart`

**Checkpoint**: l'application s'ouvre hors ligne après un premier lancement.

---

## Phase 4: User Story 2 - Fiches de champions hors ligne (Priority: P2)

**Goal**: fiches consultées lisibles hors ligne, bornées à 12.

**Independent Test**: `flutter test test/champions/services/champion_service_offline_test.dart`

### Tests for User Story 2

- [x] T012 [P] [US2] Test des fiches vue et jamais vue dans `test/champions/services/champion_service_offline_test.dart`
- [x] T013 [P] [US2] Test `offlineKeepLast efface les copies les plus anciennes` dans `test/data_dragon/data_dragon_service_test.dart`

### Implementation for User Story 2

- [x] T014 [US2] Ajouter `keepLast` et la liste d'ancienneté `ddragon_recent_<famille>` dans `lib/data_dragon/offline_json_cache.dart`
- [x] T015 [US2] Ajouter `offlineKeepLast` à `fetchJson` dans `lib/data_dragon/data_dragon_service.dart`
- [x] T016 [US2] Mettre en copie `fetchDetail` (`champion:<id>`, constante `_detailCopiesKept = 12`) dans `lib/champions/services/champion_service.dart`

---

## Phase 5: User Story 3 - Une copie fiable (Priority: P2)

**Goal**: une réponse de mauvaise forme ou une copie illisible ne casse rien.

**Independent Test**: tests `un JSON de mauvaise forme…`, `un corps illisible…`, `une copie corrompue…`.

### Tests for User Story 3

- [x] T017 [P] [US3] Tests de forme et de copie corrompue dans `test/data_dragon/data_dragon_service_test.dart`
- [x] T018 [P] [US3] Test `la version est resservie hors ligne, et un echec se retente` dans `test/data_dragon/data_dragon_service_test.dart`

### Implementation for User Story 3

- [x] T019 [US3] Ajouter le paramètre `isValid` et `hasDataMap` à `lib/data_dragon/data_dragon_service.dart`
- [x] T020 [US3] Relancer la panne d'origine quand la copie est illisible ou invalide dans `lib/data_dragon/data_dragon_service.dart`
- [x] T021 [P] [US3] Brancher `isValid` dans `lib/champions/services/champion_service.dart`, `lib/items/services/item_service.dart`, `lib/summoner_spells/services/summoner_spell_service.dart` (`hasDataMap`) et `lib/runes/services/rune_service.dart` (liste)

---

## Phase 6: User Story 4 - « Réessayer » sur la page de la carte (Priority: P3)

**Goal**: ne plus laisser la carte sans issue.

**Independent Test**: `flutter test test/map/map_page_retry_test.dart`

- [x] T022 [P] [US4] Test `échec puis succès : Réessayer relance le chargement` dans `test/map/map_page_retry_test.dart`
- [x] T023 [US4] Rendre `loadVersion` injectable, recréer le futur au retry et afficher `ErrorRetryView` dans `lib/map/map_page.dart`

---

## Phase N: Polish & Cross-Cutting Concerns

- [x] T024 [P] Consigner l'audit dans `docs/agents/reports/offline-audit.md`
- [x] T025 Passer `flutter analyze` sur `lib/data_dragon`, `lib/champions/services` et `lib/map/map_page.dart`

---

## Dependencies & Execution Order

- T003 et T004 précèdent T006 ; T006 précède T007 à T011.
- T014 précède T015 ; T015 précède T016.
- T019 précède T020 et T021.
- US2, US3, US4 dépendent de US1 ; elles sont indépendantes entre elles.
