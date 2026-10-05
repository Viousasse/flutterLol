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

/// Les deux joueurs d'une draft à deux. Sans eux, le bilan s'adresse au joueur
/// (camp bleu) et nomme l'adversaire « le site ».
class DraftPlayers {
  final String blue;
  final String red;

  const DraftPlayers({required this.blue, required this.red});

  String of(DraftSide side) => side == DraftSide.blue ? blue : red;
}

/// Le bilan d'une draft terminée : qui gagne, pourquoi, et ce que le joueur
/// (camp bleu) peut améliorer.
///
/// Dans une draft à deux ([players] renseigné), le bilan est neutre et les
/// forces et conseils sont donnés pour chacun des deux camps.
class DraftReport {
  final List<DraftCriterion> criteria;
  final double blueScore;
  final double redScore;
  final DraftWinner winner;
  final String verdict;
  final List<String> strengths;
  final List<String> improvements;
  final DraftPlayers? players;
  final List<String> redStrengths;
  final List<String> redImprovements;

  const DraftReport({
    required this.criteria,
    required this.blueScore,
    required this.redScore,
    required this.winner,
    required this.verdict,
    required this.strengths,
    required this.improvements,
    this.players,
    this.redStrengths = const [],
    this.redImprovements = const [],
  });
}
