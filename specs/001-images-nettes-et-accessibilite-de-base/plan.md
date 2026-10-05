# Implementation Plan: Images nettes et accessibilité de base

**Branch**: `001-images-nettes-et-accessibilite-de-base` (livré sur `main`) | **Date**: 2026-10-05 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-images-nettes-et-accessibilite-de-base/spec.md`

## Summary

Les cartes de champions passent de l'icône carrée de 120 px agrandie à l'illustration verticale « loading » de Data Dragon (`Champion.portraitUrl`), ancrée en haut grâce à un nouveau paramètre `alignment` de `RemoteImage`. Le même composant gagne un fond qui pulse pendant le chargement (`ShimmerBox`), un repli discret en cas d'échec et une description optionnelle pour les lecteurs d'écran. Le badge favori et la barre d'onglets reçoivent des annotations de sémantique, et le texte discret est éclairci pour atteindre le contraste 4,5:1.

## Technical Context

**Language/Version**: Dart 3 / Flutter (SDK `^3.13.3`)

**Primary Dependencies**: `cached_network_image` (cache disque sur mobile), Flutter `Image.network` sur le web ; aucune nouvelle dépendance

**Storage**: cache disque des images géré par `cached_network_image` (mobile) ; aucun stockage applicatif

**Testing**: `flutter_test` ; sémantique des onglets (`test/main_navigation/app_nav_bar_test.dart`), contraste (`test/theme/contrast_test.dart`)

**Target Platform**: mobile et web

**Project Type**: application mobile Flutter (companion League of Legends)

**Performance Goals**: pas de clignotement blanc au chargement ; une animation de pulsation de 1 100 ms par image en attente

**Constraints**: aucun appel réseau dans les tests ; les images viennent de `ddragon.leagueoflegends.com`

**Scale/Scope**: une cinquantaine d'appels à `RemoteImage` dans `lib/`, une page de liste (cartes) et une page de comparaison utilisent le portrait

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principe | Verdict | Preuve |
|----------|---------|--------|
| I. Organisation par fonctionnalité | Respecté | `lib/shared/widgets/remote_image/remote_image.dart`, `lib/shared/widgets/shimmer_box/shimmer_box.dart` (un widget public par fichier, dossier `widgets/<nom>/<nom>.dart`) ; carte dans `lib/champions/widgets/champion_card/` |
| II. Données Riot via Data Dragon | Sans objet | Aucun appel réseau géré par `DataDragonService` n'est ajouté ; seule l'URL de l'image change |
| III. Images uniquement via RemoteImage | Respecté | La carte et `compare_slot.dart` passent par `RemoteImage` avec `portraitUrl` ; aucun `Image.network` direct hors du composant (`grep` sur `lib/`) |
| IV. Thème centralisé | Respecté | `ShimmerBox` et le repli d'échec lisent `AppColors` ; le contraste est porté par les palettes `AppPalette` (`lib/theme/app_colors.dart`) |
| V. État simple et local | Respecté | `ShimmerBox` est un `StatefulWidget` qui libère son `AnimationController` dans `dispose` |
| VI. Tests (NON-NEGOTIABLE) | Respecté en partie, voir Complexity Tracking | Sémantique des onglets et contraste testés ; le composant d'image et la carte n'ont pas de test dédié |
| VII. Lisibilité, français | Respecté, une entorse mineure | Commentaires qui expliquent le pourquoi (`remote_image.dart`, `champion.dart`) ; durée de fondu `150` en littéral |

## Project Structure

### Documentation (this feature)

```text
specs/001-images-nettes-et-accessibilite-de-base/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── remote-image.md
├── checklists/
│   └── requirements.md
└── tasks.md
```

### Source Code (repository root)

```text
lib/
├── champions/
│   ├── models/champion.dart                          # portraitUrl
│   └── widgets/champion_card/
│       ├── champion_card.dart                        # portrait ancré en haut
│       └── champion_card_favorite_badge.dart         # sémantique du badge
├── compare/widgets/compare_slot/compare_slot.dart    # même portrait, ancré en haut
├── main_navigation/widgets/app_nav_bar/app_nav_bar.dart  # sémantique des onglets
├── shared/widgets/
│   ├── remote_image/remote_image.dart                # alignment, semanticLabel, repli, pulsation
│   └── shimmer_box/shimmer_box.dart                  # fond qui pulse
└── theme/app_colors.dart                             # contraste du texte discret

test/
├── main_navigation/app_nav_bar_test.dart
└── theme/contrast_test.dart
```

**Structure Decision**: tout reste dans la structure existante ; seul `ShimmerBox` est un nouveau dossier de widget partagé.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Principe VI : pas de test dédié pour `RemoteImage`, `ShimmerBox`, `ChampionCard`, `Champion.portraitUrl` | Le résultat (netteté, cadrage, pulsation) a été jugé à l'œil dans l'application ; le réseau n'est pas disponible en test | Un test de widget aurait dû vérifier au moins l'URL du portrait et l'alignement ; c'est une dette reconnue, non justifiée par une impossibilité technique |
| Principe VII : `Duration(milliseconds: 150)` littéral dans `remote_image.dart` | Valeur courte et locale | Aurait dû être nommée comme `_pulse` l'est dans `shimmer_box.dart` |
