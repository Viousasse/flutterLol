# Implementation Plan: Carte du dernier patch sur l'accueil

**Branch**: `006-carte-du-dernier-patch` (travail livré sur `main`) | **Date**: 2026-10-05 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/006-carte-du-dernier-patch/spec.md`

**Note**: plan rédigé après coup d'après le commit `e973e19`.

## Summary

Déduire le numéro du dernier patch de la version Data Dragon (`DataDragonService.latestVersion`), construire l'adresse officielle des notes (`PatchNotes.fromVersion`) et l'afficher dans une carte de l'accueil (`PatchNotesCard`) qui ouvre le lien avec `url_launcher`. La carte est facultative : sans version, elle est absente.

## Technical Context

**Language/Version**: Dart 3 / Flutter, SDK `^3.13.3`

**Primary Dependencies**: `url_launcher` (^6.3.3, **ajoutée par cette fonctionnalité**, `pubspec.yaml`), `DataDragonService` existant

**Storage**: N/A (la version du jeu est mise en cache par `DataDragonService`, hors périmètre)

**Testing**: `flutter_test` — `test/patch_notes/patch_notes_test.dart`

**Target Platform**: mobile et web ; l'ouverture externe passe par `LaunchMode.externalApplication`. Les fichiers de plugins générés des plateformes (`linux`, `macos`, `windows`) et `pubspec.lock` ont été mis à jour par la commande de dépendance.

**Project Type**: application mobile/web Flutter, projet unique

**Performance Goals**: aucun ; le chargement de la version est lancé en parallèle de celui des champions et n'attend rien.

**Constraints**: la carte ne doit jamais bloquer ni dégrader l'accueil ; aucune clé API.

**Scale/Scope**: 1 modèle, 1 widget, 1 branchement dans l'accueil.

## Constitution Check

| Principe | Verdict | Preuve / remarque |
|----------|---------|-------------------|
| I. Organisation par fonctionnalité | Respecté | `lib/patch_notes/models/patch_notes.dart` (modèle), widget dans `lib/home/widgets/patch_notes_card/patch_notes_card.dart` (un seul widget public). L'accueil importe un modèle d'une autre fonctionnalité, pas un widget. |
| II. Données Riot via Data Dragon, erreurs affichables | Respecté avec nuance | La version passe par `DataDragonService.latestVersion()`. L'échec est volontairement silencieux (carte absente) : ce n'est pas un chargement sans issue, mais l'erreur n'est pas affichée (justifié : bonus). L'ouverture du lien échoue avec un message en français. |
| III. Images uniquement via RemoteImage | Respecté | La carte n'affiche aucune image réseau (icône `Icons.open_in_new`). |
| IV. Thème centralisé | Respecté | `AppColors.accentSoft`, `AppColors.accent`, `AppTheme.mono/serif` (`patch_notes_card.dart`). |
| V. État simple et local | Respecté | `HomePage` garde `PatchNotes? patchNotes` dans son `State` et appelle `setState`. |
| VI. Tests de la logique et des widgets clés | Respecté en partie | `test/patch_notes/patch_notes_test.dart` couvre le calcul (3 tests). Pas de test de la carte ni de l'accueil (`test/home/` n'existe pas). |
| VII. Lisibilité, français, tutoiement | Respecté | Textes en français sans adresse directe à l'utilisateur ; commentaires « pourquoi » dans le modèle et la page d'accueil. |

Contraintes techniques : la constitution liste `http`, `shared_preferences`, `cached_network_image` ; `url_launcher` est une nouvelle dépendance, justifiée ici (voir Complexity Tracking).

## Project Structure

### Documentation (this feature)

```text
specs/006-carte-du-dernier-patch/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── patch-notes.md
├── checklists/
│   └── requirements.md
└── tasks.md
```

### Source Code (repository root)

```text
lib/
├── patch_notes/models/patch_notes.dart
└── home/
    ├── home_page.dart                                   # loadPatchNotes + carte
    └── widgets/patch_notes_card/patch_notes_card.dart

test/
└── patch_notes/patch_notes_test.dart

pubspec.yaml                                             # + url_launcher
```

**Structure Decision**: projet Flutter unique ; le modèle vit dans sa propre fonctionnalité `patch_notes` pour rester testable sans Flutter, la carte reste dans `home` car elle n'y sert qu'une fois.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Nouvelle dépendance `url_launcher` hors liste de la constitution (non justifiée dans un plan à l'époque) | Ouvrir une page web externe sur mobile et web | Aucune alternative n a laissé de trace dans le code ni les commits. La constitution n a pas été amendée pour lister la dépendance |
| Ligne d'import mal formée dans `lib/home/home_page.dart` : `import 'widgets/patch_notes_card/patch_notes_card.dart';import 'widgets/role_scroller/role_scroller.dart';` sur une seule ligne | Aucune : défaut de mise en forme (compile) | Séparer les deux imports ; non corrigé car hors périmètre documentaire |
| Pas de test de widget de `PatchNotesCard` / `HomePage` | La logique testable est dans `PatchNotes` | Injecter le lanceur d'URL pour tester le message d'échec |
