# Implementation Plan: Quiz : chrono, historique des séries et duels

**Branch**: `003-quiz-chrono-et-duels` (livré sur `main`) | **Date**: 2026-10-05 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/003-quiz-chrono-et-duels/spec.md`

## Summary

Trois ajouts à l'onglet Quiz (`lib/quiz/`) : un mode chrono porté par un `Timer.periodic` de `QuizPage` et un widget `QuizTimerBar` ; un historique des séries terminées dans `QuizScoreService` (liste bornée dans `shared_preferences`) affiché par `QuizHistory` ; et une famille « Duels » fabriquée par `DuelQuestionBuilder` à partir du fichier de matchups, avec seuils de fiabilité (`MatchupService.minGames`, écart de 6 points) et masquage automatique de la famille sans données.

## Technical Context

**Language/Version**: Dart 3 / Flutter (SDK `^3.13.3`)

**Primary Dependencies**: `shared_preferences` (record et historique) ; aucune nouvelle dépendance

**Storage**: `shared_preferences`, clés `quiz_best_streak` (entier) et `quiz_recent_streaks` (liste de chaînes) ; matchups en lecture seule depuis un fichier embarqué via `MatchupService`

**Testing**: `flutter_test` ; données de duel construites sur place, graine fixe du générateur

**Target Platform**: mobile et web

**Project Type**: application mobile Flutter

**Performance Goals**: décompte à 1 Hz ; animation de la barre de 900 ms

**Constraints**: aucun appel réseau dans les tests ; la page garde son état sous un `IndexedStack`, donc le chrono doit se suspendre quand `TickerMode` est coupé

**Scale/Scope**: une page, 4 familles de questions, 8 séries d'historique, 15 secondes par question

## Constitution Check

| Principe | Verdict | Preuve |
|----------|---------|--------|
| I. Organisation par fonctionnalité | Respecté | `lib/quiz/{models,services,widgets/<nom>/<nom>.dart}` ; un widget public par fichier (`quiz_timer_bar.dart`, `quiz_history.dart`) ; `duel_question_builder.dart` n'importe que des modèles et services d'autres fonctionnalités (`matchups`, `champions`) |
| II. Données Riot, erreurs affichables | Respecté | `QuizPage.loadData` attrape tout, affiche `userMessageFor` et `ErrorRetryView` ; seul le fichier de matchups, hors Riot, est toléré absent |
| III. Images via RemoteImage | Respecté | `quiz_question_card.dart` et `quiz_answer_button.dart` utilisent `RemoteImage` ; aucun appel direct à `Image.network` dans `lib/quiz` |
| IV. Thème centralisé | Respecté, avec une couleur de sens existante | `AppColors`/`AppTheme` partout ; `quizWrongColor` est une constante de sens définie avant cette fonctionnalité dans `quiz_answer_button.dart` |
| V. État simple et local | Respecté | `StatefulWidget` + `setState` ; `QuizScoreService.bestStreak` et `recentStreaks` sont des `ValueNotifier` ; `timer?.cancel()` dans `dispose` |
| VI. Tests (NON-NEGOTIABLE) | Respecté en partie, voir Complexity Tracking | Barre de temps, record/historique, familles, duels testés ; la logique du chrono dans `QuizPage` ne l'est pas |
| VII. Lisibilité, français, tutoiement | Respecté avec écarts | Constantes nommées (`_secondsPerQuestion`, `_timedOutIndex`, `maxRecentStreaks`, `minGap`) ; commentaires sur le pourquoi ; textes en vouvoiement (voir Complexity Tracking) ; durées `Duration(seconds: 1)` et `Duration(milliseconds: 900)` en littéral |

## Project Structure

### Documentation (this feature)

```text
specs/003-quiz-chrono-et-duels/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── quiz-score-service.md
│   └── duel-question-builder.md
├── checklists/
│   └── requirements.md
└── tasks.md
```

### Source Code (repository root)

```text
lib/quiz/
├── quiz_page.dart                                   # chrono, tirage, catégories disponibles
├── models/
│   ├── quiz_question.dart                           # QuizCategory (Duels), QuizQuestion
│   └── daily_quiz_question.dart                     # quiz du jour (hors périmètre)
├── services/
│   ├── quiz_generator.dart                          # availableCategories, next, startOver
│   ├── duel_question_builder.dart                   # face-à-face et meilleur contre X
│   ├── quiz_score_service.dart                      # record + historique
│   └── quiz_service.dart                            # quiz du jour (hors périmètre)
└── widgets/
    ├── quiz_timer_bar/quiz_timer_bar.dart
    ├── quiz_history/quiz_history.dart
    ├── quiz_category_bar/quiz_category_bar.dart     # paramètre available
    └── quiz_question_card/quiz_question_card.dart   # timedOut

test/quiz/
├── matchup_quiz_test.dart
├── quiz_category_bar_test.dart
├── quiz_generator_test.dart
├── quiz_score_service_test.dart
└── quiz_timer_bar_test.dart
```

**Structure Decision**: structure `lib/quiz/` existante ; `duel_question_builder.dart` est un nouveau service extrait de `QuizGenerator`.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Principe VI : la logique du chrono dans `QuizPage` (décompte, expiration, pause par `TickerMode`) n'a aucun test | Elle est liée à un `Timer` et à l'arbre de widgets de la page, qui charge champions et objets réseau | Dette reconnue : un widget test avec `fakeAsync` et des services injectés aurait été possible mais `QuizPage` n'accepte aucune injection |
| Principe VI : `QuizHistory` sans test propre | Widget de 28 lignes, couvert indirectement par le test du service | Dette mineure |
| Principe VII : « Testez vos connaissances » et « Touchez pour réessayer » vouvoient | Textes plus anciens que cette fonctionnalité (« Touchez pour réessayer » est dans `_NoQuestion`) | Écart à corriger, non corrigé |
| Principe VII : durées littérales | `Duration(seconds: 1)` du `Timer.periodic` et 900 ms de l'animation | Aurait dû être nommé comme `_secondsPerQuestion` |
