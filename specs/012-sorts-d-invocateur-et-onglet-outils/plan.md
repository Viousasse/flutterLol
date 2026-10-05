# Implementation Plan: Sorts d'invocateur conseillés et onglet Outils

**Branch**: `012-sorts-d-invocateur-et-onglet-outils` (travail livré sur `main`) | **Date**: 2026-10-05 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/012-sorts-d-invocateur-et-onglet-outils/spec.md`

## Summary

Deux apports indépendants. (1) Les sorts d'invocateur conseillés : `SummonerSpellService` télécharge `summoner.json` de Data Dragon (partie classique seulement), `SummonerSpellRecommender` choisit deux sorts et une raison d'après la voie principale du champion (`MatchupService.mainLaneOf`) puis son profil, et `SummonerSpellSection` les affiche sur la fiche du champion. (2) L'onglet Outils : `MainNavigation` gagne une sixième destination qui ouvre `ToolsPage`, laquelle affiche `ToolsSection`, une grille de tuiles qui ouvrent contre-picks, points forts, composition, comparaison et builds. `ToolsSection` avait d'abord été placée sur l'accueil (`a96b9d2`) puis déplacée dans l'onglet (`a4475d7`).

## Technical Context

**Language/Version**: Dart 3 (`sdk: ^3.13.3`), Flutter

**Primary Dependencies**: aucune ajoutée ; `DataDragonService` pour `summoner.json` ; `MatchupService` pour la voie principale

**Storage**: aucun stockage propre ; cache mémoire des sorts (`SummonerSpellService._cache`) ; `DataDragonService.fetchJson` garde le fichier pour le hors-ligne sous la clé `summoners`

**Testing**: `flutter_test` ; recommandeur et modèle testés en pur Dart ; barre de navigation testée en widget

**Target Platform**: mobile et web

**Project Type**: application mobile et web Flutter

**Performance Goals**: un seul téléchargement de `summoner.json` par exécution, quel que soit le nombre de fiches ouvertes

**Constraints**: les sorts sont un bonus (échec silencieux) ; onglets non visités non construits (aucun téléchargement au démarrage pour les onglets jamais ouverts)

**Scale/Scope**: 3 fichiers de logique, 1 widget de fiche, 1 page, 1 section d'outils, 1 destination de navigation

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principe | Verdict | Preuve |
|----------|---------|--------|
| I. Organisation par fonctionnalité | Respecté | `lib/summoner_spells/{models,services}`, `lib/tools/{tools_page.dart,widgets/tools_section/tools_section.dart}`, `lib/main_navigation/{main_navigation.dart,widgets/app_nav_bar/app_nav_bar.dart}`, widget de fiche dans `lib/champion_detail/widgets/summoner_spell_section/summoner_spell_section.dart`. `ToolsSection` importe les pages d'autres fonctionnalités (compteurs, points forts, composition, comparaison, builds) : c'est un hub de navigation qui n'utilise que leurs pages publiques, pas leurs widgets internes. |
| II. Données Riot via Data Dragon, erreurs affichables | Respecté, avec une exception voulue | `SummonerSpellService` passe par `DataDragonService.latestVersion` et `fetchJson` (délai, version, secours hors-ligne `offlineKey: 'summoners'`, validation `hasDataMap`). Le cache n'est rempli qu'après un parsing réussi et `_pending` est vidé dans `finally` (échec non mis en cache). L'exception : l'erreur n'est pas affichée à l'utilisateur, la section est omise (bonus assumé, commentaire de `loadSummonerSpells`). |
| III. Images via RemoteImage | Respecté | `SummonerSpellSection` : `RemoteImage` en 44 px. L'URL de l'icône est construite dans `SummonerSpell.fromJson` comme les autres modèles du projet (`champion.dart`, `item.dart`). |
| IV. Thème centralisé | Respecté | `AppColors`, `AppTheme`, `AppFonts` uniquement dans `lib/tools`, `lib/main_navigation`, `summoner_spell_section.dart`. |
| V. État simple et local | Respecté | `StatefulWidget` + `setState` (`MainNavigation`, fiche champion) ; `visitedTabs` (ensemble d'index) + `IndexedStack`. Aucun paquet d'état. |
| VI. Tests de la logique et des widgets clés | Respecté, avec lacunes | `test/summoner_spells/summoner_spell_recommender_test.dart` (recommandeur, lecture JSON, filtre classique) et `test/main_navigation/app_nav_bar_test.dart` (barre). Pas de test pour `SummonerSpellService`, `SummonerSpellSection`, `ToolsPage`/`ToolsSection` ni `MainNavigation` (initialisation paresseuse des onglets). Voir Complexity Tracking. |
| VII. Lisibilité, commentaires, français | Écart mineur | Constantes nommées (identifiants de sorts, `_classicMode`), commentaires sur le pourquoi. Écart : textes au vouvoiement (« Préparez votre partie », « Épuisement protège votre allié… ») alors que la constitution demande le tutoiement. |

## Project Structure

### Documentation (this feature)

```text
specs/012-sorts-d-invocateur-et-onglet-outils/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── summoner-spells.md
│   └── tools-and-navigation.md
├── tasks.md
└── checklists/
    └── requirements.md
```

### Source Code (repository root)

```text
lib/
├── summoner_spells/
│   ├── models/summoner_spell.dart                      # SummonerSpell
│   └── services/
│       ├── summoner_spell_service.dart                 # téléchargement + cache
│       └── summoner_spell_recommender.dart             # SummonerSpellPlan, recommend
├── champion_detail/
│   ├── champion_detail_page.dart                       # chargement et section « Sorts d'invocateur »
│   └── widgets/summoner_spell_section/summoner_spell_section.dart
├── tools/
│   ├── tools_page.dart                                 # onglet « Outils »
│   └── widgets/tools_section/tools_section.dart        # tuiles d'outils
├── main_navigation/
│   ├── main_navigation.dart                            # six destinations, IndexedStack
│   └── widgets/app_nav_bar/app_nav_bar.dart            # barre du bas
└── home/home_page.dart                                 # section Outils retirée
test/
├── summoner_spells/summoner_spell_recommender_test.dart
└── main_navigation/app_nav_bar_test.dart
```

**Structure Decision**: la décision de conseil est une fonction pure (`SummonerSpellRecommender.recommend`) séparée du téléchargement pour être testée sans réseau ; la fiche champion orchestre les deux. `ToolsSection` est un widget partagé de l'onglet : une liste constante d'outils, une tuile par outil.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Principe VI : pas de test de `SummonerSpellService`, `SummonerSpellSection`, `ToolsPage`, `ToolsSection`, `MainNavigation` | La logique de décision et la barre, qui portent les règles, sont testées | Un test du service (futur en cours mis en cache, échec non mis en cache) et un test d'écran de l'onglet seraient possibles ; non écrits, dette à combler. |
| Principe VII : vouvoiement dans les textes de l'onglet et des raisons de sorts | Texte écrit ainsi dès la livraison | Aucune justification dans le code ; à corriger. |
