---

description: "Liste des tâches de la fonctionnalité 014 (livrée)"
---

# Tasks: Barre de navigation

**Input**: Design documents from `/specs/014-barre-de-navigation/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: inclus (principe VI de la constitution).

**Organization**: tâches groupées par parcours utilisateur. Toutes sont livrées (`[x]`).

## Phase 1: Setup

- [x] T001 Créer le dossier `lib/main_navigation/widgets/app_nav_bar/` et `test/main_navigation/`

## Phase 2: Foundational

- [x] T002 Définir `AppNavDestination` (libellé, icône, icône pleine) dans `lib/main_navigation/widgets/app_nav_bar/app_nav_bar.dart`

## Phase 3: User Story 1 - Reconnaître et utiliser la barre (Priority: P1) MVP

**Goal**: barre d'onglets icône + libellé qui ouvre la destination touchée.

**Independent Test**: scénarios 1 et 2 de `quickstart.md`.

- [x] T003 [P] [US1] Test « affiche une icône et un libellé par destination » dans `test/main_navigation/app_nav_bar_test.dart`
- [x] T004 [P] [US1] Test « signale l'onglet touché » dans `test/main_navigation/app_nav_bar_test.dart`
- [x] T005 [US1] Implémenter `AppNavBar` (surface, filet supérieur, zone de sécurité, onglets à largeur égale, libellé réduit si besoin) dans `lib/main_navigation/widgets/app_nav_bar/app_nav_bar.dart`
- [x] T006 [US1] Remplacer la rangée de pastilles par `AppNavBar` et la liste de six `AppNavDestination` dans `lib/main_navigation/main_navigation.dart`

## Phase 4: User Story 2 - Onglet actif lisible (Priority: P1)

**Goal**: trait doré animé, icône pleine, libellé gras doré.

**Independent Test**: scénario 2 de `quickstart.md`.

- [x] T007 [US2] Ajouter le trait animé (`AnimatedContainer`, hauteur constante) et le jeu d'icônes/couleurs actif/inactif dans `lib/main_navigation/widgets/app_nav_bar/app_nav_bar.dart`
- [x] T008 [P] [US2] Test de l'icône pleine de l'onglet actif dans `test/main_navigation/app_nav_bar_test.dart` (test « affiche une icône et un libellé… »)

## Phase 5: User Story 3 - Accessibilité (Priority: P2)

**Goal**: bouton + libellé + état sélectionné annoncés.

**Independent Test**: scénario 7 de `quickstart.md`.

- [x] T009 [US3] Exposer `Semantics(button, selected, label)` par onglet dans `lib/main_navigation/widgets/app_nav_bar/app_nav_bar.dart`
- [x] T010 [P] [US3] Test « marque l'onglet actif pour les lecteurs d'écran » dans `test/main_navigation/app_nav_bar_test.dart`

## Phase 6: User Story 4 - État des onglets conservé (Priority: P2)

**Goal**: ne construire un onglet qu'à sa première visite et le garder vivant.

**Independent Test**: scénarios 3 et 4 de `quickstart.md` (pas de test automatisé).

- [x] T011 [US4] Conserver `visitedTabs` et l'`IndexedStack` autour des six pages dans `lib/main_navigation/main_navigation.dart`

## Phase 7: Polish

- [x] T012 [P] Vérifier `flutter analyze lib/main_navigation test/main_navigation` sans alerte
- [x] T013 Exécuter les scénarios de `specs/014-barre-de-navigation/quickstart.md`

## Dependencies & Execution Order

- Setup → Foundational (T002) → US1 → US2 (même fichier que T005) → US3 → US4 (indépendante, fichier `main_navigation.dart`) → Polish.

## Notes

- Livré en un seul commit, `b9132b1` (2026-10-05). T011 reprend un comportement antérieur (`6ea513f`).
