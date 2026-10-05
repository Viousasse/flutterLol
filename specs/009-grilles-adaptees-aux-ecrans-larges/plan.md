# Implementation Plan: Grilles adaptées aux écrans larges

**Branch**: `009-grilles-adaptees-aux-ecrans-larges` (travail livré sur `main`) | **Date**: 2026-10-05 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/009-grilles-adaptees-aux-ecrans-larges/spec.md`

## Summary

Les grilles d'objets (3 colonnes fixes) et de champions (2 colonnes fixes) s'étiraient sur un écran large. Elles passent à des grilles à largeur maximale de carte (`SliverGridDelegateWithMaxCrossAxisExtent`) : le nombre de colonnes dépend de la largeur disponible. Chaque grille est définie une seule fois dans un fichier `constants/` de sa fonctionnalité et réutilisée par la page de liste et par l'onglet de favoris correspondant.

## Technical Context

**Language/Version**: Dart 3, Flutter SDK `^3.13`

**Primary Dependencies**: aucune dépendance ajoutée (widgets Flutter standards)

**Storage**: N/A (mise en page uniquement)

**Testing**: `flutter_test` ; aucun test dédié n'a été écrit pour cette fonctionnalité (voir Complexity Tracking)

**Target Platform**: mobile et web (le défaut est visible sur le web et sur tablette)

**Project Type**: application mobile et web Flutter

**Performance Goals**: N/A

**Constraints**: la hauteur d'une carte d'objet doit suivre l'échelle de texte du système ; aucun rognage du nom sur deux lignes à 360 px

**Scale/Scope**: 2 grilles, 4 écrans concernés (Champions, Objets, Favoris champions, Favoris objets)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principe | Verdict | Preuve |
|----------|---------|--------|
| I. Organisation par fonctionnalité | Respecté avec une réserve | Les grilles sont dans `lib/champions/constants/champion_grid.dart` et `lib/items/constants/item_grid.dart`. Les onglets de `lib/favorites/` importent ces fichiers de constantes (pas des widgets internes), ce qui reste conforme à l'esprit « passer par un modèle ou shared/ » sans y déplacer le code. |
| II. Données Riot via Data Dragon | Sans objet | Aucun appel réseau. |
| III. Images via RemoteImage | Sans objet | Les images des cartes ne changent pas. |
| IV. Thème centralisé | Respecté | Aucune couleur ni police ajoutée. |
| V. État simple et local | Respecté | Aucun état ; la grille de objets lit seulement `MediaQuery`. |
| VI. Tests de la logique et des widgets clés | **Écart** | `test/items/` et `test/champions/` ne contiennent aucun test de grille. Voir Complexity Tracking. |
| VII. Lisibilité, commentaires utiles | Respecté | Les constantes sont nommées (`_maxCardWidth`, `_fixedHeight`, `_textHeight`, `_spacing`) et commentées sur le pourquoi. |

## Project Structure

### Documentation (this feature)

```text
specs/009-grilles-adaptees-aux-ecrans-larges/
├── plan.md
├── research.md
├── data-model.md        # omis : aucune donnée
├── quickstart.md
├── contracts/
│   └── grid-delegates.md
├── tasks.md
└── checklists/
    └── requirements.md
```

`data-model.md` n'est pas produit : la fonctionnalité ne manipule aucune donnée.

### Source Code (repository root)

```text
lib/
├── champions/
│   ├── champions_page.dart                       # utilise championGridDelegate
│   └── constants/champion_grid.dart              # championGridDelegate (nouveau)
├── items/
│   ├── items_page.dart                           # utilise itemGridDelegate(context)
│   └── constants/item_grid.dart                  # itemGridDelegate (nouveau)
└── favorites/widgets/
    ├── favorite_champions_tab/favorite_champions_tab.dart
    └── favorite_items_tab/favorite_items_tab.dart
```

**Structure Decision**: une constante ou fonction de grille par fonctionnalité, dans `constants/`, plutôt qu'un widget de grille partagé : les deux grilles ont des paramètres différents (hauteur fixe pour les objets, ratio pour les champions).

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Principe VI : aucun test de la grille (`itemGridDelegate`, `championGridDelegate`) | La livraison était un correctif visuel vérifié dans l'application sur capture d'écran | Un test de widget fixant la largeur de fenêtre serait possible (`tester.view.physicalSize`) mais n'a pas été écrit ; c'est une dette à combler, pas un choix justifié |
