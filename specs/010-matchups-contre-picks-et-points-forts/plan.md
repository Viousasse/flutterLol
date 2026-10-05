# Implementation Plan: Matchups, contre-picks et points forts

**Branch**: `010-matchups-contre-picks-et-points-forts` (travail livré sur `main`) | **Date**: 2026-10-05 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/010-matchups-contre-picks-et-points-forts/spec.md`

## Summary

Deux écrans de conseil, « Contre-picks » (qui jouer contre ce champion) et « Points forts » (contre qui mon champion est fort ou faible), reposent sur un fichier de matchups embarqué (`assets/data/champion_matchups.json`, 7 600 parties Master+ EUW) lu par `MatchupService`. `CounterService` fait tout le calcul : agrégation par champion, classement déterministe, seuil de fiabilité à 8 parties, repli sur des bilans peu fiables classés par taux tempéré (`smoothedWinRate`) pour ne jamais renvoyer une liste vide. Une note commune (`DataSourceNote`) dit d'où viennent les chiffres, une barre de voies (`LaneFilterBar`) restreint les résultats, et la fiche d'un champion ouvre les deux écrans avec le champion déjà choisi. Le fichier de données est produit par `tool/generate_matchups.dart` (spécification 019, hors de ce plan).

## Technical Context

**Language/Version**: Dart 3 (`sdk: ^3.13.3`), Flutter

**Primary Dependencies**: aucune dépendance ajoutée ; `flutter/services.dart` (`rootBundle`) pour lire l'asset, `dart:convert`

**Storage**: fichier embarqué en lecture seule `assets/data/champion_matchups.json` (déclaré dans `pubspec.yaml`, 2,1 Mo, 17 284 lignes de matchups, 173 champions) ; mis en cache mémoire dans `MatchupService`. Aucune préférence persistée.

**Testing**: `flutter_test` ; services testés avec des jeux de données construits sur place et avec le vrai fichier ; pages testées avec des sources injectées (aucun réseau)

**Target Platform**: mobile et web

**Project Type**: application mobile et web Flutter

**Performance Goals**: classement calculé à l'affichage sur au plus quelques milliers de lignes par champion ; pas de calcul au lancement de l'application

**Constraints**: hors-ligne par construction (fichier embarqué) ; aucune clé Riot dans l'application ; classement stable (mêmes entrées, même ordre)

**Scale/Scope**: 2 écrans, 3 widgets partagés (`CounterTile`, `LaneFilterBar`, `DataSourceNote`), 2 services (`MatchupService`, `CounterService`), 4 modèles

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principe | Verdict | Preuve |
|----------|---------|--------|
| I. Organisation par fonctionnalité | Respecté avec réserves | `lib/matchups/{models,services,constants}`, `lib/counters/{counters_page.dart,models,services}`, `lib/strengths/strengths_page.dart` ; widgets réutilisables dans `lib/shared/widgets/{counter_tile,lane_filter_bar,data_source_note}`. Réserves : `CounterTile` (shared) importe `counters/models/counter_pick.dart`, et `StrengthsPage` importe `CounterService` et `CounterPick` de `lib/counters/` ; ce sont des services et modèles, pas des widgets internes, donc conforme à la règle « par `shared/` ou par un modèle ». |
| II. Données Riot via Data Dragon, erreurs affichables | Respecté | Aucun appel réseau propre : les matchups viennent d'un asset. Les champions passent par `ChampionService` (Data Dragon). Les erreurs ressortent par `userMessageFor` et `ErrorRetryView` (`counters_page.dart`, `strengths_page.dart`). `MatchupService._load` vide `_pending` dans `finally` et ne met en cache que le succès. Aucune clé Riot embarquée : l'outil la lit dans `RIOT_API_KEY`. |
| III. Images via RemoteImage | Respecté | `CounterTile` et les sélecteurs de champion utilisent `RemoteImage` ; portraits de 44 et 52 px via `champion.imageUrl`. |
| IV. Thème centralisé | Écart mineur | `AppColors` et `AppTheme` partout, sauf `_winningColor = Color(0xFF6FBF73)` et `_cautionColor = Color(0xFFD08A1E)` écrits en dur dans `lib/shared/widgets/counter_tile/counter_tile.dart` (couleurs de sens vert/orange, constantes `const`). Voir Complexity Tracking. |
| V. État simple et local | Respecté | `StatefulWidget` + `setState` dans les deux pages ; aucun paquet d'état ; aucun contrôleur à libérer. Pas d'état partagé. |
| VI. Tests de la logique et des widgets clés | Respecté | `test/counters/counter_service_test.dart` (21 tests), `test/matchups/matchup_service_test.dart`, `test/matchups/main_lane_test.dart`, `test/shared/widgets/data_source_note_test.dart`, `test/counters/counters_page_test.dart`, `test/strengths/strengths_page_test.dart`. `LaneFilterBar` n'a pas de fichier de test propre : il est exercé via `test/shared/widgets/app_filter_chip_test.dart` et via les tests de pages (« le filtre de voie restreint la liste »). `CounterTile` n'est testé qu'à travers les pages. Les tests de pages sont des fichiers non commités au moment de la rédaction (tâche T14). |
| VII. Lisibilité, commentaires, français | Écart mineur | Noms en anglais, constantes nommées (`minGames`, `maxPicks`, `priorGames`…), commentaires sur le pourquoi. Écart : textes de `counters_page.dart` et `strengths_page.dart` au vouvoiement (« Choisissez… ») alors que la constitution demande le tutoiement. |

## Project Structure

### Documentation (this feature)

```text
specs/010-matchups-contre-picks-et-points-forts/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── matchup-data-file.md
│   ├── matchup-service.md
│   └── counter-service.md
├── tasks.md
└── checklists/
    └── requirements.md
```

### Source Code (repository root)

```text
assets/data/champion_matchups.json                 # données embarquées
lib/
├── matchups/
│   ├── constants/lane_labels.dart                 # libellés des voies
│   ├── models/matchup.dart                        # Matchup, MatchupDataset, OverallRecord
│   └── services/
│       ├── matchup_service.dart                   # chargement + requêtes par champion
│       └── lane_profile.dart                      # où se joue chaque champion
├── counters/
│   ├── counters_page.dart                         # écran « Contre-picks »
│   ├── models/counter_pick.dart                   # CounterPick, smoothedWinRate
│   └── services/counter_service.dart              # classement, repli, voies
├── strengths/strengths_page.dart                  # écran « Points forts »
├── shared/widgets/
│   ├── counter_tile/counter_tile.dart
│   ├── lane_filter_bar/lane_filter_bar.dart
│   └── data_source_note/data_source_note.dart
├── champion_detail/champion_detail_page.dart      # liens vers les deux écrans
└── tools/widgets/tools_section/tools_section.dart # entrées « Contre-picks » et « Points forts »
test/
├── counters/{counter_service_test.dart, counters_page_test.dart, counter_pages_support.dart}
├── strengths/strengths_page_test.dart
├── matchups/{matchup_service_test.dart, main_lane_test.dart, matchup_section_test.dart}
└── shared/widgets/{data_source_note_test.dart, app_filter_chip_test.dart}
```

**Structure Decision**: la logique est dans `CounterService` (méthodes statiques pures sur un `MatchupDataset`) pour être testable sans widget ni asset ; les pages ne font que charger, filtrer par voie et afficher. `tool/` n'est pas documenté ici (spécification 019).

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Principe IV : deux couleurs en dur dans `CounterTile` (vert de victoire, orange de prudence) | Ce sont des couleurs de sens, identiques en mode clair et sombre, et le code les nomme et les déclare `const` ; la coordination du projet les tolère (« couleurs de sens existantes ») | Les ajouter à `AppColors` serait plus conforme ; ce n'a pas été fait dans la livraison. Dette légère. |
| Principe VII : vouvoiement dans les textes des deux écrans | Texte écrit ainsi dès la livraison | Aucune justification dans le code ; à corriger pour tutoyer (« Choisis le champion que tu vas affronter… »). |
