# Implementation Plan: Galerie des apparences d'un champion

**Branch**: `007-galerie-des-apparences` (travail livré sur `main`) | **Date**: 2026-10-05 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/007-galerie-des-apparences/spec.md`

**Note**: plan rédigé après coup d'après le commit `400a75c`.

## Summary

Lire la liste `skins` de la fiche détaillée Data Dragon (`ChampionSkin.listFromJson`), l'afficher en galerie horizontale sur la fiche du champion (`SkinGallery`) et ouvrir un visualiseur plein écran à pages glissantes avec zoom (`SkinViewerPage`).

## Technical Context

**Language/Version**: Dart 3 / Flutter, SDK `^3.13.3`

**Primary Dependencies**: aucune ajoutée ; `RemoteImage` (qui s'appuie sur `cached_network_image`), `DataDragonService` via `ChampionService.fetchDetail`

**Storage**: N/A

**Testing**: `flutter_test` — `test/champions/models/champion_skin_test.dart`

**Target Platform**: mobile et web (glisser, pincer, flèches cliquables)

**Project Type**: application mobile/web Flutter, projet unique

**Performance Goals**: vignettes légères (`loading`) pour la liste, grande illustration (`splash`) seulement dans le visualiseur ; les pages du `PageView` sont construites à la demande.

**Constraints**: les adresses d'illustration sont construites localement à partir du nom et du numéro (pas de version de jeu dans l'adresse).

**Scale/Scope**: 1 modèle, 1 widget de galerie, 1 page de visualiseur, 1 branchement dans la fiche.

## Constitution Check

| Principe | Verdict | Preuve / remarque |
|----------|---------|-------------------|
| I. Organisation par fonctionnalité | Respecté | Modèle `lib/champions/models/champion_skin.dart`, widget `lib/champion_detail/widgets/skin_gallery/skin_gallery.dart`, page `lib/champion_detail/skin_viewer_page.dart`. Un widget public par fichier. |
| II. Données Riot via Data Dragon, erreurs affichables | Respecté avec nuance | La liste vient de la fiche détaillée déjà chargée par `ChampionService` (erreurs gérées par la fiche). Les adresses d'images sont construites dans `ChampionSkin` (`_baseUrl` du CDN `cdn/img/champion`) sans passer par `DataDragonService` : ce ne sont pas des appels d'API mais des images. |
| III. Images uniquement via RemoteImage | Respecté | `skin_gallery.dart` et `skin_viewer_page.dart` utilisent `RemoteImage` ; source choisie selon la taille : `loadingUrl` (120×190) pour les vignettes, `splashUrl` en plein écran. |
| IV. Thème centralisé | Entorse mineure | `skin_viewer_page.dart` écrit `Colors.black`, `Colors.white`, `Colors.white70` (voir Complexity Tracking). Le reste utilise `AppColors`/`AppTheme`. |
| V. État simple et local | Respecté | `StatefulWidget` + `setState` ; le `PageController` est libéré dans `dispose` (`skin_viewer_page.dart`). |
| VI. Tests de la logique et des widgets clés | Respecté en partie | `champion_skin_test.dart` (4 tests : chromas, nom d'origine, adresses, liste absente). Pas de test de widget pour la galerie ni le visualiseur. |
| VII. Lisibilité, français, tutoiement | Respecté | Textes en français sans adresse directe (« Apparences », « Apparence précédente »), commentaires « pourquoi » (chromas, tailles d'images). |

## Project Structure

### Documentation (this feature)

```text
specs/007-galerie-des-apparences/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── champion-skin.md
├── checklists/
│   └── requirements.md
└── tasks.md
```

### Source Code (repository root)

```text
lib/
├── champions/models/
│   ├── champion_skin.dart
│   └── champion_detail.dart                             # + skins
├── champion_detail/
│   ├── champion_detail_page.dart                        # section « Apparences (n) »
│   ├── skin_viewer_page.dart
│   └── widgets/skin_gallery/skin_gallery.dart

test/
└── champions/models/champion_skin_test.dart
```

**Structure Decision**: projet Flutter unique ; le visualiseur est une page de la fonctionnalité `champion_detail` (à la racine du dossier, comme les autres pages), la galerie est son widget.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Principe IV : `Colors.black`/`Colors.white`/`white70` dans `lib/champion_detail/skin_viewer_page.dart` | Vue immersive : fond noir sous l'illustration quel que soit le thème | Utiliser `AppColors.background` serait blanc en mode clair ; aucune justification n'est écrite dans le code, c'est le raisonnement retenu a posteriori |
| Principe VI : pas de test de widget pour `SkinGallery` et `SkinViewerPage` | La logique (chromas, adresses) est testée dans le modèle | Tests de widget avec `RemoteImage` : pump répétés (voir `docs/agents/COORDINATION.md` §3.5) |
