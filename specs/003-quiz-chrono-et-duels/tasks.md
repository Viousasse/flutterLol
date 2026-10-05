---

description: "Liste des tâches de la fonctionnalité 003, rédigée après coup d'après le code livré"
---

# Tasks: Quiz : chrono, historique des séries et duels

**Input**: Design documents from `/specs/003-quiz-chrono-et-duels/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: inclus (livrés avec le code ; la logique du chrono dans la page n'en a pas).

**Organization**: groupé par parcours. Commits : `412ea8f` (US1, US2), `0afb3b1` (US3).

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup (Shared Infrastructure)

- [x] T001 Vérifier que le quiz existait avec ses familles et son score dans `lib/quiz/quiz_page.dart` et `lib/quiz/services/quiz_generator.dart` (base préexistante)

---

## Phase 2: Foundational (Blocking Prerequisites)

- [x] T002 Ajouter le paramètre `timedOut` à `QuizQuestionCard` pour afficher « Temps écoulé : … » dans `lib/quiz/widgets/quiz_question_card/quiz_question_card.dart`
- [x] T003 [P] Réutiliser la couleur de sens `quizWrongColor`, déjà définie dans `lib/quiz/widgets/quiz_answer_button/quiz_answer_button.dart`, pour la barre rouge

**Checkpoint**: la carte de question sait afficher une expiration.

---

## Phase 3: User Story 1 - Jouer contre la montre (Priority: P1) 🎯 MVP

**Goal**: mode chrono de 15 secondes.

**Independent Test**: `flutter test test/quiz/quiz_timer_bar_test.dart` et quickstart.md, étapes 2 à 5.

### Tests for User Story 1

- [x] T004 [P] [US1] Tests de la barre (secondes, rouge sous 5 s) dans `test/quiz/quiz_timer_bar_test.dart`

### Implementation for User Story 1

- [x] T005 [P] [US1] Créer `QuizTimerBar` (barre, nombre, `urgentSeconds`, sémantique) dans `lib/quiz/widgets/quiz_timer_bar/quiz_timer_bar.dart`
- [x] T006 [US1] Ajouter l'état chrono, `Timer.periodic`, `_tick`, `_expire`, la puce « Chrono 15 s » et la pause par `TickerMode` dans `lib/quiz/quiz_page.dart`
- [x] T007 [US1] Libérer le minuteur dans `dispose` et l'arrêter à chaque réponse dans `lib/quiz/quiz_page.dart`

**Checkpoint**: le quiz se joue contre la montre.

---

## Phase 4: User Story 2 - Historique des séries (Priority: P2)

**Goal**: mémoriser les dernières séries terminées.

**Independent Test**: `flutter test test/quiz/quiz_score_service_test.dart`

### Tests for User Story 2

- [x] T008 [P] [US2] Tests de l'historique (ordre, zéro ignoré, borne) dans `test/quiz/quiz_score_service_test.dart`

### Implementation for User Story 2

- [x] T009 [US2] Ajouter `recentStreaks`, `maxRecentStreaks`, `recordFinished` et la file d'écriture dans `lib/quiz/services/quiz_score_service.dart`
- [x] T010 [P] [US2] Créer `QuizHistory` dans `lib/quiz/widgets/quiz_history/quiz_history.dart`
- [x] T011 [US2] Enregistrer la série terminée à une mauvaise réponse ou à l'expiration, et afficher `QuizHistory` dans `lib/quiz/quiz_page.dart`

---

## Phase 5: User Story 3 - La catégorie « Duels » (Priority: P2)

**Goal**: questions « Qui bat qui ? » fiables.

**Independent Test**: `flutter test test/quiz/matchup_quiz_test.dart`

### Tests for User Story 3

- [x] T012 [P] [US3] Tests des duels (11 cas : écart, seuil de parties, deux choix, chiffres dans l'explication, graine, doublons, masquage) dans `test/quiz/matchup_quiz_test.dart`
- [x] T013 [P] [US3] Adapter les tests du générateur à la nouvelle famille dans `test/quiz/quiz_generator_test.dart`
- [x] T014 [P] [US3] Test de la famille masquée dans `test/quiz/quiz_category_bar_test.dart`

### Implementation for User Story 3

- [x] T015 [P] [US3] Réutiliser le seuil de fiabilité `MatchupService.minGames`, déjà défini dans `lib/matchups/services/matchup_service.dart`, comme nombre minimal de parties
- [x] T016 [US3] Créer `DuelQuestionBuilder` (face-à-face, meilleur contre X, `minGap`, `startOver`) dans `lib/quiz/services/duel_question_builder.dart`
- [x] T017 [US3] Brancher le constructeur de duels, `availableCategories()` et la relance de série dans `lib/quiz/services/quiz_generator.dart` (retrait de l'ancienne `_bestMatchup`)
- [x] T018 [P] [US3] Renommer la famille en « Duels » dans `lib/quiz/models/quiz_question.dart`
- [x] T019 [P] [US3] Ajouter le paramètre `available` à `lib/quiz/widgets/quiz_category_bar/quiz_category_bar.dart`
- [x] T020 [US3] Charger les matchups sans bloquer le quiz (`_loadMatchups`), calculer `availableCategories` et revenir à « Tout » si besoin dans `lib/quiz/quiz_page.dart`

---

## Phase N: Polish & Cross-Cutting Concerns

- [x] T021 [P] Vérifier à la main les trois parcours (quickstart.md)
- [x] T022 Passer `flutter analyze lib/quiz test/quiz` et `flutter test test/quiz/`

---

## Dependencies & Execution Order

- T002 précède T006 ; T005 précède T006.
- T009 précède T011 ; T010 précède T011.
- T016 précède T017 ; T017, T018, T019 précèdent T020.
- Hors périmètre : le quiz du jour de l'accueil (`lib/quiz/services/quiz_service.dart`, `lib/quiz/models/daily_quiz_question.dart`) n'est pas touché.
