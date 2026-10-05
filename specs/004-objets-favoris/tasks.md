---

description: "Liste des tâches de la fonctionnalité 004, rédigée après coup d'après le code livré"
---

# Tasks: Objets favoris

**Input**: Design documents from `/specs/004-objets-favoris/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: inclus pour les services ; aucun test de widget n'a été écrit.

**Organization**: groupé par parcours. Commit : `993ab50` (contexte : `d7c57fe`, favoris de champions en source unique, avant cette fonctionnalité).

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup (Shared Infrastructure)

- [x] T001 Vérifier que `shared_preferences` est déclaré dans `pubspec.yaml` (aucune dépendance ajoutée)

---

## Phase 2: Foundational (Blocking Prerequisites)

- [x] T002 Extraire le mécanisme des favoris dans `lib/shared/services/favorite_ids_store/favorite_ids_store.dart` (notifieur, chargement partagé, bascule, file d'écriture)
- [x] T003 Réduire `FavoritesService` à une façade du magasin (clé `favorite_champions`) dans `lib/champions/services/favorites_service.dart`
- [x] T004 [P] Créer `ItemFavoritesService` (clé `favorite_items`) dans `lib/items/services/item_favorites_service.dart`
- [x] T005 [P] Test de non-régression des favoris de champions dans `test/champions/services/favorites_service_test.dart`

**Checkpoint**: les deux jeux de favoris existent, indépendants.

---

## Phase 3: User Story 1 - Mettre un objet en favori depuis sa fiche (Priority: P1) 🎯 MVP

**Goal**: étoile sur la fiche et sur la carte d'objet.

**Independent Test**: quickstart.md, étapes 1 et 2.

### Tests for User Story 1

- [x] T006 [P] [US1] Test des objets favoris (bascule, séparation d'avec les champions) dans `test/items/services/item_favorites_service_test.dart`

### Implementation for User Story 1

- [x] T007 [P] [US1] Ajouter le bouton étoile (info-bulle selon l'état) dans `lib/items/widgets/item_detail_sheet/item_detail_header.dart`
- [x] T008 [P] [US1] Ajouter la petite étoile à côté du prix dans `lib/items/widgets/item_card/item_card.dart`

---

## Phase 4: User Story 2 - Retrouver ses objets favoris (Priority: P1)

**Goal**: onglet « Objets » dans la page « Favoris ».

**Independent Test**: quickstart.md, étapes 3 à 5 et 8.

- [x] T009 [P] [US2] Déplacer la liste des champions favoris dans `lib/favorites/widgets/favorite_champions_tab/favorite_champions_tab.dart`
- [x] T010 [P] [US2] Créer l'onglet des objets favoris (grille, vide, erreur, Réessayer) dans `lib/favorites/widgets/favorite_items_tab/favorite_items_tab.dart`
- [x] T011 [US2] Passer `FavoritesPage` à deux onglets « Champions » et « Objets » dans `lib/favorites/favorites_page.dart`

---

## Phase 5: User Story 3 - Des favoris qui survivent et ne se mélangent pas (Priority: P2)

**Goal**: relecture avant le premier rendu.

**Independent Test**: quickstart.md, étapes 6 et 7.

- [x] T012 [US3] Relire les favoris d'objets en même temps que ceux des champions avant `runApp` dans `lib/main.dart`

---

## Phase N: Polish & Cross-Cutting Concerns

- [x] T013 [P] Vérifier à la main les trois parcours (quickstart.md)
- [x] T014 Passer `flutter analyze` sur `lib/items`, `lib/favorites`, `lib/shared/services/favorite_ids_store`, `lib/champions/services/favorites_service.dart` et `lib/main.dart`

---

## Dependencies & Execution Order

- T002 précède T003 et T004 ; T003 précède T005.
- T004 précède T006, T007, T008, T010 et T012.
- T009 et T010 précèdent T011.
