# Implementation Plan: Filtre de rôle dans le choix d'un champion

**Branch**: `018-filtre-de-role` (travail livré sur `main`) | **Date**: 2026-10-05 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/018-filtre-de-role/spec.md`

## Summary

La feuille `ChampionPickerSheet` reçoit un `ChampionRoleFilter` optionnel (rôles proposés, règle d'appartenance, voie de départ) et affiche des puces défilantes. La règle d'appartenance vient de `LaneProfile`, calculé à partir du jeu de matchups embarqué ; `RoleFilters` construit le filtre à partir de ce profil pour les écrans autres que la draft. `LaneProfile` a été déplacé de `lib/draft/services/` vers `lib/matchups/services/` parce qu'il sert désormais à plusieurs fonctionnalités.

## Technical Context

**Language/Version**: Dart 3 / Flutter, SDK `^3.13.3`

**Primary Dependencies**: aucune nouvelle ; réutilise `MatchupService` (fichier embarqué) et `AppFilterChip`

**Storage**: N/A (profil calculé en mémoire à partir de `assets/data/champion_matchups.json`)

**Testing**: `flutter_test`, sans réseau

**Target Platform**: mobile et web

**Project Type**: application mobile Flutter

**Performance Goals**: filtrage d'une liste d'environ 170 champions à chaque frappe ou toucher de puce, sans cache

**Constraints**: le filtre est un confort : son échec de chargement ne doit jamais empêcher de choisir un champion

**Scale/Scope**: 1 widget partagé, 1 modèle de filtre, 1 constructeur, 6 écrans clients

## Constitution Check

| Principe | Verdict | Preuve |
|----------|---------|--------|
| I. Organisation par fonctionnalité | Respecté avec réserve | Le filtre vit dans `lib/shared/widgets/champion_picker_sheet/`. `RoleFilters` est dans `lib/team/services/` mais est importé par `builds`, `compare`, `counters`, `strengths` : une fonctionnalité utilise un service d'une autre sans passer par `shared/` (voir Complexity Tracking). `LaneProfile` a été déplacé dans `lib/matchups/services/` (propriétaire naturel). |
| II. Données Riot | Respecté | Aucun réseau ; `RoleFilters.loadProfile` renvoie `null` en cas d'échec au lieu de lever. |
| III. RemoteImage | Respecté | La feuille garde `RemoteImage` pour les portraits. |
| IV. Thème centralisé | Respecté | `AppColors`/`AppTheme` uniquement. |
| V. État simple | Respecté | `setState` ; la voie retenue est un état local de la feuille. |
| VI. Tests | Respecté | `test/shared/widgets/champion_picker_sheet_test.dart`, `test/team/role_filters_test.dart`. Pas de test direct des seuils de `LaneProfile.fits` ni de l'intégration écran par écran. |
| VII. Français, commentaires | Respecté | Libellés en français, commentaires qui expliquent le pourquoi. |

## Project Structure

### Documentation (this feature)

```text
specs/018-filtre-de-role/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── role-filter.md
├── checklists/
│   └── requirements.md
└── tasks.md
```

### Source Code (repository root)

```text
lib/
├── shared/widgets/champion_picker_sheet/
│   ├── champion_picker_sheet.dart
│   └── champion_role_filter.dart
├── matchups/services/lane_profile.dart
├── team/
│   ├── constants/team_roles.dart
│   └── services/role_filters.dart
├── draft/draft_page.dart            # construit son filtre avec le profil du bot
├── team/team_page.dart
├── counters/counters_page.dart
├── strengths/strengths_page.dart
├── compare/compare_page.dart
└── builds/build_editor_page.dart

test/
├── shared/widgets/champion_picker_sheet_test.dart
└── team/role_filters_test.dart
```

**Structure Decision**: la feuille ignore ce qu'est un rôle ; l'écran qui l'ouvre fournit les rôles et la règle, ce qui garde la feuille réutilisable.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| `RoleFilters` (dans `lib/team/services/`) importé par `builds`, `compare`, `counters`, `strengths` (principe I). | Il fallait un seul endroit qui traduise un profil en filtre. | Le placer dans `lib/shared/` aurait mieux respecté le principe I : l'écart n'est pas corrigé. De plus `draft_page.dart` répète la construction du filtre (`_roleFilter`) au lieu d'appeler `RoleFilters.forProfile`, car il possède déjà le profil via le bot. |
