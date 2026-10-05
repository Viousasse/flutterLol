# Implementation Plan: Constructeur de builds, partage et import par code

**Branch**: `008-constructeur-de-builds` (travail livré sur `main`) | **Date**: 2026-10-05 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/008-constructeur-de-builds/spec.md`

**Note**: plan rédigé après coup. Commits : `c86ea71` (constructeur), `32fac77` (déplacement du sélecteur d'objets), `a4475d7` (entrée Outils), `57ca610` et `0afb3b1` (partage, code, import), `23ea5c6` (filtre de rôle).

## Summary

Composer jusqu'à six objets, voir prix et bonus cumulés, enregistrer localement (`BuildStore`, `shared_preferences`), lister/modifier/supprimer, copier un résumé contenant un code `LOLB1.` et importer un code collé. Le mécanisme de code (`ShareCode`) et la boîte de collage (`PasteCodeDialog`) sont partagés avec l'historique des drafts.

## Technical Context

**Language/Version**: Dart 3 / Flutter, SDK `^3.13.3`

**Primary Dependencies**: `shared_preferences` (stockage), `dart:convert` (JSON, base64url), `flutter/services` (presse-papiers) ; `ItemService`/`ChampionService` (Data Dragon). Aucune dépendance ajoutée.

**Storage**: `shared_preferences`, clé `saved_builds`, liste de chaînes JSON (une par build).

**Testing**: `flutter_test` — `test/builds/*.dart`, `test/shared/widgets/paste_code_dialog_test.dart`.

**Target Platform**: mobile et web.

**Project Type**: application mobile/web Flutter, projet unique.

**Performance Goals**: aucun objectif chiffré.

**Constraints**: hors-ligne via la copie des données Data Dragon ; écritures du stockage sérialisées.

**Scale/Scope**: 2 pages, 3 widgets, 5 services/modèles, plus `ShareCode` et `PasteCodeDialog` partagés.

## Constitution Check

| Principe | Verdict | Preuve / remarque |
|----------|---------|-------------------|
| I. Organisation par fonctionnalité | Respecté | `lib/builds/{models,services,widgets/<nom>/<nom>.dart}` ; partage dans `lib/shared/services/share_code/share_code.dart` et `lib/shared/widgets/{paste_code_dialog,item_picker_sheet,champion_picker_sheet}/`. |
| II. Données Riot via Data Dragon, erreurs affichables | Respecté | `BuildsPage` et `BuildEditorPage` : `userMessageFor` + `ErrorRetryView` ; `ItemService`/`ChampionService`. |
| III. Images uniquement via RemoteImage | Respecté | `build_tile.dart`, `build_slot.dart`, `build_editor_page.dart` utilisent `RemoteImage`. |
| IV. Thème centralisé | Respecté | `AppColors`/`AppTheme` dans tous les fichiers de `lib/builds`. |
| V. État simple et local | Respecté | `setState` ; `BuildStore.builds` en `ValueNotifier` écouté par `ValueListenableBuilder` ; `TextEditingController` libéré dans `dispose` (`build_editor_page.dart`) ; `BuildStore.reset()` pour les tests. |
| VI. Tests de la logique et des widgets clés | Respecté en partie | Services testés (stats, store, texte, code, import) ; `builds_page_test.dart` pour la liste ; `paste_code_dialog_test.dart`. Pas de test de `BuildEditorPage`. |
| VII. Lisibilité, français, tutoiement | Entorse | Messages vouvoyants (« Composez-en une… », « Collez le code… »). |

## Project Structure

### Documentation (this feature)

```text
specs/008-constructeur-de-builds/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
├── checklists/requirements.md
└── tasks.md
```

### Source Code (repository root)

```text
lib/builds/
├── build_editor_page.dart
├── builds_page.dart
├── models/build.dart
├── services/{build_stats,build_store,build_share_text,build_share_code,build_import}.dart
└── widgets/{build_slot,build_stats_panel,build_tile}/<nom>.dart
lib/shared/services/share_code/share_code.dart
lib/shared/services/clipboard_copy/clipboard_copy.dart
lib/shared/widgets/{paste_code_dialog,item_picker_sheet,champion_picker_sheet,action_link}/…
lib/items/widgets/builds_button/builds_button.dart
lib/tools/widgets/tools_section/tools_section.dart
test/builds/{build_stats,build_store,build_share_text,build_share_code,build_import,builds_page}_test.dart
test/shared/widgets/paste_code_dialog_test.dart
```

**Structure Decision**: projet Flutter unique, un dossier par fonctionnalité ; le code partageable (code de partage, boîte de collage, feuilles de choix) est dans `lib/shared`.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Principe VII : vouvoiement dans `builds_page.dart` et `compare_page.dart` | Aucune justification (écart non voulu) | Corriger les textes, ou amender la constitution |
| Principe VI : pas de test de `BuildEditorPage` | La logique est dans les services testés | Écrire un test d'écran avec sources injectables (comme `BuildsPage`) |
| `importBuildFromText` sans appelant dans `lib/` | Conservée par `test/builds/build_import_test.dart` | La supprimer ou l'utiliser dans `BuildsPage` |
