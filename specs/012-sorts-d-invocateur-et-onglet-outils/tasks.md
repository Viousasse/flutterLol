---
description: "Liste de tâches de la fonctionnalité 012 (rédigée après coup, tout est livré)"
---

# Tasks: Sorts d'invocateur conseillés et onglet Outils

**Input**: Design documents from `/specs/012-sorts-d-invocateur-et-onglet-outils/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: les tests sont inclus (principe VI de la constitution).

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup

- [x] T001 Créer `lib/summoner_spells/{models,services}`, `lib/tools/widgets/tools_section` et `test/summoner_spells/`

## Phase 2: Foundational

- [x] T002 [P] Modèle `SummonerSpell` (lecture JSON, filtre `isClassic`) dans `lib/summoner_spells/models/summoner_spell.dart`
- [x] T003 Voie principale d'un champion (`mainLaneOf`, seuil de 30 parties) dans `lib/matchups/services/matchup_service.dart`
- [x] T004 [P] Test de la voie principale dans `test/matchups/main_lane_test.dart`

## Phase 3: User Story 1 - Sorts d'invocateur sur la fiche (Priority: P1) MVP

**Goal**: section « Sorts d'invocateur » sur la fiche d'un champion.

**Independent Test**: quickstart.md, scénarios 6 à 9.

- [x] T005 [P] [US1] Table de décision `SummonerSpellRecommender` et `SummonerSpellPlan` dans `lib/summoner_spells/services/summoner_spell_recommender.dart`
- [x] T006 [P] [US1] Téléchargement et cache des sorts (`fetchAll`, `byIds`) dans `lib/summoner_spells/services/summoner_spell_service.dart`
- [x] T007 [P] [US1] Widget `SummonerSpellSection` dans `lib/champion_detail/widgets/summoner_spell_section/summoner_spell_section.dart`
- [x] T008 [US1] Charger et afficher la section, échec silencieux, dans `lib/champion_detail/champion_detail_page.dart` (`loadSummonerSpells`)
- [x] T009 [P] [US1] Tests du recommandeur (jungle, tireur en bas, haut, soutien, voie inconnue, sans tag, deux sorts et une raison par plan) dans `test/summoner_spells/summoner_spell_recommender_test.dart`
- [x] T010 [P] [US1] Tests du modèle (lecture JSON, filtre de la partie classique) dans `test/summoner_spells/summoner_spell_recommender_test.dart`

## Phase 4: User Story 2 - Onglet Outils (Priority: P1)

**Goal**: sixième destination de la barre de navigation.

**Independent Test**: quickstart.md, scénarios 1, 2 et 4.

- [x] T011 [P] [US2] Page `ToolsPage` dans `lib/tools/tools_page.dart`
- [x] T012 [US2] Ajouter la destination « Outils » et la construction paresseuse de l'onglet dans `lib/main_navigation/main_navigation.dart`
- [x] T013 [P] [US2] Barre `AppNavBar` avec icônes, trait de l'onglet actif et sémantique dans `lib/main_navigation/widgets/app_nav_bar/app_nav_bar.dart`
- [x] T014 [P] [US2] Tests de la barre (icône et libellé par destination, onglet touché, onglet actif annoncé) dans `test/main_navigation/app_nav_bar_test.dart`

## Phase 5: User Story 3 - Tuiles d'outils (Priority: P2)

**Goal**: cinq tuiles qui ouvrent les outils ; retrait de la section de l'accueil.

**Independent Test**: quickstart.md, scénarios 2, 3 et 5.

- [x] T015 [US3] Section `ToolsSection` (liste d'outils, tuiles sur deux colonnes, sémantique) dans `lib/tools/widgets/tools_section/tools_section.dart`
- [x] T016 [US3] Retirer la section Outils de l'accueil dans `lib/home/home_page.dart`
- [x] T017 [US3] Ajouter les entrées « Contre-picks » et « Points forts » dans `lib/tools/widgets/tools_section/tools_section.dart` (spécification 010)

## Phase 6: Polish

- [x] T018 Vérification manuelle des scénarios de quickstart.md
