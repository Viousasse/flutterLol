# Implementation Plan: Outil de mise à jour des matchups

**Branch**: `019-outil-de-mise-a-jour-des-matchups` (travail livré sur `main`) | **Date**: 2026-09-16 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/019-outil-de-mise-a-jour-des-matchups/spec.md`

## Summary

Un script Dart en ligne de commande (`tool/generate_matchups.dart`) interroge l'API Riot (league-v4, match-v5), compte les victoires voie par voie et écrit `assets/data/champion_matchups.json`, que l'application embarque et lit sans réseau. La logique pure (vieillissement, comparaison et fusion de patchs) est isolée dans `tool/matchup_tally.dart` pour être testée sans clé. Un guide (`tool/README.md`) décrit l'exploitation.

## Technical Context

**Language/Version**: Dart 3 (script exécuté avec `dart run`, SDK `^3.13.3`)

**Primary Dependencies**: bibliothèque standard seulement (`dart:io`, `dart:convert`, `dart:math`) ; aucune dépendance ajoutée

**Storage**: fichiers : données `assets/data/champion_matchups.json` (environ 2,1 Mo) et sauvegarde de progression `<sortie>.progress.json`

**Testing**: `flutter_test` sur `tool/matchup_tally.dart` (`test/tool/matchup_tally_test.dart`) ; tests de données sur le vrai fichier (`test/counters/counter_service_test.dart`, `test/matchups/matchup_section_test.dart`, `test/quiz/quiz_generator_test.dart`)

**Target Platform**: poste du mainteneur (Windows, macOS, Linux) pour l'outil ; mobile et web pour la lecture du fichier

**Project Type**: script d'outillage + donnée statique d'une application mobile

**Performance Goals**: environ 1 h pour 3 000 parties (limite de la clé)

**Constraints**: 100 requêtes par 2 minutes (l'outil s'arrête à 95 dans la fenêtre de 122 s) ; clé valable 24 h ; clé jamais écrite

**Scale/Scope**: 7 600 parties, environ 17 000 lignes de matchups, 173 champions

## Constitution Check

| Principe | Verdict | Preuve |
|----------|---------|--------|
| I. Organisation par fonctionnalité | Respecté | Scripts sous `tool/` comme le prévoit la section « Contraintes techniques » ; donnée sous `assets/data/`. |
| II. Données Riot, aucune clé embarquée | Respecté | `RIOT_API_KEY` lue dans l'environnement (`tool/generate_matchups.dart`) ; `tool/README.md` interdit de l'écrire dans un fichier ; recherche de `RGAPI-` dans le dépôt : uniquement des exemples `RGAPI-...`. L'application n'appelle pas l'API Riot : elle lit le fichier embarqué. L'outil appelle l'API Riot directement, sans passer par `DataDragonService` : c'est un script hors application, donc hors du périmètre de ce principe. |
| III. RemoteImage | Sans objet | Aucune image. |
| IV. Thème centralisé | Sans objet | Aucune interface. |
| V. État simple | Sans objet | Aucun état d'écran. |
| VI. Tests | Respecté pour la logique pure | `test/tool/matchup_tally_test.dart` (13 tests). Les appels réseau, la reprise et le rendu ne sont pas testés (voir Complexity Tracking). |
| VII. Français, commentaires utiles | Respecté | Commentaires et guide en français qui expliquent le pourquoi (écriture atomique, patch illisible conservé…). |

**Contraintes techniques** : « données statiques volumineuses générées par les scripts de `tool/` et embarquées sous `assets/data/` ; l'application ne recalcule jamais ces données au lancement » : respecté (`MatchupService` lit l'asset ; asset déclaré dans `pubspec.yaml`).

## Project Structure

### Documentation (this feature)

```text
specs/019-outil-de-mise-a-jour-des-matchups/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── cli.md
│   └── matchups-file.md
├── checklists/
│   └── requirements.md
└── tasks.md
```

### Source Code (repository root)

```text
tool/
├── generate_matchups.dart     # point d'entrée, client Riot, progression, rendu
├── matchup_tally.dart         # logique pure testée
└── README.md                  # guide d'exploitation

assets/data/champion_matchups.json   # sortie embarquée

lib/matchups/
├── models/matchup.dart                 # MatchupDataset.fromJson
└── services/matchup_service.dart       # lecture de l'asset, seuil de 8 parties

test/
├── tool/matchup_tally_test.dart
├── counters/counter_service_test.dart  # vrai fichier
├── matchups/matchup_service_test.dart
├── matchups/matchup_section_test.dart  # vrai fichier
└── quiz/quiz_generator_test.dart       # vrai fichier
```

**Structure Decision**: script autonome dans `tool/`, sans dépendance sur le code de l'application, pour tourner avec `dart run` sans Flutter.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Pas de test automatique de `tool/generate_matchups.dart` (réseau, reprise, écriture). | Le script dépend de l'API Riot et d'une clé de 24 h. | Un faux client HTTP aurait été possible mais n'a pas été écrit : lacune assumée, la logique pure est testée à part. |
