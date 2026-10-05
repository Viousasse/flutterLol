# Implementation Plan: Accessibilité des écrans récents

**Branch**: `020-accessibilite-des-ecrans-recents` (travail livré sur `main`) | **Date**: 2026-10-05 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/020-accessibilite-des-ecrans-recents/spec.md`

## Summary

Un audit RGAA des écrans récents (`docs/agents/reports/a11y-audit.md`) débouche sur de petits correctifs : `AppFilterChip` expose bouton, libellé et état sélectionné (`Semantics`) et agrandit sa zone tactile à 44 px quand l'appelant impose au moins cette hauteur, la barre de voies et la rangée de rôles de la feuille de choix lui donnent 44 px, et les titres du bilan de draft, des suggestions et de la feuille « Affichage » deviennent des en-têtes sémantiques. Un test de contraste fige les rapports de la palette, qui n'a pas eu besoin de changer.

## Technical Context

**Language/Version**: Dart 3 / Flutter, SDK `^3.13.3`

**Primary Dependencies**: aucune ; API `Semantics` de Flutter

**Storage**: N/A

**Testing**: `flutter_test` avec `tester.ensureSemantics()` et `isSemantics(...)`, sans `pumpAndSettle`

**Target Platform**: mobile et web

**Project Type**: application mobile Flutter

**Performance Goals**: sans objet

**Constraints**: ne pas changer l'aspect visible (pastille de 32 px conservée) ; ne pas casser les mises en page qui imposent des hauteurs de 30 à 34 px

**Scale/Scope**: 1 widget partagé central (`AppFilterChip`), 2 conteneurs de puces, 3 titres de section, 1 test de contraste

## Constitution Check

| Principe | Verdict | Preuve |
|----------|---------|--------|
| I. Organisation par fonctionnalité | Respecté | Modifications dans `lib/shared/widgets/`, `lib/draft/widgets/draft_report_view/`, `lib/theme/widgets/theme_mode_sheet/` ; `_SectionTitle` est un widget privé du fichier du bilan, sans nouveau widget public. |
| II. Données Riot | Sans objet | Aucun réseau. |
| III. RemoteImage | Respecté | Les images décoratives restent exclues de l'arbre sémantique par `RemoteImage` (`lib/shared/widgets/remote_image/remote_image.dart`). |
| IV. Thème centralisé | Respecté | Aucune couleur ajoutée ; `lib/theme/app_colors.dart` inchangé. |
| V. État simple | Respecté | Aucun état nouveau. |
| VI. Tests | Respecté avec lacune | `test/shared/widgets/app_filter_chip_test.dart`, `test/draft/draft_a11y_test.dart`, `test/theme/contrast_test.dart`. Les titres BANNISSEMENTS et SUGGESTIONS ne sont pas testés. |
| VII. Français, commentaires utiles | Respecté | Commentaires qui expliquent le pourquoi (zone tactile, `runSpacing`, `Row` minimale). |

**Contraintes techniques** : aucune nouvelle dépendance.

## Project Structure

### Documentation (this feature)

```text
specs/020-accessibilite-des-ecrans-recents/
├── plan.md
├── research.md
├── data-model.md   # non produit : aucune donnée manipulée (voir ci-dessous)
├── quickstart.md
├── contracts/
│   └── app-filter-chip.md
├── checklists/
│   └── requirements.md
└── tasks.md
```

Pas de `data-model.md` : cette fonctionnalité ne manipule aucune donnée (ni modèle, ni stockage). Le fichier est donc volontairement omis.

### Source Code (repository root)

```text
lib/
├── shared/widgets/
│   ├── app_filter_chip/app_filter_chip.dart
│   ├── lane_filter_bar/lane_filter_bar.dart
│   └── champion_picker_sheet/champion_picker_sheet.dart
├── draft/
│   ├── draft_page.dart                                   # titre SUGGESTIONS
│   └── widgets/draft_report_view/draft_report_view.dart  # titres du bilan
└── theme/widgets/theme_mode_sheet/theme_mode_sheet.dart  # titre « Affichage »

test/
├── shared/widgets/app_filter_chip_test.dart
├── draft/draft_a11y_test.dart
└── theme/contrast_test.dart

docs/agents/reports/a11y-audit.md
```

**Structure Decision**: correctifs au plus près des widgets concernés, sans nouvelle couche.

## Complexity Tracking

Aucune entorse à la constitution. Une réserve de périmètre : les appelants de `AppFilterChip` qui imposent 30 à 34 px (région, objets, carte, quiz, régions) ne sont pas passés à 44 px ; c'est une limite documentée dans `spec.md`, pas une violation d'un principe.
