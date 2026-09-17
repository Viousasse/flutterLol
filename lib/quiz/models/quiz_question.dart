enum QuizCategory { champions, regions, items, matchups }

const quizCategoryLabels = {
  QuizCategory.champions: 'Champions',
  QuizCategory.regions: 'Régions',
  QuizCategory.items: 'Objets',
  QuizCategory.matchups: 'Matchups',
};

/// Une réponse proposée. L'image est facultative : elle sert aux questions où
/// c'est le visuel qui compte, comme « lequel de ces objets est le plus cher ».
class QuizOptionData {
  final String label;
  final String? imageUrl;

  const QuizOptionData(this.label, {this.imageUrl});
}

/// Une question de quiz, quelle qu'en soit la famille.
///
/// Toutes les familles partagent la même forme — un énoncé, une illustration
/// facultative, quatre propositions dont une bonne — ce qui permet d'en ajouter
/// une sans toucher à l'écran.
class QuizQuestion {
  final QuizCategory category;
  final String prompt;
  final String? imageUrl;
  final List<QuizOptionData> options;
  final int answerIndex;

  /// Affichée après la réponse : d'où vient l'information.
  final String? explanation;

  const QuizQuestion({
    required this.category,
    required this.prompt,
    required this.options,
    required this.answerIndex,
    this.imageUrl,
    this.explanation,
  });

  QuizOptionData get answer => options[answerIndex];
}
