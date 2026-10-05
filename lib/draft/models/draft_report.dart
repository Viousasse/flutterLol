import 'draft_state.dart';

/// Qui l'emporte sur un critère : un camp, ou aucun.
enum DraftWinner {
  blue,
  red,
  tie;

  static DraftWinner of(DraftSide side) {
    return side == DraftSide.blue ? DraftWinner.blue : DraftWinner.red;
  }
}

/// Un critère de comparaison entre les deux drafts, avec ce qui fait la
/// différence en toutes lettres.
class DraftCriterion {
  final String title;
  final DraftWinner winner;
  final String blueText;
  final String redText;
  final String explanation;

  const DraftCriterion({
    required this.title,
    required this.winner,
    required this.blueText,
    required this.redText,
    required this.explanation,
  });
}

/// Le bilan d'une draft terminée : qui gagne, pourquoi, et ce que le joueur
/// (camp bleu) peut améliorer.
class DraftReport {
  final List<DraftCriterion> criteria;
  final double blueScore;
  final double redScore;
  final DraftWinner winner;
  final String verdict;
  final List<String> strengths;
  final List<String> improvements;

  const DraftReport({
    required this.criteria,
    required this.blueScore,
    required this.redScore,
    required this.winner,
    required this.verdict,
    required this.strengths,
    required this.improvements,
  });
}
