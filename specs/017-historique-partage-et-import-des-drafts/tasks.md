---

description: "Liste des tâches livrées : historique, partage et import des drafts"
---

# Tasks: Historique, partage et import des drafts

**Input**: Design documents from `/specs/017-historique-partage-et-import-des-drafts/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: inclus (principe VI de la constitution).

**Organization**: tâches groupées par parcours utilisateur. Tout est livré (commits `57ca610` puis `0afb3b1`).

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup (Shared Infrastructure)

- [x] T001 [P] Écrire le service de copie avec message d'échec dans `lib/shared/services/clipboard_copy/clipboard_copy.dart`
- [x] T002 [P] Écrire l'enveloppe commune des codes de partage (préfixe + base64url) dans `lib/shared/services/share_code/share_code.dart`
- [x] T003 [P] Écrire la boîte générique de collage de code dans `lib/shared/widgets/paste_code_dialog/paste_code_dialog.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

- [x] T004 Créer le modèle `DraftRecord` (sérialisation, `tryFromJson` tolérant, `assisted`, `imported`) dans `lib/draft/models/draft_record.dart`
- [x] T005 Créer `DraftHistoryStore` (ValueNotifier, 50 entrées, file d'écritures, `reset()` de test) dans `lib/draft/services/draft_history_store.dart`
- [x] T006 Tests du modèle et du stockage dans `test/draft/draft_history_test.dart` (groupes `DraftRecord`, `DraftHistoryStore`)
- [x] T007 [P] Fabrique de données de test partagée dans `test/draft/draft_support.dart`

**Checkpoint**: une draft se garde et se relit.

---

## Phase 3: User Story 1 - Retrouver mes drafts et mon bilan (Priority: P1) 🎯 MVP

**Goal**: enregistrer automatiquement, lister, supprimer, vider, bilan.

**Independent Test**: jouer une draft, ouvrir l'historique (quickstart 1 à 4).

### Tests for User Story 1

- [x] T008 [P] [US1] Tests des statistiques (taux, égalités, champions les plus choisis) dans `test/draft/draft_history_test.dart` (groupe `DraftHistoryStats`)
- [x] T009 [P] [US1] Tests de `DraftStatsCard` et `DraftHistoryTile` dans `test/draft/draft_history_widgets_test.dart`

### Implementation for User Story 1

- [x] T010 [P] [US1] Créer le calcul `DraftHistoryStats` dans `lib/draft/services/draft_history_stats.dart`
- [x] T011 [P] [US1] Créer la tuile `DraftHistoryTile` (libellé sémantique unique, partage, suppression) dans `lib/draft/widgets/draft_history_tile/draft_history_tile.dart`
- [x] T012 [P] [US1] Créer le bilan `DraftStatsCard` dans `lib/draft/widgets/draft_stats_card/draft_stats_card.dart`
- [x] T013 [US1] Créer `DraftHistoryPage` (chargement, erreur + « Réessayer », vide, confirmations de suppression) dans `lib/draft/draft_history_page.dart`
- [x] T014 [US1] Enregistrer la draft dès que le bilan est établi dans `lib/draft/draft_page.dart`
- [x] T015 [US1] Ajouter l'accès à l'historique depuis `lib/draft/draft_page.dart` (icône horloge) et `lib/team/team_page.dart` (lien « Historique des drafts »)

**Checkpoint**: parcours 1 fonctionnel.

---

## Phase 4: User Story 2 - Détail et rejeu (Priority: P2)

**Goal**: page de détail et « Rejouer avec les mêmes bannissements ».

**Independent Test**: quickstart 5.

### Tests for User Story 2

- [x] T016 [P] [US2] Tests de la page de détail dans `test/draft/draft_record_page_test.dart`
- [x] T017 [P] [US2] Tests du rejeu (bans posés, ban introuvable, mode à deux, « Refaire une draft », nouvelle entrée) dans `test/draft/draft_page_replay_test.dart`

### Implementation for User Story 2

- [x] T018 [US2] Créer `DraftRecordPage` dans `lib/draft/draft_record_page.dart`
- [x] T019 [US2] Ajouter `DraftPage(replayOf:)` (pose des bans dans l'ordre, mode et noms repris) dans `lib/draft/draft_page.dart`
- [x] T020 [US2] Brancher `onTap` de la tuile sur la page de détail dans `lib/draft/draft_history_page.dart`

---

## Phase 5: User Story 3 - Partage texte et code (Priority: P2)

**Goal**: résumé texte finissant par `Code : LOLD1.…`.

**Independent Test**: quickstart 6.

### Tests for User Story 3

- [x] T021 [P] [US3] Tests du résumé (groupe `DraftShareText`) dans `test/draft/draft_history_test.dart`
- [x] T022 [P] [US3] Tests du code (aller-retour, noyé dans un message, tronqué, bornes, champs inconnus) dans `test/draft/draft_share_code_test.dart`

### Implementation for User Story 3

- [x] T023 [P] [US3] Créer `DraftShareText` dans `lib/draft/services/draft_share_text.dart`
- [x] T024 [US3] Créer `DraftShareCode` (encodage, décodage, garde-fous, identifiant neuf) dans `lib/draft/services/draft_share_code.dart`
- [x] T025 [US3] Brancher « Copier le résumé » dans la tuile (`lib/draft/draft_history_page.dart`), la page de détail (`lib/draft/draft_record_page.dart`) et le bilan (`lib/draft/draft_page.dart`)

---

## Phase 6: User Story 4 - Importer la draft d'un ami (Priority: P3)

**Independent Test**: quickstart 7 et 8.

### Tests for User Story 4

- [x] T026 [P] [US4] Tests de la boîte d'import dans `test/shared/widgets/paste_code_dialog_test.dart`
- [x] T027 [P] [US4] Tests de l'import dans l'historique (une seule fois, texte sans code) dans `test/draft/draft_import_test.dart`

### Implementation for User Story 4

- [x] T028 [US4] Ajouter l'action « Importer une draft », la détection de doublon et les messages dans `lib/draft/draft_history_page.dart`

---

## Phase 7: User Story 5 - Bilan honnête (Priority: P3)

**Independent Test**: quickstart 2 ; tests `assisted` et `imported`.

- [x] T029 [P] [US5] Tests « les drafts avec aide sortent du taux » et « drafts importées » dans `test/draft/draft_history_test.dart`
- [x] T030 [P] [US5] Tests du bilan avec aide / importées dans `test/draft/draft_history_widgets_test.dart`
- [x] T031 [US5] Marqueurs `assisted` et `imported` dans `lib/draft/models/draft_record.dart`, comptage dans `lib/draft/services/draft_history_stats.dart`, étiquettes dans `lib/draft/widgets/draft_history_tile/draft_history_tile.dart` et `lib/draft/widgets/draft_stats_card/draft_stats_card.dart`

---

## Phase 8: Polish & Cross-Cutting Concerns

- [x] T032 [P] Tests du code avec `assisted`/`imported` et ancien code sans `a` dans `test/draft/draft_share_code_test.dart`
- [x] T033 Vérifier `flutter analyze` sur `lib/draft`, `lib/shared/services/share_code`, `lib/shared/widgets/paste_code_dialog`

## Dependencies & Execution Order

- Phase 2 bloque toutes les histoires. US2, US3 dépendent de US1. US4 dépend de US3 (le code à lire). US5 s'appuie sur US1.
