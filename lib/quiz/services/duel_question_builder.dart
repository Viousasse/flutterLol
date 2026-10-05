import 'dart:math';

import '../../champions/models/champion.dart';
import '../../matchups/constants/lane_labels.dart';
import '../../matchups/models/matchup.dart';
import '../../matchups/services/matchup_service.dart';
import '../models/quiz_question.dart';

/// Fabrique les questions « Qui bat qui ? » à partir des duels réellement
/// comptés dans le fichier de matchups.
///
/// Une question n'est posée que si une seule réponse est défendable : les
/// duels trop peu joués sont écartés, et il faut un écart net entre la bonne
/// réponse et les autres. Sans ça, le quiz récompenserait la chance.
class DuelQuestionBuilder {
  /// Écart minimal, en taux de victoire (0,06 = 6 points), entre la bonne
  /// réponse et chaque autre proposition.
  static const minGap = 0.06;

  /// Un duel A contre B à 56 % laisse B à 44 % : l'écart entre eux est de
  /// 12 points. On l'exprime en distance à 50 % pour rester lisible.
  static const _minDuelEdge = minGap;

  static const _minOptionCount = 3;
  static const _maxOptionCount = 4;

  final List<Matchup> _reliable;
  final Map<String, Champion> _championsById;
  final Random _random;

  /// Énoncés déjà posés dans cette série, pour ne pas les répéter.
  final Set<String> _asked = {};

  DuelQuestionBuilder(
    this._random, {
    required MatchupDataset matchups,
    required List<Champion> champions,
  }) : _championsById = {for (final c in champions) c.id: c},
       _reliable = matchups.matchups
           .where(
             (m) =>
                 m.games >= MatchupService.minGames &&
                 m.championId != m.opponentId &&
                 laneLabels.containsKey(m.lane),
           )
           .toList();

  /// Les deux familles de questions, dans un ordre quelconque.
  List<QuizQuestion? Function()> get builders => [_laneDuel, _counterOf];

  /// « En Mid, qui gagne le plus souvent : A ou B ? »
  QuizQuestion? _laneDuel() {
    final candidates = _reliable
        .where(
          (m) =>
              m.winRate - 0.5 >= _minDuelEdge &&
              _championsById.containsKey(m.championId) &&
              _championsById.containsKey(m.opponentId),
        )
        .toList();

    // A contre B et B contre A sont la même question : une seule clé.
    String keyOf(Matchup m) {
      final ids = [m.championId, m.opponentId]..sort();

      return 'duel:${ids.join(':')}:${m.lane}';
    }

    final matchup = _pickUnasked(candidates, keyOf);
    if (matchup == null) return null;

    final winner = _championsById[matchup.championId]!;
    final loser = _championsById[matchup.opponentId]!;

    // L'ordre dans l'énoncé est tiré au sort : le gagnant ne doit pas toujours
    // être cité en premier.
    final names = [winner.name, loser.name]..shuffle(_random);

    return _question(
      prompt:
          'En ${laneLabels[matchup.lane]}, qui gagne le plus souvent : '
          '${names.first} ou ${names.last} ?',
      options: [
        QuizOptionData(winner.name, imageUrl: winner.imageUrl),
        QuizOptionData(loser.name, imageUrl: loser.imageUrl),
      ],
      explanation: _explain(matchup, winner.name, loser.name),
    );
  }

  /// « Quel champion gagne le plus souvent contre X en Mid ? »
  QuizQuestion? _counterOf() {
    final groups = <String, List<Matchup>>{};
    for (final matchup in _reliable) {
      if (!_championsById.containsKey(matchup.championId)) continue;
      if (!_championsById.containsKey(matchup.opponentId)) continue;

      groups
          .putIfAbsent('${matchup.opponentId}|${matchup.lane}', () => [])
          .add(matchup);
    }

    final keys = groups.keys.toList()..shuffle(_random);
    final open = keys.where((k) => !_asked.contains('counter:$k')).toList();

    for (final key in open) {
      final question = _counterInGroup(key, groups[key]!);
      if (question != null) return question;
    }

    return null;
  }

  QuizQuestion? _counterInGroup(String key, List<Matchup> group) {
    // Un champion ne figure qu'une fois dans les propositions.
    final byChampion = <String, Matchup>{};
    for (final matchup in group) {
      final known = byChampion[matchup.championId];
      if (known == null || matchup.games > known.games) {
        byChampion[matchup.championId] = matchup;
      }
    }

    final candidates = byChampion.values.toList()..shuffle(_random);

    for (final best in candidates) {
      final lower = candidates
          .where((m) => best.winRate - m.winRate >= minGap)
          .toList();
      if (lower.length < _minOptionCount - 1) continue;

      final distractorCount = min(lower.length, _maxOptionCount - 1);
      final distractors = (lower..shuffle(_random)).take(distractorCount);
      final target = _championsById[best.opponentId]!;
      final winner = _championsById[best.championId]!;

      _asked.add('counter:$key');

      return _question(
        prompt:
            'Quel champion gagne le plus souvent contre ${target.name} '
            'en ${laneLabels[best.lane]} ?',
        imageUrl: target.imageUrl,
        options: [
          QuizOptionData(winner.name, imageUrl: winner.imageUrl),
          ...distractors.map((m) {
            final champion = _championsById[m.championId]!;

            return QuizOptionData(champion.name, imageUrl: champion.imageUrl);
          }),
        ],
        explanation: _explain(best, winner.name, target.name),
      );
    }

    return null;
  }

  /// Un élément de [candidates] dont la clé n'a pas encore servi, ou `null`
  /// quand tout a servi : le générateur relance alors la série.
  Matchup? _pickUnasked(
    List<Matchup> candidates,
    String Function(Matchup) keyOf,
  ) {
    if (candidates.isEmpty) return null;

    final open = candidates.where((m) => !_asked.contains(keyOf(m))).toList();
    if (open.isEmpty) return null;

    final picked = open[_random.nextInt(open.length)];
    _asked.add(keyOf(picked));

    return picked;
  }

  /// Fait repartir la série : les énoncés déjà posés peuvent revenir.
  /// Appelé quand tout a servi, pour que le quiz ne s'arrête jamais.
  bool startOver() {
    if (_asked.isEmpty) return false;
    _asked.clear();

    return true;
  }

  /// Les chiffres exacts vont ici, après la réponse : dans l'énoncé ils
  /// auraient donné la solution.
  static String _explain(Matchup matchup, String winner, String loser) {
    final percent = (matchup.winRate * 100).round();

    return '$winner gagne $percent % de ses duels contre $loser '
        '(${matchup.games} parties).';
  }

  /// La bonne réponse est la première fournie ; les propositions sont ensuite
  /// mélangées.
  QuizQuestion _question({
    required String prompt,
    required List<QuizOptionData> options,
    required String explanation,
    String? imageUrl,
  }) {
    final answer = options.first;
    final shuffled = [...options]..shuffle(_random);

    return QuizQuestion(
      category: QuizCategory.matchups,
      prompt: prompt,
      imageUrl: imageUrl,
      options: shuffled,
      answerIndex: shuffled.indexOf(answer),
      explanation: explanation,
    );
  }
}
