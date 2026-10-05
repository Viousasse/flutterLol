# Implementation Plan: Entraîneur de draft

**Branch**: `015-entraineur-de-draft` (livré sur `main`) | **Date**: 2026-10-05 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/015-entraineur-de-draft/spec.md`

## Summary

Une page `DraftPage` fait jouer une draft de cinq rôles contre un adversaire simulé (`DraftBot`), avec une phase optionnelle de bannissements, puis compare les deux drafts (`DraftEvaluator`, `BanAnalyzer`) et affiche un bilan (`DraftReportView`). Un conseiller déterministe (`DraftAdvisor`) propose trois champions au joueur quand l'aide au choix est active. L'état d'une draft est un objet immuable (`DraftState`) ; la page ne contient que l'orchestration (tour par tour, attente du site, analyse, enregistrement dans l'historique).

## Technical Context

**Language/Version**: Dart 3 / Flutter SDK `^3.13`

**Primary Dependencies**: `flutter` (Material), `shared_preferences` (indirectement, par l'historique de la 017) ; `http` et `cached_network_image` via `ChampionService` et `RemoteImage`. Aucune dépendance ajoutée par cette fonctionnalité.

**Storage**: aucun stockage propre aux réglages ; la draft jugée est confiée à `DraftHistoryStore` (017, `shared_preferences`). Données de matchups : fichier embarqué `assets/data/champion_matchups.json`, lu par `MatchupService.load`.

**Testing**: `flutter_test` (tests unitaires des services et du modèle, tests de widget de la page avec chargeurs injectés, aucun accès réseau)

**Target Platform**: mobile et web

**Project Type**: application mobile/web Flutter (projet unique)

**Performance Goals**: aucun objectif chiffré ; le site « réfléchit » 900 ms (`_botThinkingDelay`) pour que la draft reste lisible ; l'analyse télécharge dix fiches de champion en parallèle (`Future.wait`).

**Constraints**: les matchups sont embarqués donc le bilan ne dépend pas du réseau, mais la liste des champions et les fiches viennent de Data Dragon (repli hors-ligne de la 002) ; interface en français ; le site doit pouvoir jouer même avec des données lacunaires.

**Scale/Scope**: 5 rôles × 2 camps, 10 bannissements, 3 modèles, 4 services, 5 widgets et la page (`draft_page.dart`, 967 lignes avec la part du mode à deux) ; `lib/draft` compte ~3 600 lignes en tout, historique, partage et mode à deux compris.

## Constitution Check

| Principe | Verdict | Preuve |
|----------|---------|--------|
| I. Organisation par fonctionnalité | Respecté | `lib/draft/` (page, `models/`, `services/`, `widgets/<nom>/<nom>.dart`) ; un seul widget public par fichier (les classes privées `_TeamColumn`, `_StatusCard`… restent dans `draft_page.dart`). `LaneProfile`, partagé avec cinq autres écrans, vit dans `lib/matchups/services/lane_profile.dart` (déplacé depuis `lib/draft/services/` au commit `0afb3b1`). Le filtre de rôle passe par `lib/shared/widgets/champion_picker_sheet/`. |
| II. Données Riot / erreurs affichables | Respecté | `lib/draft/draft_page.dart` : `ChampionService.fetchAll` / `fetchDetail` (donc `DataDragonService`), échec converti par `userMessageFor`, affiché par `ErrorRetryView` avec `retry` et `analyse` comme actions. Aucun échec mis en cache. |
| III. Images via RemoteImage | Respecté | `draft_slot.dart`, `ban_row.dart`, `suggestion_card.dart` utilisent `RemoteImage` ; aucune image réseau en direct. |
| IV. Thème centralisé | Entorse mineure | `lib/draft/widgets/criterion_tile/criterion_tile.dart` écrit en dur `_goodColor = Color(0xFF3F9E5A)` et `_badColor = Color(0xFFD08A1E)` (vert et orange du verdict). Le reste vient de `AppColors`, `AppTheme.serif`, `AppTheme.mono` (voir Complexity Tracking). |
| V. État simple et local | Respecté | `StatefulWidget` + `setState` dans `lib/draft/draft_page.dart` ; `DraftState` immuable (`lib/draft/models/draft_state.dart`) ; numéro de `generation` pour ignorer un tour du site périmé. `dispose` retire l'écouteur de session (016). |
| VI. Tests | Respecté | `test/draft/` : `draft_state_test`, `draft_ban_test`, `draft_bot_test`, `draft_evaluator_test`, `ban_analyzer_test`, `draft_advisor_test`, `draft_report_view_test`, `suggestion_card_test`, `draft_page_flow_test`, `draft_page_advice_test`, `draft_a11y_test` avec données construites par `test/draft/draft_support.dart`. Pas de test dédié à `DraftSlot`, `BanRow`, `CriterionTile` (couverts par les tests de page et du bilan). |
| VII. Lisibilité, français | Entorse | Commentaires qui expliquent le pourquoi, constantes nommées (`counterWeight`, `winRateWeight`, `laneWinThreshold`…) ; mais l'interface **vouvoie** (« À vous de choisir », « Choisissez un champion », « prenez un mage ») au lieu de tutoyer (voir Complexity Tracking). |

## Project Structure

### Documentation (this feature)

```text
specs/015-entraineur-de-draft/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── draft-services.md
├── checklists/
│   └── requirements.md
└── tasks.md
```

### Source Code (repository root)

```text
lib/draft/
├── draft_page.dart                       # DraftPage : orchestration, réglages, board, résultat
├── models/
│   ├── draft_state.dart                  # DraftSide, ordres, DraftState immuable
│   ├── draft_report.dart                 # DraftCriterion, DraftPlayers, DraftReport
│   └── draft_mode.dart                   # DraftMode (vsSite / vsFriend, voir 016)
├── services/
│   ├── draft_bot.dart                    # DraftBot : choix et bannissement du site
│   ├── draft_evaluator.dart              # DraftEvaluator : comparaison et conseils
│   ├── ban_analyzer.dart                 # BanAnalyzer : jugement des bannissements
│   └── draft_advisor.dart                # DraftAdvisor : conseils « Aide au choix »
└── widgets/
    ├── draft_slot/draft_slot.dart
    ├── ban_row/ban_row.dart
    ├── criterion_tile/criterion_tile.dart
    ├── draft_report_view/draft_report_view.dart
    └── suggestion_card/suggestion_card.dart

lib/matchups/services/lane_profile.dart   # LaneProfile (partagé)

test/draft/
├── draft_support.dart
├── draft_state_test.dart, draft_ban_test.dart
├── draft_bot_test.dart, draft_evaluator_test.dart
├── ban_analyzer_test.dart, draft_advisor_test.dart
├── draft_report_view_test.dart, suggestion_card_test.dart
├── draft_page_flow_test.dart, draft_page_advice_test.dart
└── draft_a11y_test.dart
```

**Structure Decision**: la logique (barème du site, comparaison, conseils) est dans des services purs sans Flutter, testables sans écran ; la page ne fait que relier les services au jeu tour par tour. Le déplacement de `LaneProfile` vers `matchups` vient de son usage par d'autres écrans (contre-picks, points forts…).

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Vouvoiement dans les textes de la draft (principe VII demande le tutoiement) | Aucune justification écrite : le ton a été posé dès le premier commit (`d260ea6`) et conservé partout (bilan, statut, conseils, boîtes de dialogue de la 016). | Non justifié ; entorse reconnue, à traiter en bloc (textes de `draft_page.dart`, `draft_evaluator.dart`, `ban_analyzer.dart`, `draft_advisor.dart`, widgets). |
| Deux couleurs en dur dans `criterion_tile.dart` (principe IV) | Vert « avantage » et orange « avantage au site » sans équivalent dans `AppColors` au moment du commit. | Les ajouter à `AppPalette` aurait demandé deux valeurs par mode (clair/sombre) ; aucune trace écrite de la décision, entorse non justifiée dans le code. |
| `draft_page.dart` (967 lignes, dont les fonctions de la 016) | Les réglages, le tour du site, l'analyse et le mode à deux partagent le même état. | Aucun principe de la constitution ne fixe une limite ; l'extraction (controller séparé) n'a pas été faite. |
