# Contrat : `QuizScoreService` et widgets du chrono

## `QuizScoreService` (`lib/quiz/services/quiz_score_service.dart`)

```dart
class QuizScoreService {
  static const int maxRecentStreaks = 8;

  static final ValueNotifier<int> bestStreak;           // meilleure série
  static final ValueNotifier<List<int>> recentStreaks;  // séries terminées, la plus récente d'abord

  static Future<void> ensureLoaded();                   // idempotent ; stockage indisponible = départ à zéro, retentable
  static Future<bool> submit(int streak);               // vrai si `streak` bat le record (et le mémorise)
  static Future<void> recordFinished(int streak);       // ignore streak <= 0 ; borne à maxRecentStreaks
}
```

Clés `shared_preferences` : `quiz_best_streak`, `quiz_recent_streaks`. Pas de méthode `reset` : les tests s'appuient sur `SharedPreferences.setMockInitialValues`.

## `QuizTimerBar` (`lib/quiz/widgets/quiz_timer_bar/quiz_timer_bar.dart`)

```dart
class QuizTimerBar extends StatelessWidget {
  static const int urgentSeconds = 5;
  const QuizTimerBar({super.key, required int secondsLeft, required int totalSeconds});
}
```

Barre animée et texte « N s » ; couleur `quizWrongColor` si `secondsLeft <= urgentSeconds`, `AppColors.accent` sinon ; étiquette sémantique « N secondes restantes ».

## `QuizHistory` (`lib/quiz/widgets/quiz_history/quiz_history.dart`)

```dart
class QuizHistory extends StatelessWidget { const QuizHistory({super.key}); }
```

Écoute `QuizScoreService.recentStreaks` ; rend « DERNIÈRES SÉRIES  a · b · c » ou rien si la liste est vide.

## `QuizCategoryBar` (`lib/quiz/widgets/quiz_category_bar/quiz_category_bar.dart`)

```dart
const QuizCategoryBar({
  super.key,
  required QuizCategory? selected,
  required ValueChanged<QuizCategory?> onSelect,
  Set<QuizCategory>? available,   // null : toutes les familles ; sinon seules celles listées
});
```

Un second appui sur la puce sélectionnée renvoie `null` (« Tout »).

## `QuizQuestionCard`

Gagne `bool timedOut` (défaut faux) : si vrai, le verdict affiche « Temps écoulé : <bonne réponse>. ».
