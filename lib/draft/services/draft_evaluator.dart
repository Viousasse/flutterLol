import '../../champions/models/champion.dart';
import '../../counters/services/counter_service.dart';
import '../../matchups/models/matchup.dart';
import '../../matchups/services/matchup_service.dart';
import '../../team/constants/team_roles.dart';
import '../../team/models/team_insight.dart';
import '../../team/models/team_member.dart';
import '../../team/services/team_analyzer.dart';
import '../models/draft_report.dart';
import '../models/draft_state.dart';

/// Compare deux drafts complètes et explique laquelle est meilleure.
///
/// Les drafts sont des listes de cinq [TeamMember], dans l'ordre des rôles. Le
/// camp bleu est celui du joueur : c'est pour lui que sortent les conseils.
class DraftEvaluator {
  /// Écart de répartition des dégâts en dessous duquel deux équilibres sont
  /// considérés comme équivalents.
  static const balanceTolerance = 0.05;

  /// Taux de victoire en duel à partir duquel une voie est gagnée : entre les
  /// deux seuils, le duel est trop serré pour désigner quelqu'un.
  static const laneWinThreshold = 0.53;
  static const laneLossThreshold = 0.47;

  /// Écart de taux de victoire moyen (en points) nécessaire pour désigner un
  /// camp.
  static const winRateTolerance = 0.01;

  /// Écart de score en dessous duquel les drafts sont jugées équivalentes.
  static const tieScoreGap = 0.5;

  static DraftReport evaluate({
    required List<TeamMember> blue,
    required List<TeamMember> red,
    required MatchupDataset dataset,
    Map<String, String> championNames = const {},
    DraftPlayers? players,
  }) {
    final blueAnalysis = TeamAnalyzer.analyze(blue);
    final redAnalysis = TeamAnalyzer.analyze(red);
    final lanes = _laneResults(blue, red, dataset);

    final criteria = [
      _damageCriterion(blueAnalysis, redAnalysis, players),
      _frontlineCriterion(blueAnalysis, redAnalysis, players),
      _controlCriterion(blueAnalysis, redAnalysis, players),
      _lanesCriterion(lanes, players),
      _winRateCriterion(blue, red, dataset, players),
    ];

    var blueScore = 0.0;
    var redScore = 0.0;
    for (final criterion in criteria) {
      switch (criterion.winner) {
        case DraftWinner.blue:
          blueScore += 1;
        case DraftWinner.red:
          redScore += 1;
        case DraftWinner.tie:
          blueScore += 0.5;
          redScore += 0.5;
      }
    }

    final winner = (blueScore - redScore).abs() < tieScoreGap
        ? DraftWinner.tie
        : blueScore > redScore
        ? DraftWinner.blue
        : DraftWinner.red;

    return DraftReport(
      criteria: criteria,
      blueScore: blueScore,
      redScore: redScore,
      winner: winner,
      verdict: _verdict(winner, blueScore, redScore, criteria, players),
      strengths: _strengths(criteria, DraftSide.blue),
      improvements: _improvements(
        analysis: blueAnalysis,
        lanes: lanes,
        dataset: dataset,
        championNames: championNames,
        taken: _taken(blue, red),
        players: players,
        side: DraftSide.blue,
      ),
      players: players,
      // Les conseils du camp rouge n'ont de sens que face à un vrai joueur :
      // contre le site, personne ne les lirait.
      redStrengths: players == null
          ? const []
          : _strengths(criteria, DraftSide.red),
      redImprovements: players == null
          ? const []
          : _improvements(
              analysis: redAnalysis,
              lanes: lanes,
              dataset: dataset,
              championNames: championNames,
              taken: _taken(blue, red),
              players: players,
              side: DraftSide.red,
            ),
    );
  }

  static Set<String> _taken(List<TeamMember> blue, List<TeamMember> red) {
    return {
      for (final member in [...blue, ...red]) member.champion.id,
    };
  }

  /// Le gagnant et le perdant d'un critère, nommés pour une phrase de duel.
  static (String, String) _names(DraftPlayers players, DraftWinner winner) {
    return winner == DraftWinner.blue
        ? (players.blue, players.red)
        : (players.red, players.blue);
  }

  // --- Critères ---------------------------------------------------------

  /// 1 pour des dégâts répartis moitié-moitié, 0 pour un seul type de dégâts.
  static double _balance(TeamAnalysis analysis) {
    return 1 - (analysis.physicalShare - analysis.magicShare).abs();
  }

  static String _damageText(TeamAnalysis analysis) {
    return '${_percent(analysis.physicalShare)} % physiques, '
        '${_percent(analysis.magicShare)} % magiques';
  }

  static DraftCriterion _damageCriterion(
    TeamAnalysis blue,
    TeamAnalysis red,
    DraftPlayers? players,
  ) {
    final gap = _balance(blue) - _balance(red);
    final winner = gap.abs() < balanceTolerance
        ? DraftWinner.tie
        : gap > 0
        ? DraftWinner.blue
        : DraftWinner.red;

    final explanation = switch (winner) {
      DraftWinner.tie =>
        'Les deux drafts répartissent leurs dégâts de façon comparable.',
      _ when players != null =>
        '${_names(players, winner).$2} mise surtout sur un seul type de '
            "dégâts : ${_names(players, winner).$1} n'a qu'à empiler une "
            "seule défense pour l'annuler.",
      DraftWinner.blue =>
        "Le camp rouge mise presque tout sur un seul type de dégâts : vos "
            "adversaires n'ont qu'à empiler une seule défense pour l'annuler.",
      DraftWinner.red =>
        'Votre draft mise surtout sur un seul type de dégâts : le camp rouge '
            "n'a qu'à empiler une seule défense pour la neutraliser.",
    };

    return DraftCriterion(
      title: 'Répartition des dégâts',
      winner: winner,
      blueText: _damageText(blue),
      redText: _damageText(red),
      explanation: explanation,
    );
  }

  static DraftCriterion _frontlineCriterion(
    TeamAnalysis blue,
    TeamAnalysis red,
    DraftPlayers? players,
  ) {
    final winner = _higherWins(
      blue.frontlineCount.toDouble(),
      red.frontlineCount.toDouble(),
      tolerance: 0.5,
    );

    final explanation = switch (winner) {
      DraftWinner.tie => 'Les deux équipes ont autant de première ligne.',
      _ when players != null =>
        '${_names(players, winner).$1} a une première ligne plus solide : ses '
            'dégâts sont mieux protégés pendant les combats.',
      DraftWinner.blue =>
        'Votre première ligne est plus solide : vos dégâts sont mieux '
            'protégés pendant les combats.',
      DraftWinner.red =>
        'Le camp rouge a davantage de champions pour encaisser : ses dégâts '
            "sont mieux protégés que les vôtres.",
    };

    return DraftCriterion(
      title: 'Première ligne',
      winner: winner,
      blueText: _plural(blue.frontlineCount, 'champion'),
      redText: _plural(red.frontlineCount, 'champion'),
      explanation: explanation,
    );
  }

  static DraftCriterion _controlCriterion(
    TeamAnalysis blue,
    TeamAnalysis red,
    DraftPlayers? players,
  ) {
    final winner = _higherWins(
      blue.controlSpellCount.toDouble(),
      red.controlSpellCount.toDouble(),
      tolerance: 1,
    );

    final explanation = switch (winner) {
      DraftWinner.tie => 'Les deux équipes ont un contrôle équivalent.',
      _ when players != null =>
        '${_names(players, winner).$1} a plus de sorts pour immobiliser ou '
            'étourdir : bloquer une cible lui sera plus facile.',
      DraftWinner.blue =>
        'Vous avez plus de sorts pour immobiliser ou étourdir : il vous est '
            'plus facile de bloquer une cible.',
      DraftWinner.red =>
        'Le camp rouge a plus de sorts pour immobiliser ou étourdir : il '
            'bloquera plus facilement vos champions.',
    };

    return DraftCriterion(
      title: 'Contrôle',
      winner: winner,
      blueText: _plural(blue.controlSpellCount, 'sort'),
      redText: _plural(red.controlSpellCount, 'sort'),
      explanation: explanation,
    );
  }

  static DraftCriterion _lanesCriterion(
    List<_LaneResult> lanes,
    DraftPlayers? players,
  ) {
    final blueWins = lanes.where((l) => l.outcome == _Outcome.blue).length;
    final redWins = lanes.where((l) => l.outcome == _Outcome.red).length;

    final winner = _higherWins(
      blueWins.toDouble(),
      redWins.toDouble(),
      tolerance: 1,
    );

    final detail = [for (final lane in lanes) lane.describe()].join('\n');
    final summary = switch (winner) {
      DraftWinner.tie => 'Les voies se répartissent équitablement.',
      _ when players != null =>
        '${_names(players, winner).$1} gagne plus de duels de voie que '
            '${_names(players, winner).$2}.',
      DraftWinner.blue =>
        'Vous gagnez plus de duels de voie que le camp rouge.',
      DraftWinner.red => 'Le camp rouge gagne plus de duels de voie que vous.',
    };

    return DraftCriterion(
      title: 'Duels de voie',
      winner: winner,
      blueText: _plural(blueWins, 'voie'),
      redText: _plural(redWins, 'voie'),
      explanation: '$summary\n$detail',
    );
  }

  static DraftCriterion _winRateCriterion(
    List<TeamMember> blue,
    List<TeamMember> red,
    MatchupDataset dataset,
    DraftPlayers? players,
  ) {
    final blueRate = _averageWinRate(blue, dataset);
    final redRate = _averageWinRate(red, dataset);

    if (blueRate == null || redRate == null) {
      return const DraftCriterion(
        title: 'Taux de victoire moyen',
        winner: DraftWinner.tie,
        blueText: 'données insuffisantes',
        redText: 'données insuffisantes',
        explanation:
            'Trop peu de parties Master+ pour comparer les champions choisis.',
      );
    }

    final winner = _higherWins(blueRate, redRate, tolerance: winRateTolerance);

    final explanation = switch (winner) {
      DraftWinner.tie =>
        'Les champions des deux camps gagnent à peu près autant.',
      _ when players != null =>
        'Les champions de ${_names(players, winner).$1} gagnent plus souvent '
            'en moyenne dans les parties classées Master+.',
      DraftWinner.blue =>
        'Vos champions gagnent plus souvent en moyenne dans les parties '
            'classées Master+.',
      DraftWinner.red =>
        'Les champions du camp rouge gagnent plus souvent en moyenne dans '
            'les parties classées Master+.',
    };

    return DraftCriterion(
      title: 'Taux de victoire moyen',
      winner: winner,
      blueText: '${(blueRate * 100).toStringAsFixed(1)} %',
      redText: '${(redRate * 100).toStringAsFixed(1)} %',
      explanation: explanation,
    );
  }

  static double? _averageWinRate(List<TeamMember> team, MatchupDataset data) {
    final rates = [
      for (final member in team)
        if (MatchupService.overallFor(member.champion.id, data) case final r
            when r.isReliable)
          r.winRate,
    ];
    if (rates.isEmpty) return null;

    return rates.fold(0.0, (sum, rate) => sum + rate) / rates.length;
  }

  // --- Voies ------------------------------------------------------------

  static List<_LaneResult> _laneResults(
    List<TeamMember> blue,
    List<TeamMember> red,
    MatchupDataset dataset,
  ) {
    return [
      for (var index = 0; index < teamRoles.length; index++)
        _LaneResult(
          role: teamRoles[index],
          lane: teamRoleLanes[index],
          blue: blue[index].champion,
          red: red[index].champion,
          blueWinRate: MatchupService.headToHead(
            blue[index].champion.id,
            red[index].champion.id,
            dataset,
          )?.winRate,
        ),
    ];
  }

  // --- Verdict et conseils ----------------------------------------------

  static String _verdict(
    DraftWinner winner,
    double blueScore,
    double redScore,
    List<DraftCriterion> criteria,
    DraftPlayers? players,
  ) {
    final score = '${_score(blueScore)} contre ${_score(redScore)}';

    if (winner == DraftWinner.tie) {
      return 'Les deux drafts se valent ($score).';
    }

    final name = players != null
        ? 'La draft de ${_names(players, winner).$1}'
        : winner == DraftWinner.blue
        ? 'Votre draft'
        : 'La draft rouge';
    final reasons = [
      for (final criterion in criteria)
        if (criterion.winner == winner) criterion.title.toLowerCase(),
    ];

    return '$name est meilleure ($score), grâce à : ${reasons.join(', ')}.';
  }

  /// Les critères que [side] remporte, du point de vue de ce camp.
  static List<String> _strengths(
    List<DraftCriterion> criteria,
    DraftSide side,
  ) {
    final winner = DraftWinner.of(side);

    return [
      for (final criterion in criteria)
        if (criterion.winner == winner)
          side == DraftSide.blue
              ? '${criterion.title} : ${criterion.blueText} contre '
                    '${criterion.redText}.'
              : '${criterion.title} : ${criterion.redText} contre '
                    '${criterion.blueText}.',
    ];
  }

  /// Ce que [side] peut améliorer. Sans [players], le conseil s'adresse au
  /// joueur (camp bleu) à la deuxième personne ; en duel, il nomme le joueur.
  static List<String> _improvements({
    required TeamAnalysis analysis,
    required List<_LaneResult> lanes,
    required MatchupDataset dataset,
    required Map<String, String> championNames,
    required Set<String> taken,
    required DraftPlayers? players,
    required DraftSide side,
  }) {
    final advice = <String>[];
    final duel = players != null;
    final name = duel ? players.of(side) : 'Vous';
    final opponent = duel ? players.of(side.opposite) : 'le camp rouge';
    final lacks = duel ? 'manque' : 'manquez';

    if (analysis.magicShare < TeamAnalyzer.minDamageShare) {
      advice.add(
        '$name $lacks de dégâts magiques (${_percent(analysis.magicShare)} '
        '%) : prenez un mage ou un assassin à dégâts magiques, en milieu ou '
        "en soutien, pour empêcher $opponent de n'empiler que de l'armure.",
      );
    } else if (analysis.physicalShare < TeamAnalyzer.minDamageShare) {
      advice.add(
        '$name $lacks de dégâts physiques '
        '(${_percent(analysis.physicalShare)} %) : prenez un tireur ou un '
        'combattant à dégâts physiques pour ne pas laisser $opponent '
        'empiler la résistance magique.',
      );
    }

    if (analysis.frontlineCount == 0) {
      advice.add(
        "${duel ? 'L\'équipe de $name' : 'Votre équipe'} n'a aucune première "
        'ligne : un tank en haut, en jungle ou en soutien protégerait '
        '${duel ? 'ses' : 'vos'} dégâts.',
      );
    }

    if (analysis.controlSpellCount < TeamAnalyzer.minControlSpells) {
      advice.add(
        '$name ${duel ? 'a' : 'avez'} peu de contrôle '
        '(${analysis.controlSpellCount} sort'
        '${analysis.controlSpellCount > 1 ? 's' : ''}) : cherchez des '
        'champions qui étourdissent ou immobilisent, souvent en soutien ou en '
        'jungle.',
      );
    }

    // Les duels sont écrits du côté bleu : pour le rouge, on les retourne afin
    // que « perdre » veuille toujours dire « perdre pour ce camp ».
    for (final lane in lanes) {
      final own = side == DraftSide.blue ? lane : lane.flipped();
      if (own.outcome != _Outcome.red) continue;

      advice.add(own.suggestion(dataset, taken, championNames));
    }

    if (advice.isEmpty) {
      advice.add(
        duel
            ? "La draft de $name n'a pas de point faible évident."
            : "Votre draft n'a pas de point faible évident.",
      );
    }

    return advice;
  }

  // --- Outils -----------------------------------------------------------

  static DraftWinner _higherWins(
    double blue,
    double red, {
    required double tolerance,
  }) {
    final gap = blue - red;
    if (gap.abs() < tolerance) return DraftWinner.tie;

    return gap > 0 ? DraftWinner.blue : DraftWinner.red;
  }

  static int _percent(double share) => (share * 100).round();

  static String _plural(int count, String noun) {
    return '$count $noun${count > 1 ? 's' : ''}';
  }

  static String _score(double score) {
    return score == score.roundToDouble()
        ? '${score.round()}'
        : score.toStringAsFixed(1).replaceAll('.', ',');
  }
}

enum _Outcome { blue, red, even, unknown }

/// Le duel d'un rôle : les deux champions et le taux de victoire du bleu.
class _LaneResult {
  final String role;
  final String lane;
  final Champion blue;
  final Champion red;
  final double? blueWinRate;

  const _LaneResult({
    required this.role,
    required this.lane,
    required this.blue,
    required this.red,
    required this.blueWinRate,
  });

  /// Le même duel vu du camp rouge : les champions s'échangent et le taux de
  /// victoire devient celui du rouge.
  _LaneResult flipped() {
    final rate = blueWinRate;

    return _LaneResult(
      role: role,
      lane: lane,
      blue: red,
      red: blue,
      blueWinRate: rate == null ? null : 1 - rate,
    );
  }

  _Outcome get outcome {
    final rate = blueWinRate;
    if (rate == null) return _Outcome.unknown;
    if (rate >= DraftEvaluator.laneWinThreshold) return _Outcome.blue;
    if (rate <= DraftEvaluator.laneLossThreshold) return _Outcome.red;

    return _Outcome.even;
  }

  String describe() {
    final rate = blueWinRate;
    if (rate == null) {
      return '$role : ${blue.name} contre ${red.name}, pas assez de parties.';
    }

    return '$role : ${blue.name} gagne ${(rate * 100).round()} % contre '
        '${red.name}.';
  }

  /// Un conseil précis pour une voie perdue : le champion qui bat le mieux
  /// l'adversaire à ce poste, s'il est encore libre.
  String suggestion(
    MatchupDataset dataset,
    Set<String> taken,
    Map<String, String> championNames,
  ) {
    final rate = ((blueWinRate ?? 0) * 100).round();
    final base =
        '$role : ${blue.name} ne gagne que $rate % contre ${red.name}.';

    final better =
        CounterService.counters(
              red.id,
              dataset,
              lane: lane,
              includeLowConfidence: false,
            )
            .where(
              (pick) => !taken.contains(pick.championId) && pick.winRate > 0.5,
            )
            .firstOrNull;
    if (better == null) return '$base Essayez un autre choix à ce poste.';

    final name = championNames[better.championId] ?? better.championId;

    return '$base $name gagne '
        '${(better.winRate * 100).round()} % contre lui à ce poste.';
  }
}
