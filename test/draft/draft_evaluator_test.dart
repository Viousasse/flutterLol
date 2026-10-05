import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/draft/models/draft_report.dart';
import 'package:monapp/draft/services/draft_evaluator.dart';
import 'package:monapp/matchups/models/matchup.dart';
import 'package:monapp/team/constants/team_roles.dart';
import 'package:monapp/team/models/team_member.dart';

import 'draft_support.dart';

/// Une équipe de cinq champions `prefixe0` à `prefixe4`.
List<TeamMember> _team(
  String prefix, {
  required int attack,
  required int magic,
  required int stunSpells,
  required bool tank,
}) {
  return [
    for (var role = 0; role < teamRoles.length; role++)
      member(
        '$prefix$role',
        attack: attack,
        magic: magic,
        defense: tank && role < 2 ? 9 : 3,
        tags: tank && role < 2 ? const ['Tank'] : const ['Fighter'],
        stunSpells: stunSpells,
      ),
  ];
}

/// Donne à chaque champion de [prefix] un taux de victoire global fiable.
List<Matchup> _overall(String prefix, int wins) {
  return [
    for (var role = 0; role < teamRoles.length; role++)
      duel(
        '$prefix$role',
        'Dummy',
        lane: teamRoleLanes[role],
        games: 200,
        wins: wins,
      ),
  ];
}

/// Le bleu gagne `wins` sur `games` contre le rouge dans chaque voie.
List<Matchup> _lanes(int games, int wins) {
  return [
    for (var role = 0; role < teamRoles.length; role++)
      duel(
        'b$role',
        'r$role',
        lane: teamRoleLanes[role],
        games: games,
        wins: wins,
      ),
  ];
}

DraftCriterion _criterion(DraftReport report, String title) {
  return report.criteria.firstWhere((c) => c.title == title);
}

void main() {
  // Le bleu équilibre ses dégâts, aligne deux tanks et beaucoup de contrôle.
  final strongBlue = _team('b', attack: 5, magic: 5, stunSpells: 3, tank: true);
  // Le rouge ne joue que des dégâts physiques, sans tank ni contrôle.
  final weakRed = _team('r', attack: 9, magic: 1, stunSpells: 0, tank: false);

  test('une draft meilleure partout l emporte sur chaque critère', () {
    final report = DraftEvaluator.evaluate(
      blue: strongBlue,
      red: weakRed,
      dataset: dataset([
        ..._overall('b', 112),
        ..._overall('r', 90),
        ..._lanes(30, 20),
      ]),
    );

    expect(report.winner, DraftWinner.blue);
    expect(report.blueScore, 5);
    expect(report.redScore, 0);
    expect(report.verdict, contains('Votre draft est meilleure'));
    expect(report.criteria.every((c) => c.winner == DraftWinner.blue), isTrue);
  });

  test('le verdict nomme les critères qui font la différence', () {
    final report = DraftEvaluator.evaluate(
      blue: strongBlue,
      red: weakRed,
      dataset: dataset([..._lanes(30, 20)]),
    );

    expect(report.verdict, contains('répartition des dégâts'));
    expect(report.verdict, contains('contrôle'));
    expect(report.strengths, isNotEmpty);
  });

  test(
    'si le site gagne, le verdict le dit et les conseils visent le joueur',
    () {
      final report = DraftEvaluator.evaluate(
        blue: weakRed.map(_renamed('b')).toList(),
        red: strongBlue.map(_renamed('r')).toList(),
        dataset: dataset([..._lanes(30, 10)]),
      );

      expect(report.winner, DraftWinner.red);
      expect(report.verdict, contains('La draft rouge est meilleure'));
      expect(
        report.improvements.any((line) => line.contains('dégâts magiques')),
        isTrue,
      );
      expect(
        report.improvements.any((line) => line.contains('première ligne')),
        isTrue,
      );
    },
  );

  test('deux drafts identiques sont jugées équivalentes', () {
    final blue = _team('b', attack: 5, magic: 5, stunSpells: 2, tank: true);
    final red = _team('r', attack: 5, magic: 5, stunSpells: 2, tank: true);

    final report = DraftEvaluator.evaluate(
      blue: blue,
      red: red,
      dataset: dataset(_lanes(30, 15)),
    );

    expect(report.winner, DraftWinner.tie);
    expect(report.verdict, contains('se valent'));
  });

  test('un duel serré ne désigne personne', () {
    final report = DraftEvaluator.evaluate(
      blue: strongBlue,
      red: weakRed,
      dataset: dataset(_lanes(100, 50)),
    );

    final lanes = _criterion(report, 'Duels de voie');

    expect(lanes.winner, DraftWinner.tie);
  });

  test('sans données de duel, les voies sont signalées sans conclure', () {
    final report = DraftEvaluator.evaluate(
      blue: strongBlue,
      red: weakRed,
      dataset: dataset(const []),
    );

    final lanes = _criterion(report, 'Duels de voie');

    expect(lanes.winner, DraftWinner.tie);
    expect(lanes.explanation, contains('pas assez de parties'));
  });

  test('conseille un contre-pick libre pour une voie perdue', () {
    final report = DraftEvaluator.evaluate(
      blue: strongBlue,
      red: weakRed,
      dataset: dataset([
        duel('b0', 'r0', lane: 'TOP', games: 40, wins: 12),
        duel('Garen', 'r0', lane: 'TOP', games: 30, wins: 21),
      ]),
      championNames: const {'Garen': 'Garen le Puissant'},
    );

    final advice = report.improvements.firstWhere((l) => l.startsWith('Top'));

    expect(advice, contains('30 %'));
    expect(advice, contains('Garen le Puissant'));
    expect(advice, contains('70 %'));
  });

  test('ne conseille pas un champion déjà pris dans la draft', () {
    final report = DraftEvaluator.evaluate(
      blue: strongBlue,
      red: weakRed,
      dataset: dataset([
        duel('b0', 'r0', lane: 'TOP', games: 40, wins: 12),
        // b1 est déjà dans l'équipe bleue : il ne peut pas être proposé.
        duel('b1', 'r0', lane: 'TOP', games: 30, wins: 24),
      ]),
    );

    final advice = report.improvements.firstWhere((l) => l.startsWith('Top'));

    expect(advice, isNot(contains('b1')));
    expect(advice, contains('un autre choix'));
  });

  test('une draft sans défaut reçoit un message plutôt qu une liste vide', () {
    final report = DraftEvaluator.evaluate(
      blue: strongBlue,
      red: weakRed,
      dataset: dataset(_lanes(30, 20)),
    );

    expect(report.improvements, [
      'Votre draft n\'a pas de point faible évident.',
    ]);
  });

  group('draft à deux', () {
    const players = DraftPlayers(blue: 'Léa', red: 'Tom');
    final data = dataset([
      ..._overall('b', 112),
      ..._overall('r', 90),
      ..._lanes(30, 20),
    ]);

    DraftReport duelReport() => DraftEvaluator.evaluate(
      blue: strongBlue,
      red: weakRed,
      dataset: data,
      players: players,
    );

    test('nomme les joueurs au lieu de « vous » et du site', () {
      final report = duelReport();

      expect(report.players, players);
      expect(report.verdict, contains('La draft de Léa est meilleure'));
      expect(report.verdict, isNot(contains('Votre')));

      final text = [
        for (final criterion in report.criteria) criterion.explanation,
      ].join(' ');
      expect(text, contains('Léa'));
      expect(text, contains('Tom'));
      expect(text, isNot(contains('Vous')));
      expect(text, isNot(contains('camp rouge')));
    });

    test('donne des conseils au perdant, pas seulement au camp bleu', () {
      final report = duelReport();

      expect(report.redImprovements.join(' '), contains('Tom'));
      // Le rouge ne joue que du physique, sans tank ni contrôle.
      expect(report.redImprovements.join(' '), contains('dégâts magiques'));
      expect(report.redImprovements.join(' '), contains('première ligne'));
      expect(report.redStrengths, isEmpty);
    });

    test('les points forts du bleu restent écrits de son point de vue', () {
      final report = duelReport();

      expect(report.strengths, isNotEmpty);
      expect(report.redStrengths, isEmpty);
    });

    test('un duel inversé donne les mêmes avantages au rouge', () {
      final report = DraftEvaluator.evaluate(
        blue: weakRed,
        red: strongBlue,
        dataset: data,
        players: players,
      );

      expect(report.winner, DraftWinner.red);
      expect(report.verdict, contains('La draft de Tom est meilleure'));
      expect(report.redStrengths, isNotEmpty);
      expect(report.strengths, isEmpty);
    });

    test('contre le site, aucun conseil n\'est donné au camp rouge', () {
      final report = DraftEvaluator.evaluate(
        blue: strongBlue,
        red: weakRed,
        dataset: data,
      );

      expect(report.players, isNull);
      expect(report.redImprovements, isEmpty);
      expect(report.redStrengths, isEmpty);
    });
  });
}

/// Renomme un membre pour qu'il porte l'identifiant `prefixe + rôle`.
TeamMember Function(TeamMember) _renamed(String prefix) {
  var role = 0;

  return (original) {
    final renamed = member(
      '$prefix${role++}',
      attack: original.detail.stats.attackRating,
      magic: original.detail.stats.magicRating,
      defense: original.detail.stats.defenseRating,
      tags: original.champion.tags,
      stunSpells: _stunCount(original),
    );

    return renamed;
  };
}

int _stunCount(TeamMember original) {
  return original.detail.spells.where((s) => s.description == stunSpell).length;
}
