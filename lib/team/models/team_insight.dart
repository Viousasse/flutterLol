enum InsightKind { good, warning, info }

/// Un constat sur l'équipe : ce qui va bien, ce qui manque, ou une précision.
class TeamInsight {
  final InsightKind kind;
  final String title;
  final String message;

  const TeamInsight({
    required this.kind,
    required this.title,
    required this.message,
  });
}

/// Le bilan complet d'une équipe.
class TeamAnalysis {
  /// Part des dégâts physiques et magiques, de 0 à 1 chacune. Les deux valent 0
  /// quand l'équipe est vide.
  final double physicalShare;
  final double magicShare;

  /// Champions capables d'encaisser en première ligne.
  final int frontlineCount;

  /// Sorts qui étourdissent, immobilisent, projettent ou réduisent au silence.
  final int controlSpellCount;

  final int memberCount;
  final List<TeamInsight> insights;

  const TeamAnalysis({
    required this.physicalShare,
    required this.magicShare,
    required this.frontlineCount,
    required this.controlSpellCount,
    required this.memberCount,
    required this.insights,
  });
}
