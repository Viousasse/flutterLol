---

description: "Liste des tâches de la fonctionnalité 007 (rédigée après coup, tout est livré)"
---

# Tasks: Galerie des apparences d'un champion

**Input**: Design documents from `/specs/007-galerie-des-apparences/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: inclus (la constitution exige des tests de la logique).

**Organization**: commit d'origine `400a75c`.

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup (Shared Infrastructure)

- [x] T001 Aucune dépendance ni structure à ajouter : réutilise `lib/shared/widgets/remote_image/remote_image.dart` et `lib/champions/services/champion_service.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

- [x] T002 [P] Créer le modèle `ChampionSkin` (lecture, chromas écartés, adresses) dans `lib/champions/models/champion_skin.dart`
- [x] T003 [P] Test du modèle (chromas, nom d'origine, adresses, liste absente) dans `test/champions/models/champion_skin_test.dart`
- [x] T004 Ajouter le champ `skins` à `lib/champions/models/champion_detail.dart`

**Checkpoint**: les apparences se lisent et se testent.

---

## Phase 3: User Story 1 - Parcourir les apparences (Priority: P1) 🎯 MVP

**Goal**: galerie horizontale sur la fiche du champion.

**Independent Test**: scénarios 1 et 5 de `quickstart.md`.

- [x] T005 [US1] Créer la galerie à vignettes sémantiques dans `lib/champion_detail/widgets/skin_gallery/skin_gallery.dart`
- [x] T006 [US1] Ajouter la section « Apparences (n) » (masquée à une seule apparence) dans `lib/champion_detail/champion_detail_page.dart`

---

## Phase 4: User Story 2 - Plein écran et navigation (Priority: P2)

**Goal**: voir une apparence en grand et naviguer.

**Independent Test**: scénarios 2 à 4 de `quickstart.md`.

- [x] T007 [US2] Créer le visualiseur (PageView, flèches, zoom, titre, nom, libération du contrôleur) dans `lib/champion_detail/skin_viewer_page.dart`
- [x] T008 [US2] Ouvrir le visualiseur depuis la vignette dans `lib/champion_detail/widgets/skin_gallery/skin_gallery.dart`

---

## Phase N: Polish & Cross-Cutting Concerns

- [x] T009 Fixer en blanc les textes et icônes du visualiseur (fond noir) pour qu un thème clair ne les rende pas illisibles : commit `15d9e51`, `lib/champion_detail/skin_viewer_page.dart`
- [x] T010 Exécuter les scénarios de `specs/007-galerie-des-apparences/quickstart.md`

---

## Dependencies & Execution Order

- T002 → T004 → T005 → T006 → T007 → T008.

## Notes

- Toutes les tâches sont livrées (`[x]`) ; liste reconstituée d'après le code et `git log`.
- La moitié « constructeur de build » de la demande est décrite dans `specs/008-constructeur-de-builds`.
