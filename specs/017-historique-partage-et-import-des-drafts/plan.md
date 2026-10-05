# Implementation Plan: Historique, partage et import des drafts

**Branch**: `017-historique-partage-et-import-des-drafts` (travail livré sur `main`) | **Date**: 2026-10-05 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/017-historique-partage-et-import-des-drafts/spec.md`

## Summary

Chaque draft jugée est enregistrée dans un historique local (50 entrées au plus) exposé par un `ValueNotifier` et persisté dans `shared_preferences`. Une page liste les drafts avec un bilan (taux contre le site hors drafts à deux, avec aide ou importées), une page de détail permet de copier un résumé et de rejouer avec les mêmes bannissements (`DraftPage(replayOf:)`). Le résumé texte se termine par un code `LOLD1.<base64url(JSON)>` ; un décodeur partagé (`ShareCode`) et une boîte générique (`PasteCodeDialog`) permettent d'importer ce code, d'où une draft marquée « importée ».

## Technical Context

**Language/Version**: Dart 3 / Flutter, SDK `^3.13.3` (`pubspec.yaml`)

**Primary Dependencies**: `shared_preferences` (persistance), `flutter/services` (presse-papiers). Aucune dépendance ajoutée.

**Storage**: `shared_preferences`, clé `draft_history`, liste de chaînes JSON (une par draft)

**Testing**: `flutter_test`, aucun appel réseau (chargeurs injectés, `SharedPreferences.setMockInitialValues`, presse-papiers simulé)

**Target Platform**: mobile et web

**Project Type**: application mobile Flutter

**Performance Goals**: sans objet ; liste d'au plus 50 éléments rendue dans un `ListView.separated`

**Constraints**: hors-ligne compatible (historique local, import sans réseau) ; seule la liste des champions (images) passe par le réseau et son échec est affiché avec « Réessayer »

**Scale/Scope**: 4 écrans/boîtes (historique, détail, import, confirmations), 1 format de code

## Constitution Check

| Principe | Verdict | Preuve |
|----------|---------|--------|
| I. Organisation par fonctionnalité | Respecté | Modèles/services/widgets sous `lib/draft/` ; code partagé (`ShareCode`, `PasteCodeDialog`, `copyToClipboard`) sous `lib/shared/`. Un widget public par fichier (`draft_history_tile.dart` exporte aussi deux fonctions publiques `formatDraftDate` et `draftOutcomeLabel`, pas des widgets). |
| II. Données Riot, erreurs affichables | Respecté | `lib/draft/draft_history_page.dart` : `userMessageFor` + `ErrorRetryView` quand `loadChampions` échoue. Aucun appel réseau propre, aucune clé. |
| III. Images via RemoteImage | Respecté | `draft_history_tile.dart`, `draft_stats_card.dart` utilisent `RemoteImage` ; champion absent = case grise sans image. |
| IV. Thème centralisé | Respecté | Seulement `AppColors`/`AppTheme` dans les fichiers de la fonctionnalité. |
| V. État simple et local | Respecté | `DraftHistoryStore.records` est un `ValueNotifier` persisté avec `shared_preferences` ; `setState` dans les pages ; `TextEditingController` libéré dans `dispose` (`paste_code_dialog.dart`). |
| VI. Tests | Respecté | 7 fichiers de tests listés dans `quickstart.md` ; `DraftHistoryStore.reset()` pour le stockage statique. |
| VII. Français, tutoiement, commentaires utiles | **Entorse partielle** | Texte en français, commentaires qui expliquent le pourquoi. Mais l'interface de cette fonctionnalité vouvoie (voir Complexity Tracking). |

## Project Structure

### Documentation (this feature)

```text
specs/017-historique-partage-et-import-des-drafts/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── draft-share-code.md
│   └── history-api.md
├── checklists/
│   └── requirements.md
└── tasks.md
```

### Source Code (repository root)

```text
lib/
├── draft/
│   ├── draft_history_page.dart
│   ├── draft_record_page.dart
│   ├── draft_page.dart                      # enregistre la draft jugée, accepte replayOf (fichier partagé avec d'autres fonctionnalités)
│   ├── models/draft_record.dart
│   ├── services/
│   │   ├── draft_history_store.dart
│   │   ├── draft_history_stats.dart
│   │   ├── draft_share_text.dart
│   │   └── draft_share_code.dart
│   └── widgets/
│       ├── draft_history_tile/draft_history_tile.dart
│       └── draft_stats_card/draft_stats_card.dart
├── shared/
│   ├── services/
│   │   ├── share_code/share_code.dart
│   │   └── clipboard_copy/clipboard_copy.dart
│   └── widgets/paste_code_dialog/paste_code_dialog.dart
└── team/team_page.dart                       # entrée vers l'historique

test/
├── draft/
│   ├── draft_history_test.dart
│   ├── draft_history_widgets_test.dart
│   ├── draft_record_page_test.dart
│   ├── draft_share_code_test.dart
│   ├── draft_import_test.dart
│   ├── draft_page_replay_test.dart
│   └── draft_support.dart
└── shared/widgets/paste_code_dialog_test.dart
```

**Structure Decision**: structure par fonctionnalité de la constitution ; le mécanisme du code de partage est mutualisé dans `lib/shared/services/share_code/` parce que les builds l'utilisent aussi (préfixe `LOLB1.`, hors de ce dossier).

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Vouvoiement dans l'interface (principe VII demande le tutoiement) : « Collez le code ou le message reçu », « Cette draft est déjà dans votre historique. », « Jouez-en une avec l'entraîneur de draft », « Importer une draft ». | Le reste de la page de draft livrée avant la constitution (ex. « Vous l'emportez », nom par défaut « Vous ») vouvoie ; la fonctionnalité a gardé ce registre pour rester homogène. | Ce n'est pas une justification de fond : l'écart n'est pas corrigé. Une reprise des textes en tutoiement (« Colle le code… ») reste à faire. |
