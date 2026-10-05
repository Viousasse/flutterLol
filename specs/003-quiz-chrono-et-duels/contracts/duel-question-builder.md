# Contrat : `DuelQuestionBuilder` et `QuizGenerator`

## `DuelQuestionBuilder` (`lib/quiz/services/duel_question_builder.dart`)

```dart
class DuelQuestionBuilder {
  static const double minGap = 0.06;   // écart minimal de taux de victoire

  DuelQuestionBuilder(
    Random random, {
    required MatchupDataset matchups,
    required List<Champion> champions,
  });

  /// Les deux familles : face-à-face et « meilleur contre X ». Chaque fonction rend `null`
  /// quand les données ne permettent pas de question honnête.
  List<QuizQuestion? Function()> get builders;

  /// Vide la mémoire des énoncés posés. Rend vrai s'il y avait quelque chose à vider.
  bool startOver();
}
```

Formats des énoncés :

- face-à-face : `En <Voie>, qui gagne le plus souvent : <A> ou <B> ?` (2 propositions) ;
- meilleur contre X : `Quel champion gagne le plus souvent contre <X> en <Voie> ?` (3 à 4 propositions, image de X).

Explication : `<gagnant> gagne <N> % de ses duels contre <perdant> (<M> parties).`

## `QuizGenerator` (`lib/quiz/services/quiz_generator.dart`)

```dart
class QuizData {
  const QuizData({required List<Champion> champions, required List<Item> items, required MatchupDataset matchups});
}

class QuizGenerator {
  QuizGenerator(QuizData data, {int? seed});

  static const int optionCount = 4;

  /// Familles ayant au moins une question possible (sondées par un générateur à part).
  Set<QuizCategory> availableCategories();

  /// Une question, éventuellement restreinte à une famille ; `null` si rien n'aboutit.
  /// `avoid` évite de répéter l'énoncé précédent ; si tous les duels ont servi, la série repart.
  QuizQuestion? next({QuizCategory? category, QuizQuestion? avoid});
}
```

Garanties : reproductible à graine égale ; jamais deux fois le même énoncé de suite.

## Dépendances consommées

- `MatchupService.minGames` (8), `Matchup` et `MatchupDataset` (`lib/matchups/`) ;
- `laneLabels` (`lib/matchups/constants/lane_labels.dart`) ;
- `Champion` (`lib/champions/models/champion.dart`).
