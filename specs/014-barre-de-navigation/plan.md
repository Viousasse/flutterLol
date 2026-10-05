# Implementation Plan: Barre de navigation

**Branch**: `014-barre-de-navigation` (livré sur `main`) | **Date**: 2026-10-05 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/014-barre-de-navigation/spec.md`

## Summary

Remplacer la rangée de pastilles de texte de `MainNavigation` par un widget dédié `AppNavBar` (icône + libellé par onglet, trait doré animé sur l'onglet actif, icône pleine, filet doré supérieur) et extraire sa donnée dans `AppNavDestination`. `MainNavigation` garde sa logique d'onglets construits à la première visite dans un `IndexedStack`.

## Technical Context

**Language/Version**: Dart 3 / Flutter SDK `^3.13`

**Primary Dependencies**: `flutter` (Material) uniquement ; aucune nouvelle dépendance.

**Storage**: N/A (l'onglet courant n'est pas mémorisé entre deux lancements)

**Testing**: `flutter_test` (tests de widget)

**Target Platform**: mobile et web

**Project Type**: application mobile/web Flutter (projet unique)

**Performance Goals**: animation du trait de 180 ms ; pas d'autre objectif.

**Constraints**: hors-ligne sans objet ; la barre ne doit pas changer de hauteur ; zone de sécurité inférieure respectée.

**Scale/Scope**: un widget (~120 lignes), six destinations.

## Constitution Check

| Principe | Verdict | Preuve |
|----------|---------|--------|
| I. Organisation par fonctionnalité | Respecté | `lib/main_navigation/widgets/app_nav_bar/app_nav_bar.dart`. Écart mineur : le fichier contient deux classes publiques (`AppNavDestination` et `AppNavBar`) alors que la constitution demande un seul widget public par fichier ; `AppNavDestination` est un modèle et non un widget, mais il n'est pas dans `models/` (voir Complexity Tracking). |
| II. Données Riot / erreurs affichables | Sans objet | Aucun réseau. |
| III. Images via RemoteImage | Sans objet | Icônes Material uniquement. |
| IV. Thème centralisé | Respecté | Couleurs `AppColors.*`, police `AppFonts.sans`, aucun `Color(...)` dans `app_nav_bar.dart`. La taille 10,5 du libellé est écrite en dur (pas de style partagé). |
| V. État simple et local | Respecté | `setState` dans `MainNavigation` (onglet courant et `visitedTabs`). |
| VI. Tests | Respecté pour la barre | `test/main_navigation/app_nav_bar_test.dart` (3 tests) ; `MainNavigation` n'a pas de test. |
| VII. Lisibilité, français | Respecté | Libellés en français ; commentaires de `main_navigation.dart` et `app_nav_bar.dart` expliquent le pourquoi. |

## Project Structure

### Documentation (this feature)

```text
specs/014-barre-de-navigation/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── app-nav-bar.md
├── checklists/
│   └── requirements.md
└── tasks.md
```

### Source Code (repository root)

```text
lib/main_navigation/
├── main_navigation.dart                          # MainNavigation : onglets, IndexedStack, visitedTabs
└── widgets/app_nav_bar/app_nav_bar.dart          # AppNavDestination + AppNavBar (+ _NavItem privé)

test/main_navigation/
└── app_nav_bar_test.dart
```

**Structure Decision**: la barre est extraite dans son propre widget (message du commit `b9132b1` : « La barre est extraite dans son propre widget et testée »), ce qui la rend testable sans charger les six pages.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| `AppNavDestination` et `AppNavBar` dans le même fichier | La donnée n'a de sens qu'avec la barre ; elle est petite (4 champs) | Un fichier `models/` pour 12 lignes n'a pas été jugé utile ; aucune trace écrite de cette décision, c'est une entorse non justifiée dans le code. |
