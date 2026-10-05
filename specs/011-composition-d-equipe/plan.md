# Implementation Plan: Composition d'équipe

**Branch**: `011-composition-d-equipe` (travail livré sur `main`) | **Date**: 2026-10-05 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/011-composition-d-equipe/spec.md`

## Summary

L'écran « Composition » (`TeamPage`) permet de placer cinq champions dans cinq rôles. Pour chaque champion, la fiche détaillée est téléchargée à part (jauges de Riot et description des sorts). `TeamAnalyzer.analyze` transforme la liste de membres en un `TeamAnalysis` : parts de dégâts physiques et magiques, nombre de champions de première ligne, nombre de sorts de contrôle (repérés par `CrowdControl` dans le texte des sorts) et une liste de constats. `DamageSplitBar` et `InsightTile` les affichent. Aucune persistance : l'équipe vit dans l'état de l'écran.

## Technical Context

**Language/Version**: Dart 3 (`sdk: ^3.13.3`), Flutter

**Primary Dependencies**: aucune ajoutée ; `ChampionService` (Data Dragon) pour la liste et les fiches, `MatchupService` (via `RoleFilters`) pour le filtre de rôle

**Storage**: N/A (état d'écran uniquement, rien n'est enregistré)

**Testing**: `flutter_test` ; analyse testée avec des fiches construites sur place, widgets testés sans réseau

**Target Platform**: mobile et web

**Project Type**: application mobile et web Flutter

**Performance Goals**: calcul instantané (5 champions) ; une fiche détaillée par champion, mise en cache dans l'écran

**Constraints**: nécessite le réseau (Data Dragon) pour la liste et les fiches, avec message d'erreur et « Réessayer » ; le filtre de rôle est facultatif

**Scale/Scope**: 1 écran, 3 widgets, 2 services de calcul, 3 modèles, 1 constante

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principe | Verdict | Preuve |
|----------|---------|--------|
| I. Organisation par fonctionnalité | Respecté avec réserve | `lib/team/{team_page.dart,constants,models,services,widgets/<nom>/<nom>.dart}`, un widget public par fichier. Réserve : `team_page.dart` importe `draft/draft_page.dart`, `draft/draft_history_page.dart` et `draft/models/draft_mode.dart` (pages d'une autre fonctionnalité, ajoutées après le premier commit pour les raccourcis de draft) ; `role_filters.dart` importe `shared/widgets/champion_picker_sheet/champion_role_filter.dart` (via shared, conforme). |
| II. Données Riot via Data Dragon, erreurs affichables | Respecté | `ChampionService.fetchAll` et `fetchDetail` ; erreurs par `userMessageFor` avec `ErrorRetryView` (liste) ou snackbar (fiche) ; un échec n'est pas mis en cache (la fiche manquante n'est pas dans `details`, donc redemandée). Aucune clé Riot. |
| III. Images via RemoteImage | Respecté | `lib/team/widgets/team_slot/team_slot.dart` utilise `RemoteImage` (portrait 40 px). |
| IV. Thème centralisé | Écart mineur | `AppColors`/`AppTheme` partout, mais `DamageSplitBar` (`_physicalColor`, `_magicColor`) et `InsightTile` (`_goodColor`, `_warningColor`) déclarent des `Color(0x…)` en dur, en `const`. Voir Complexity Tracking. |
| V. État simple et local | Respecté | `StatefulWidget` + `setState` ; pas de paquet d'état ; aucun contrôleur à libérer. |
| VI. Tests de la logique et des widgets clés | Respecté, avec une lacune | `test/team/team_analyzer_test.dart` (analyse et contrôle), `test/team/team_widgets_test.dart` (barre et constat), `test/team/role_filters_test.dart` (filtre). Aucun test d'écran de `TeamPage` (placer un champion, vider l'équipe) ni de `TeamSlot`. |
| VII. Lisibilité, commentaires, français | Écart mineur | Constantes nommées (`minDamageShare`, `frontlineDefense`, `minControlSpells`…), commentaires sur le pourquoi. Écart : textes de `team_analyzer.dart` au vouvoiement (« Ajoutez au moins trois champions… ») ; la constitution demande le tutoiement. |

## Project Structure

### Documentation (this feature)

```text
specs/011-composition-d-equipe/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── team-analyzer.md
├── tasks.md
└── checklists/
    └── requirements.md
```

### Source Code (repository root)

```text
lib/team/
├── team_page.dart                       # écran « Composition »
├── constants/team_roles.dart            # teamRoles, teamRoleLanes
├── models/
│   ├── team_insight.dart                # InsightKind, TeamInsight, TeamAnalysis
│   └── team_member.dart                 # TeamMember (champion + fiche)
├── services/
│   ├── team_analyzer.dart               # TeamAnalyzer.analyze
│   ├── crowd_control.dart               # CrowdControl (mots-clés des sorts)
│   └── role_filters.dart                # filtre de rôle de la feuille de choix
└── widgets/
    ├── damage_split_bar/damage_split_bar.dart
    ├── insight_tile/insight_tile.dart
    └── team_slot/team_slot.dart
test/team/
├── team_analyzer_test.dart
├── team_widgets_test.dart
└── role_filters_test.dart
```

**Structure Decision**: toute la logique d'évaluation est dans des méthodes statiques pures (`TeamAnalyzer`, `CrowdControl`) pour être testées sans widget ; `TeamPage` se limite aux choix et au téléchargement des fiches. `RoleFilters` et `team_roles.dart` sont réutilisés par les écrans de contre-picks, de points forts et de builds.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Principe IV : quatre couleurs de sens en dur (`DamageSplitBar`, `InsightTile`) | Couleurs sémantiques (physique, magique, vert, orange) identiques dans les deux thèmes, déclarées `const` | Les placer dans `AppColors` serait plus conforme ; non fait à la livraison. Dette légère. |
| Principe VII : vouvoiement dans les messages d'analyse | Texte écrit ainsi dès la livraison | Aucune justification dans le code ; à corriger. |
| Principe VI : pas de test d'écran de `TeamPage` | Les règles sont portées par `TeamAnalyzer` (testé) et les widgets d'affichage (testés) | Un test d'écran couvrirait le téléchargement des fiches et les erreurs ; l'injection des sources dans `TeamPage` est prête dans l'arbre de travail mais aucun test n'existe encore. |
