---
description: "Liste des tâches de la fonctionnalité 016 (livrée)"
---

# Tasks: Draft à deux

**Input**: Design documents from `/specs/016-draft-a-deux/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: inclus (principe VI de la constitution).

**Organization**: tâches groupées par parcours utilisateur. Toutes sont livrées (`[x]`). Commits : `00bcf4c` (mode à deux), `b6c98aa` (noms), `0afb3b1` (soirée, score, rejeu sans score).

## Phase 1: Setup

- [x] T001 [P] Définir `DraftMode` (`vsSite`, `vsFriend`) et `friendPlayers` dans `lib/draft/models/draft_mode.dart`
- [x] T002 [P] Définir `DraftPlayers` et les champs de bilan à deux (`redStrengths`, `redImprovements`, `redBanNotes`) dans `lib/draft/models/draft_report.dart`

## Phase 2: Foundational

- [x] T003 Rendre le bilan neutre quand `players` est renseigné (noms, conseils pour chaque camp, duels retournés pour le rouge) dans `lib/draft/services/draft_evaluator.dart`
- [x] T004 [P] Test « draft à deux » (noms, conseils au perdant, points forts du bleu, duel inversé, aucun conseil rouge contre le site) dans `test/draft/draft_evaluator_test.dart`

## Phase 3: User Story 1 - Faire une draft à deux (Priority: P1) MVP

**Goal**: dix choix alternés sur un appareil, bilan neutre.

**Independent Test**: scénario 1 de `quickstart.md`.

- [x] T005 [P] [US1] Afficher « Avantage à <nom> » avec une couleur commune dans `lib/draft/widgets/criterion_tile/criterion_tile.dart`
- [x] T006 [P] [US1] Afficher un bloc de forces et de conseils par joueur dans `lib/draft/widgets/draft_report_view/draft_report_view.dart`
- [x] T007 [P] [US1] Test du bilan contre le site et à deux dans `test/draft/draft_report_view_test.dart`
- [x] T008 [US1] Ajouter le mode `vsFriend` à la page (aucun tour du site, cases actives pour le camp qui joue, statut « Au tour de … », titre « Draft à deux ») dans `lib/draft/draft_page.dart`
- [x] T009 [US1] Brancher « Draft à deux : jouer contre un ami » dans `lib/team/team_page.dart`
- [x] T010 [P] [US1] Test de bout en bout « une draft à deux se joue sans le site » dans `test/draft/draft_page_flow_test.dart`

## Phase 4: User Story 2 - Nommer les joueurs (Priority: P2)

**Goal**: noms modifiables, valides, affichés partout.

**Independent Test**: scénario 2 de `quickstart.md`.

- [x] T011 [P] [US2] Tests de `validatePlayerName` et de la boîte (nom nettoyé, nom pris, annulation) dans `test/draft/player_name_dialog_test.dart`
- [x] T012 [US2] Implémenter `validatePlayerName`, `playerNameMaxLength` et `PlayerNameDialog` dans `lib/draft/widgets/player_name_dialog/player_name_dialog.dart`
- [x] T013 [US2] Rendre le titre de colonne touchable (crayon, sémantique « Modifier le nom ») et figer les noms après le bilan dans `lib/draft/draft_page.dart`

## Phase 5: User Story 3 - Score de la soirée (Priority: P2)

**Goal**: noms et score conservés, remise à zéro confirmée.

**Independent Test**: scénario 3 de `quickstart.md`.

- [x] T014 [P] [US3] Tests du magasin (défauts, renommage, refus, victoires et égalités, remise à zéro, relecture, entrées invalides) dans `test/draft/friend_session_store_test.dart`
- [x] T015 [US3] Implémenter `FriendSession` et `FriendSessionStore` (notifier, sauvegarde, file d'écritures, relecture défensive) dans `lib/draft/services/friend_session_store.dart`
- [x] T016 [P] [US3] Tests de la barre (format, égalités au pluriel, remise à zéro, bouton désactivé, sémantique) dans `test/draft/friend_score_bar_test.dart`
- [x] T017 [US3] Implémenter `FriendScoreBar` dans `lib/draft/widgets/friend_score_bar/friend_score_bar.dart`
- [x] T018 [US3] Charger la soirée, s'abonner (`_syncPlayersWithSession`), enregistrer le résultat (`recordResult`), confirmer la remise à zéro (`confirmResetScore`) dans `lib/draft/draft_page.dart`
- [x] T019 [P] [US3] Tests de page (noms de la session, renommage, score, confirmation) dans `test/draft/draft_page_friend_session_test.dart`

## Phase 6: User Story 4 - Rejouer un duel sans toucher au score (Priority: P3)

**Goal**: le rejeu ne compte pas dans la soirée.

**Independent Test**: scénario 4 de `quickstart.md`.

- [x] T020 [US4] Reprendre mode et noms de l'enregistrement rejoué et masquer la barre en rejeu (`_usesSession`, `_initialPlayers`, `_mode`) dans `lib/draft/draft_page.dart`
- [x] T021 [P] [US4] Tests « une draft à deux normale affiche le score », « un duel rejoué n'affiche pas le score », « ne modifie pas la session » dans `test/draft/draft_page_replay_score_test.dart`
- [x] T022 [P] [US4] Test « un duel rejoué garde ses noms et n'écrit pas dans la session » dans `test/draft/draft_page_friend_session_test.dart`

## Phase 7: Polish & Cross-Cutting Concerns

- [x] T023 [P] Zone tactile de 48 px et libellé sémantique unique pour la barre de score dans `lib/draft/widgets/friend_score_bar/friend_score_bar.dart`
- [x] T024 Faire passer `flutter analyze` et `flutter test test/draft`
