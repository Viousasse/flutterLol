# Implementation Plan: Thème clair / sombre et palette du client LoL

**Branch**: `013-theme-clair-sombre-et-palette-lol` (livré sur `main`) | **Date**: 2026-10-05 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/013-theme-clair-sombre-et-palette-lol/spec.md`

## Summary

Deux palettes (`AppPalette.dark`, `AppPalette.light`) remplacent les constantes de couleur. `AppColors` devient une façade de lecteurs statiques sur la palette active. `ThemeService` porte le mode choisi (`ValueNotifier<ThemeMode>`) et le persiste. `MyApp` résout la luminosité effective (mode choisi + réglage de l'appareil), bascule la palette, reconstruit `ThemeData` et force la reconstruction de tout l'arbre. Une feuille « Affichage » permet de choisir. La palette a été retravaillée aux couleurs du client LoL, et la carte « Champion du jour » garde la palette sombre sur sa photo.

## Technical Context

**Language/Version**: Dart 3 / Flutter SDK `^3.13`

**Primary Dependencies**: `flutter` (Material), `shared_preferences` (persistance du mode). Aucune nouvelle dépendance.

**Storage**: `shared_preferences`, clé `theme_mode` (valeur : `system`, `light` ou `dark`)

**Testing**: `flutter_test` (tests de logique et de contraste, un test de widget d'accessibilité dans `test/draft/draft_a11y_test.dart`)

**Target Platform**: mobile et web

**Project Type**: application mobile/web Flutter (projet unique)

**Performance Goals**: un changement de mode reconstruit tout l'arbre en une image ; non mesuré.

**Constraints**: hors-ligne (aucun réseau) ; le mode doit être relu avant `runApp`.

**Scale/Scope**: 2 palettes de 8 couleurs ; ~39 fichiers touchés au premier commit pour passer les couleurs de `const` à des lecteurs dynamiques.

## Constitution Check

| Principe | Verdict | Preuve |
|----------|---------|--------|
| I. Organisation par fonctionnalité | Respecté | `lib/theme/` avec `widgets/theme_mode_sheet/theme_mode_sheet.dart` (un widget public par fichier) ; la feuille est ouverte depuis `lib/home/widgets/home_greeting/home_greeting.dart` qui importe le widget du thème par son chemin public. |
| II. Données Riot / erreurs affichables | Sans objet | Aucun appel réseau. |
| III. Images via RemoteImage | Respecté | La carte `champion_hero_card.dart` utilise `RemoteImage`. |
| IV. Thème centralisé | Respecté, avec une nuance | Les couleurs viennent de `lib/theme/app_colors.dart`. En contrepartie, `AppColors` n'est plus `const` : le principe dit « les couleurs constantes restent `const` » ; les widgets ne peuvent plus l'être quand ils lisent une couleur (voir Complexity Tracking). |
| V. État simple et local | Respecté | `ValueNotifier` exposé par `ThemeService`, persisté avec `shared_preferences`, relu avant le premier rendu (`lib/main.dart`) ; écouteurs retirés dans `dispose`. Aucun gestionnaire d'état ajouté. |
| VI. Tests | Respecté | `test/theme/app_palette_test.dart`, `contrast_test.dart`, `theme_service_test.dart` ; la carte `ChampionHeroCard` et `MyApp` n'ont pas de test dédié (voir spec, limites). |
| VII. Lisibilité, français | Respecté, avec deux commentaires inexacts | Textes en français ; deux commentaires de `app_colors.dart` sont périmés (« neuf couleurs », opacité 0,5). |

## Project Structure

### Documentation (this feature)

```text
specs/013-theme-clair-sombre-et-palette-lol/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── theme-api.md
├── checklists/
│   └── requirements.md
└── tasks.md
```

### Source Code (repository root)

```text
lib/
├── main.dart                                  # MyApp : résolution de la luminosité, reconstruction de l'arbre
├── theme/
│   ├── app_colors.dart                        # AppPalette (dark, light) + AppColors (lecteurs statiques)
│   ├── app_theme.dart                         # themeFor(Brightness), serif(), mono()
│   ├── app_fonts.dart                         # familles embarquées
│   ├── theme_service.dart                     # ThemeService : mode, persistance, resolve()
│   └── widgets/theme_mode_sheet/theme_mode_sheet.dart
├── home/widgets/home_greeting/home_greeting.dart          # bouton d'ouverture de la feuille
└── home/widgets/champion_hero_card/champion_hero_card.dart # palette sombre forcée sur la photo

test/
├── theme/
│   ├── app_palette_test.dart
│   ├── contrast_test.dart
│   └── theme_service_test.dart
└── draft/draft_a11y_test.dart                 # titre « Affichage » annoncé comme titre
```

**Structure Decision**: structure par fonctionnalité de la constitution ; le thème reste dans `lib/theme/` et sa feuille de choix dans `lib/theme/widgets/`.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Couleurs de l'interface non `const` (lecteurs statiques) et reconstruction forcée de tout l'arbre au changement de mode (`_markNeedsBuild` dans `lib/main.dart`) | Passer d'un mode à l'autre sans perdre l'écran ni les saisies, tout en gardant les widgets existants qui lisent `AppColors.x` | Un `InheritedWidget`/`Theme.of` aurait imposé de modifier tous les widgets pour lire le thème du contexte ; le commentaire de `lib/main.dart` explique qu'un widget `const` n'est pas reconstruit avec son parent. Un redémarrage de l'arbre (clé changée) aurait perdu l'état. |
