import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/matchups/models/matchup.dart';
import 'package:monapp/draft/models/draft_report.dart';
import 'package:monapp/draft/services/ban_analyzer.dart';
import 'package:monapp/draft/services/draft_evaluator.dart';
import 'package:monapp/team/constants/team_roles.dart';

import 'draft_support.dart';

/// Un champion qui a joué `games` parties dont il a gagné `wins`.
Matchup _entry(String id, int games, int wins) =>
    duel(id, 'Dummy', lane: 'TOP', games: games, wins: wins);

final _data = dataset([
  _entry('Fort', 300, 177), // 59 %
  _entry('Solide', 300, 162), // 54 %
  _entry('Faible', 300, 120), // 40 %
  _entry('Rare', 20, 18), // trop peu de parties : pas fiable
  _entry('Joue', 300, 168), // 56 %
]);

BanAnalysis _analyze({
  List<String> blueBans = const [],
  List<String> redBans = const [],
  List<String> bluePicks = const [],
  List<String> redPicks = const [],
  DraftPlayers? players,
}) {
  return BanAnalyzer.analyze(
    blueBans: blueBans,
    redBans: redBans,
    bluePicks: bluePicks,
    redPicks: redPicks,
    dataset: _data,
    names: const {'Fort': 'Fort', 'Joue': 'Joué'},
    players: players,
  );
}

void main() {
  group('BanAnalyzer', () {
    test('sans bannissements, il n y a rien à juger', () {
      final analysis = _analyze(bluePicks: ['Fort']);

      expect(analysis.isEmpty, isTrue);
    });

    test('ignore les cases de bannissement restées vides', () {
      final analysis = _analyze(blueBans: ['', ''], redBans: ['']);

      expect(analysis.isEmpty, isTrue);
    });

    test('félicite un ban qui écarte un champion fort', () {
      final notes = _analyze(blueBans: ['Fort', 'Solide']).blue.join(' ');

      expect(notes, contains('Bannissements utiles'));
      expect(notes, contains('Fort (59 %)'));
      expect(notes, contains('Solide (54 %)'));
      expect(notes, contains('Vous avez écarté des champions'));
    });

    test('signale un ban sur un champion qui perd plus qu il ne gagne', () {
      final notes = _analyze(blueBans: ['Faible']).blue.join(' ');

      expect(notes, contains('Bannissements peu utiles'));
      expect(notes, contains('Faible (40 %)'));
      expect(notes, isNot(contains('Bannissements utiles')));
    });

    test('ne juge pas un champion trop peu joué', () {
      final notes = _analyze(blueBans: ['Rare']).blue.join(' ');

      expect(notes, isNot(contains('utiles')));
      expect(notes, contains('Aucune remarque'));
    });

    test('signale le champion fort laissé libre et joué par l adversaire', () {
      final notes = _analyze(
        blueBans: ['Faible'],
        redPicks: ['Joue'],
      ).blue.join(' ');

      expect(notes, contains('Joué (56 %) n\'a pas été banni'));
      expect(notes, contains('le site l\'a joué'));
    });

    test('ne reproche pas un champion que l adversaire a banni lui-même', () {
      final analysis = _analyze(
        blueBans: ['Faible'],
        redBans: ['Joue'],
        redPicks: ['Joue'],
      );

      expect(analysis.blue.join(' '), isNot(contains('n\'a pas été banni')));
    });

    test('limite les bannissements manqués signalés', () {
      final notes = _analyze(
        blueBans: ['Faible'],
        redPicks: ['Fort', 'Solide', 'Joue'],
      ).blue.where((note) => note.contains('n\'a pas été banni'));

      expect(notes, hasLength(BanAnalyzer.maxMissed));
      // Les plus forts d'abord.
      expect(notes.first, contains('Fort'));
    });

    test('en duel, nomme les joueurs au lieu de « vous » et du site', () {
      const players = DraftPlayers(blue: 'Léa', red: 'Tom');
      final analysis = _analyze(
        blueBans: ['Fort'],
        redBans: ['Faible'],
        redPicks: ['Joue'],
        bluePicks: ['Solide'],
        players: players,
      );

      final blue = analysis.blue.join(' ');
      expect(blue, contains('Léa a écarté'));
      expect(blue, contains('Tom l\'a joué'));
      expect(blue, isNot(contains('vous')));

      final red = analysis.red.join(' ');
      expect(red, contains('Bannissements peu utiles'));
      expect(red, contains('Léa l\'a joué'));
    });
  });

  group('DraftEvaluator : bannissements', () {
    final blue = [
      for (var role = 0; role < teamRoles.length; role++) member('b$role'),
    ];
    final red = [
      for (var role = 0; role < teamRoles.length; role++) member('r$role'),
    ];

    test('le bilan porte les remarques sur les bans du joueur', () {
      final report = DraftEvaluator.evaluate(
        blue: blue,
        red: red,
        dataset: _data,
        blueBans: ['Fort'],
        redBans: ['Faible'],
      );

      expect(report.banNotes.join(' '), contains('Bannissements utiles'));
      // Contre le site, le bilan ne parle que du joueur.
      expect(report.redBanNotes, isEmpty);
    });

    test('en duel, les deux joueurs ont leurs remarques', () {
      final report = DraftEvaluator.evaluate(
        blue: blue,
        red: red,
        dataset: _data,
        blueBans: ['Fort'],
        redBans: ['Faible'],
        players: const DraftPlayers(blue: 'Léa', red: 'Tom'),
      );

      expect(report.banNotes, isNotEmpty);
      // Les remarques du rouge portent sur ses bans, pas sur ceux du bleu.
      expect(report.redBanNotes.join(' '), contains('Faible'));
      expect(report.redBanNotes.join(' '), isNot(contains('Fort (')));
    });

    test('sans bannissements, aucune remarque', () {
      final report = DraftEvaluator.evaluate(
        blue: blue,
        red: red,
        dataset: _data,
      );

      expect(report.banNotes, isEmpty);
      expect(report.redBanNotes, isEmpty);
    });
  });
}
