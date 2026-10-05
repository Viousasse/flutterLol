---

description: "Liste des tâches de la fonctionnalité 013 (livrée)"
---

# Tasks: Thème clair / sombre et palette du client LoL

**Input**: Design documents from `/specs/013-theme-clair-sombre-et-palette-lol/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: inclus (principe VI de la constitution).

**Organization**: tâches groupées par parcours utilisateur. Toutes sont livrées (`[x]`).

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup

- [x] T001 Réutiliser les polices embarquées (déjà en place avant cette fonctionnalité, commit `938ffb6`) : `assets/fonts/` et `lib/theme/app_fonts.dart`

## Phase 2: Foundational

**Purpose**: rendre les couleurs dynamiques sans réécrire les écrans.

- [x] T002 Définir `AppPalette` (palettes `dark` et `light`) et transformer `AppColors` en lecteurs statiques dans `lib/theme/app_colors.dart`
- [x] T003 Construire le `ThemeData` d'un mode donné (`themeFor`, `surfaceTint` transparent) dans `lib/theme/app_theme.dart`
- [x] T004 Retirer les `const` qui entouraient les couleurs dans les widgets existants (ex. `lib/home/home_page.dart`, `lib/items/widgets/item_card/item_card.dart`, `lib/search/search_page.dart`)

**Checkpoint**: les couleurs se lisent à la volée dans la palette active.

## Phase 3: User Story 1 - Basculer entre clair et sombre (Priority: P1) MVP

**Goal**: choisir le mode depuis l'accueil et le voir appliqué sans perdre l'écran.

**Independent Test**: scénarios 2 et 3 de `quickstart.md`.

### Tests for User Story 1

- [x] T005 [P] [US1] Test du mode actif (`AppColors.use` / `isDark`) dans `test/theme/app_palette_test.dart`
- [x] T006 [P] [US1] Test des notifications de changement de mode dans `test/theme/theme_service_test.dart`

### Implementation for User Story 1

- [x] T007 [US1] Créer la feuille « Affichage » (trois choix, coche, fond peint dans `build`) dans `lib/theme/widgets/theme_mode_sheet/theme_mode_sheet.dart`
- [x] T008 [US1] Ajouter l'icône d'ouverture de la feuille dans `lib/home/widgets/home_greeting/home_greeting.dart`
- [x] T009 [US1] Résoudre la luminosité, changer de palette et reconstruire tout l'arbre dans `lib/main.dart`

## Phase 4: User Story 2 - Mémoire du choix et suivi de l'appareil (Priority: P1)

**Goal**: mode mémorisé, relu avant le premier rendu, suivi du réglage de l'appareil.

**Independent Test**: scénarios 4 et 5 de `quickstart.md`.

### Tests for User Story 2

- [x] T010 [P] [US2] Test de relecture/enregistrement et de résolution automatique dans `test/theme/theme_service_test.dart`

### Implementation for User Story 2

- [x] T011 [US2] Implémenter `ThemeService` (`mode`, `ensureLoaded`, `setMode`, `resolve`, tolérance aux erreurs de stockage) dans `lib/theme/theme_service.dart`
- [x] T012 [US2] Attendre `ThemeService.ensureLoaded()` avant `runApp` et écouter `didChangePlatformBrightness` dans `lib/main.dart`

## Phase 5: User Story 3 - Couleurs du client LoL (Priority: P2)

**Goal**: palettes bleu nuit/or et parchemin.

**Independent Test**: scénarios 2 et 7 de `quickstart.md`.

- [x] T013 [US3] Remplacer la palette corail par les teintes du client LoL dans `lib/theme/app_colors.dart`
- [x] T014 [US3] Retirer la teinte rosée en mode clair (surfaceTint de la barre et du schéma de couleurs) dans `lib/theme/app_theme.dart`
- [x] T015 [US3] Faire suivre le changement de mode à la feuille ouverte (fond dans `build`) dans `lib/theme/widgets/theme_mode_sheet/theme_mode_sheet.dart`

## Phase 6: User Story 4 - Lisibilité 4,5:1 (Priority: P2)

**Goal**: contrastes garantis par test.

**Independent Test**: `flutter test test/theme`.

- [x] T016 [P] [US4] Tests de contraste du texte principal, secondaire, discret et de l'accent sur fond et cartes dans `test/theme/app_palette_test.dart`
- [x] T017 [P] [US4] Tests de contraste sur une puce sélectionnée dans `test/theme/contrast_test.dart`
- [x] T018 [US4] Calibrer les opacités du texte secondaire et discret dans `lib/theme/app_colors.dart`
- [x] T019 [P] [US4] Annoncer « Affichage » comme titre sémantique dans `lib/theme/widgets/theme_mode_sheet/theme_mode_sheet.dart`, testé dans `test/draft/draft_a11y_test.dart`

## Phase 7: User Story 5 - Carte « Champion du jour » lisible (Priority: P3)

**Goal**: texte clair sur voile sombre dans les deux modes.

**Independent Test**: scénario 6 de `quickstart.md`.

- [x] T020 [US5] Forcer `AppPalette.dark` pour le texte et le dégradé de la carte dans `lib/home/widgets/champion_hero_card/champion_hero_card.dart`

## Phase 8: Polish

- [x] T021 [P] Vérifier `flutter analyze lib/theme lib/main.dart` sans alerte
- [x] T022 Exécuter les scénarios de `specs/013-theme-clair-sombre-et-palette-lol/quickstart.md`

## Dependencies & Execution Order

- Setup → Foundational → US1 et US2 (P1, en parallèle) → US3 et US4 (P2) → US5 (P3) → Polish.
- US3 et US4 modifient les mêmes valeurs de `app_colors.dart` que T002 : elles viennent après.

## Notes

- Livré en quatre commits du 2026-10-05 : `15d9e51`, `d260ea6` (partie thème), `bfc1352`, `b6c98aa` (carte du jour).
