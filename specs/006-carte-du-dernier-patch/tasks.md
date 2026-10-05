---

description: "Liste des tâches de la fonctionnalité 006 (rédigée après coup, tout est livré)"
---

# Tasks: Carte du dernier patch sur l'accueil

**Input**: Design documents from `/specs/006-carte-du-dernier-patch/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: inclus (la constitution exige des tests de la logique).

**Organization**: une seule histoire (P1) et un parcours de repli (P2). Commit d'origine : `e973e19`.

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup (Shared Infrastructure)

- [x] T001 Ajouter la dépendance `url_launcher` dans `pubspec.yaml` (et mettre à jour `pubspec.lock`)

---

## Phase 2: Foundational (Blocking Prerequisites)

- [x] T002 [P] Créer le modèle `PatchNotes` et `fromVersion` dans `lib/patch_notes/models/patch_notes.dart`
- [x] T003 [P] Test de déduction du patch (nominal, sans correctif, illisible) dans `test/patch_notes/patch_notes_test.dart`

**Checkpoint**: le numéro et l'adresse se calculent et sont testés.

---

## Phase 3: User Story 1 - Accéder aux notes du dernier patch (Priority: P1) 🎯 MVP

**Goal**: une carte d'accueil qui ouvre les notes officielles.

**Independent Test**: scénarios 1 à 3 de `quickstart.md`.

- [x] T004 [US1] Créer la carte avec ouverture externe, message d'échec et sémantique dans `lib/home/widgets/patch_notes_card/patch_notes_card.dart`
- [x] T005 [US1] Insérer la carte sous le champion du jour dans `lib/home/home_page.dart`

**Checkpoint**: la carte fonctionne seule.

---

## Phase 4: User Story 2 - L'accueil reste complet sans la carte (Priority: P2)

**Goal**: une panne de version n'altère pas l'accueil.

**Independent Test**: scénario 4 de `quickstart.md`, `flutter test test/patch_notes`.

- [x] T006 [US2] Charger la version en parallèle de l'accueil, ignorer l'échec et omettre la carte (`loadPatchNotes`) dans `lib/home/home_page.dart`
- [x] T007 [P] [US2] Mémoriser la version en cours de chargement (`latestVersion`) dans `lib/data_dragon/data_dragon_service.dart` (existant, réutilisé)

---

## Phase N: Polish & Cross-Cutting Concerns

- [x] T008 [P] Mettre à jour les fichiers de plugins générés des plateformes : `linux/flutter/generated_plugins.cmake`, `macos/Flutter/GeneratedPluginRegistrant.swift`, `windows/flutter/generated_plugins.cmake`
- [x] T009 Exécuter les scénarios de `specs/006-carte-du-dernier-patch/quickstart.md`

---

## Dependencies & Execution Order

- T001 → T002 → T004 → T005 → T006 ; T003 en parallèle de T004.

## Notes

- Toutes les tâches sont livrées (`[x]`) ; liste reconstituée d'après le code et `git log`.
- Aucune tâche de test de widget n'existe (voir Complexity Tracking dans `plan.md`).
