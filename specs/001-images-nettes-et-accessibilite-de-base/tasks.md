---

description: "Liste des tâches de la fonctionnalité 001, rédigée après coup d'après le code livré"
---

# Tasks: Images nettes et accessibilité de base

**Input**: Design documents from `/specs/001-images-nettes-et-accessibilite-de-base/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: les tâches de test listées sont celles qui existent ; aucun test dédié au composant d'image n'a été écrit (voir plan.md, Complexity Tracking).

**Organization**: tâches groupées par parcours utilisateur. Commits : `ab817a6` (US1), `a1c29ba` (US2 et US3).

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup (Shared Infrastructure)

- [x] T001 Vérifier que `cached_network_image` est déclaré dans `pubspec.yaml` (aucune dépendance ajoutée par cette fonctionnalité)

---

## Phase 2: Foundational (Blocking Prerequisites)

- [x] T002 Ajouter le paramètre `alignment` (défaut `Alignment.center`) à `RemoteImage` dans `lib/shared/widgets/remote_image/remote_image.dart`

**Checkpoint**: le composant accepte un cadrage, les parcours peuvent démarrer.

---

## Phase 3: User Story 1 - Des cartes de champions nettes et bien cadrées (Priority: P1) 🎯 MVP

**Goal**: portrait vertical net, haut conservé.

**Independent Test**: voir quickstart.md, étapes 2 et 3.

- [x] T003 [US1] Ajouter le getter `portraitUrl` dans `lib/champions/models/champion.dart`
- [x] T004 [US1] Afficher `champion.portraitUrl` avec `Alignment.topCenter` dans `lib/champions/widgets/champion_card/champion_card.dart`
- [x] T005 [P] [US1] Utiliser le même portrait ancré en haut dans `lib/compare/widgets/compare_slot/compare_slot.dart`

**Checkpoint**: la liste des champions est nette et bien cadrée.

---

## Phase 4: User Story 2 - Une attente et un échec d'image lisibles (Priority: P2)

**Goal**: pulsation pendant le chargement, repli discret en cas d'échec.

**Independent Test**: quickstart.md, étapes 4 à 6.

- [x] T006 [P] [US2] Créer `ShimmerBox` dans `lib/shared/widgets/shimmer_box/shimmer_box.dart`
- [x] T007 [US2] Brancher `ShimmerBox` comme état de chargement et rectangle `AppColors.surface` comme repli dans `lib/shared/widgets/remote_image/remote_image.dart` (remplace l'ancien `_Backdrop`)

---

## Phase 5: User Story 3 - Lecteurs d'écran et contraste du texte discret (Priority: P3)

**Goal**: contrôles nommés, images décoratives ignorées, contraste 4,5:1.

**Independent Test**: quickstart.md, étapes 7 à 9 ; tests ci-dessous.

- [x] T008 [P] [US3] Ajouter `semanticLabel` (image ignorée ou annoncée) dans `lib/shared/widgets/remote_image/remote_image.dart`
- [x] T009 [P] [US3] Annoter le badge favori (bouton, étiquette selon l'état) dans `lib/champions/widgets/champion_card/champion_card_favorite_badge.dart`
- [x] T010 [P] [US3] Annoter les onglets (bouton, sélectionné, libellé) dans `lib/main_navigation/widgets/app_nav_bar/app_nav_bar.dart` (annotation d'abord posée dans `lib/main_navigation/main_navigation.dart`, déplacée par `b9132b1`)
- [x] T011 [P] [US3] Porter le texte discret à 4,5:1 dans `lib/theme/app_colors.dart` (palettes `AppPalette.dark` et `AppPalette.light`)
- [x] T012 [P] [US3] Test de sémantique des onglets dans `test/main_navigation/app_nav_bar_test.dart`
- [x] T013 [P] [US3] Test de contraste des deux palettes dans `test/theme/contrast_test.dart`

---

## Phase N: Polish & Cross-Cutting Concerns

- [x] T014 Vérifier à la main les trois parcours dans l'application (quickstart.md)
- [x] T015 Passer `flutter analyze` sur `lib/shared/widgets/remote_image`, `lib/shared/widgets/shimmer_box` et `lib/champions`

---

## Dependencies & Execution Order

- T002 précède T004, T005 et T007 (paramètre `alignment`, repli).
- T006 précède T007.
- US1, US2, US3 sont indépendantes une fois T002 faite.
