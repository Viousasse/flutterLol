---
description: "Liste de tâches de la fonctionnalité 009 (rédigée après coup, tout est livré)"
---

# Tasks: Grilles adaptées aux écrans larges

**Input**: Design documents from `/specs/009-grilles-adaptees-aux-ecrans-larges/`

**Prerequisites**: plan.md, spec.md, research.md, contracts/

**Tests**: aucun test automatisé n'a été écrit pour cette fonctionnalité (voir plan.md, Complexity Tracking).

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup

- [x] T001 Relever le défaut sur la capture (cartes d'objets étirées) dans `lib/items/items_page.dart` et `lib/champions/champions_page.dart`

## Phase 2: Foundational

- [x] T002 [P] Créer `championGridDelegate` dans `lib/champions/constants/champion_grid.dart`
- [x] T003 [P] Créer `itemGridDelegate(context)` dans `lib/items/constants/item_grid.dart`

## Phase 3: User Story 1 - Cartes d'objets raisonnables (Priority: P1) MVP

**Goal**: cartes d'objets de 130 px au plus, hauteur fixe suivant l'échelle de texte.

**Independent Test**: voir quickstart.md, étapes 2 à 4.

- [x] T004 [US1] Remplacer la grille à 3 colonnes par `itemGridDelegate(context)` dans `lib/items/items_page.dart`

## Phase 4: User Story 2 - Cartes de champions raisonnables (Priority: P2)

**Goal**: cartes de champions de 220 px au plus.

**Independent Test**: voir quickstart.md, étape 5.

- [x] T005 [US2] Remplacer la grille à 2 colonnes par `championGridDelegate` dans `lib/champions/champions_page.dart`

## Phase 5: User Story 3 - Favoris (Priority: P3)

**Goal**: mêmes grilles dans la page Favoris.

**Independent Test**: voir quickstart.md, étape 6.

- [x] T006 [P] [US3] Utiliser `championGridDelegate` dans `lib/favorites/widgets/favorite_champions_tab/favorite_champions_tab.dart`
- [x] T007 [P] [US3] Utiliser `itemGridDelegate(context)` dans `lib/favorites/widgets/favorite_items_tab/favorite_items_tab.dart`

## Phase 6: Polish

- [x] T008 Vérifier à la main en fenêtre large et à 360 px (quickstart.md, étapes 1 à 6) ; aucun fichier de test créé (écart consigné dans plan.md)
