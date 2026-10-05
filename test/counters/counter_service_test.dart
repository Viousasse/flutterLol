import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/counters/models/counter_pick.dart';
import 'package:monapp/counters/services/counter_service.dart';
import 'package:monapp/matchups/models/matchup.dart';

Matchup _m(
  String champion,
  String opponent, {
  required int games,
  required int wins,
  String lane = 'MIDDLE',
}) {
  return Matchup(
    championId: champion,
    opponentId: opponent,
    lane: lane,
    games: games,
    wins: wins,
  );
}

MatchupDataset _dataset(List<Matchup> matchups) {
  return MatchupDataset(patch: '16.18', matches: 100, matchups: matchups);
}

void main() {
  strengthTests();

  test('classe les champions qui battent l adversaire, du meilleur au pire', () {
    final dataset = _dataset([
      _m('Ahri', 'Zed', games: 20, wins: 12),
      _m('Fizz', 'Zed', games: 20, wins: 14),
      _m('Yasuo', 'Zed', games: 20, wins: 8),
      _m('Zed', 'Ahri', games: 20, wins: 8),
    ]);

    final picks = CounterService.counters('Zed', dataset);

    expect(picks.map((p) => p.championId), ['Fizz', 'Ahri', 'Yasuo']);
    expect(picks.first.winRate, closeTo(0.7, 0.001));
  });

  test('sans repli, écarte les champions trop peu rencontrés', () {
    final dataset = _dataset([
      _m('Ahri', 'Zed', games: 20, wins: 12),
      _m('Teemo', 'Zed', games: 3, wins: 3),
    ]);

    final picks = CounterService.counters(
      'Zed',
      dataset,
      includeLowConfidence: false,
    );

    expect(picks.map((p) => p.championId), ['Ahri']);
  });

  test('complète avec des champions peu rencontrés quand il y a peu de données', () {
    final dataset = _dataset([
      _m('Ahri', 'Zed', games: 20, wins: 12),
      _m('Teemo', 'Zed', games: 3, wins: 3),
    ]);

    final picks = CounterService.counters('Zed', dataset);

    expect(picks.map((p) => p.championId), ['Ahri', 'Teemo']);
    expect(picks.first.isReliable, isTrue);
    expect(picks.last.isReliable, isFalse);
  });

  test('un adversaire sans aucun bilan fiable reçoit tout de même des propositions', () {
    final dataset = _dataset([
      _m('Ahri', 'Zed', games: 4, wins: 3),
      _m('Fizz', 'Zed', games: 2, wins: 1),
    ]);

    final picks = CounterService.counters('Zed', dataset);

    expect(picks, isNotEmpty);
    expect(picks.every((p) => !p.isReliable), isTrue);
  });

  test('ne complète pas la liste quand les bilans fiables suffisent', () {
    final dataset = _dataset([
      for (var i = 0; i < CounterService.minReliablePicks; i++)
        _m('Champion$i', 'Zed', games: 20, wins: 10),
      _m('Teemo', 'Zed', games: 3, wins: 3),
    ]);

    final picks = CounterService.counters('Zed', dataset);

    expect(picks.map((p) => p.championId), isNot(contains('Teemo')));
  });

  test('classe les petits échantillons avec un taux tempéré', () {
    final dataset = _dataset([
      _m('Chanceux', 'Zed', games: 2, wins: 2),
      _m('Solide', 'Zed', games: 7, wins: 6),
    ]);

    final picks = CounterService.counters('Zed', dataset);

    // 2 sur 2 ne doit pas passer devant 6 sur 7 : l'échantillon est trop mince.
    expect(picks.map((p) => p.championId), ['Solide', 'Chanceux']);
  });

  test('le taux tempéré rapproche les petits échantillons de 50 %', () {
    const lucky = CounterPick(championId: 'A', games: 3, wins: 3);
    const proven = CounterPick(championId: 'B', games: 200, wins: 120);

    expect(lucky.smoothedWinRate, lessThan(0.65));
    expect(lucky.winRate, 1);
    expect(proven.smoothedWinRate, closeTo(proven.winRate, 0.02));
  });

  test('chaque champion des vraies données reçoit des contre-picks', () {
    final raw = jsonDecode(
      File('assets/data/champion_matchups.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final real = MatchupDataset.fromJson(raw);

    final opponents = {for (final m in real.matchups) m.opponentId};
    final withoutData = [
      for (final id in opponents)
        if (CounterService.counters(id, real).isEmpty) id,
    ];

    expect(opponents, isNotEmpty);
    expect(withoutData, isEmpty);
  });

  test('sans voie, additionne les parties d un même champion', () {
    final dataset = _dataset([
      _m('Ahri', 'Zed', games: 6, wins: 5, lane: 'MIDDLE'),
      _m('Ahri', 'Zed', games: 6, wins: 4, lane: 'TOP'),
    ]);

    final picks = CounterService.counters('Zed', dataset);

    // Aucune voie ne dépasse le seuil seule, mais ensemble elles le franchissent.
    expect(picks.single.games, 12);
    expect(picks.single.wins, 9);
  });

  test('restreint à une voie quand on la demande', () {
    final dataset = _dataset([
      _m('Ahri', 'Zed', games: 20, wins: 14, lane: 'MIDDLE'),
      _m('Garen', 'Zed', games: 20, wins: 16, lane: 'TOP'),
    ]);

    final middle = CounterService.counters('Zed', dataset, lane: 'MIDDLE');

    expect(middle.map((p) => p.championId), ['Ahri']);
  });

  test('à pourcentage égal, le plus de parties passe devant', () {
    final dataset = _dataset([
      _m('Ahri', 'Zed', games: 10, wins: 6),
      _m('Fizz', 'Zed', games: 30, wins: 18),
    ]);

    final picks = CounterService.counters('Zed', dataset);

    expect(picks.map((p) => p.championId), ['Fizz', 'Ahri']);
  });

  test('limite la liste aux meilleures propositions', () {
    final dataset = _dataset([
      for (var i = 0; i < 30; i++) _m('Champion$i', 'Zed', games: 20, wins: 10),
    ]);

    final picks = CounterService.counters('Zed', dataset);

    expect(picks, hasLength(CounterService.maxPicks));
  });

  test('liste les voies où l adversaire a été affronté, la plus jouée d abord', () {
    final dataset = _dataset([
      _m('Ahri', 'Zed', games: 10, wins: 5, lane: 'TOP'),
      _m('Fizz', 'Zed', games: 40, wins: 20, lane: 'MIDDLE'),
      _m('Fizz', 'Zed', games: 5, wins: 2, lane: 'MIDDLE'),
    ]);

    expect(CounterService.lanesFor('Zed', dataset), ['MIDDLE', 'TOP']);
    expect(CounterService.lanesFor('Inconnu', dataset), isEmpty);
  });
}

void strengthTests() {
  group('points forts', () {
    final dataset = _dataset([
      _m('Ahri', 'Zed', games: 20, wins: 14, lane: 'MIDDLE'),
      _m('Ahri', 'Fizz', games: 20, wins: 6, lane: 'MIDDLE'),
      _m('Ahri', 'Yasuo', games: 20, wins: 12, lane: 'MIDDLE'),
      _m('Ahri', 'Garen', games: 20, wins: 5, lane: 'TOP'),
      _m('Ahri', 'Teemo', games: 3, wins: 3, lane: 'TOP'),
      _m('Zed', 'Ahri', games: 20, wins: 6, lane: 'MIDDLE'),
    ]);

    test('classe les adversaires contre lesquels le champion gagne le plus', () {
      final picks = CounterService.strongAgainst(
        'Ahri',
        dataset,
        includeLowConfidence: false,
      );

      // `championId` désigne ici l'adversaire.
      expect(picks.map((p) => p.championId), ['Zed', 'Yasuo', 'Fizz', 'Garen']);
      expect(picks.first.winRate, closeTo(0.7, 0.001));
    });

    test('ignore les duels des autres champions', () {
      final picks = CounterService.strongAgainst('Zed', dataset);

      expect(picks.map((p) => p.championId), ['Ahri']);
    });

    test('liste les faiblesses du pire au moins mauvais, bilans fiables seulement', () {
      final weak = CounterService.weakAgainst('Ahri', dataset);

      expect(weak.map((p) => p.championId), ['Garen', 'Fizz']);
      expect(weak.every((p) => p.winRate < 0.5 && p.isReliable), isTrue);
    });

    test('limite les faiblesses listées', () {
      final many = _dataset([
        for (var i = 0; i < 12; i++)
          _m('Ahri', 'Champion$i', games: 20, wins: 4),
      ]);

      expect(
        CounterService.weakAgainst('Ahri', many),
        hasLength(CounterService.maxWeaknesses),
      );
    });

    test('se restreint à une voie', () {
      final top = CounterService.strongAgainst(
        'Ahri',
        dataset,
        lane: 'TOP',
        includeLowConfidence: false,
      );

      expect(top.map((p) => p.championId), ['Garen']);
    });

    test('un champion sans aucune faiblesse reçoit une liste vide', () {
      final dominant = _dataset([
        _m('Ahri', 'Zed', games: 20, wins: 15),
        _m('Ahri', 'Fizz', games: 20, wins: 12),
      ]);

      expect(CounterService.weakAgainst('Ahri', dominant), isEmpty);
    });

    test('liste les voies jouées par le champion, la plus jouée d abord', () {
      final lanes = CounterService.lanesPlayedBy('Ahri', dataset);

      expect(lanes, ['MIDDLE', 'TOP']);
      expect(CounterService.lanesPlayedBy('Inconnu', dataset), isEmpty);
    });

    test('chaque champion des vraies données a des points forts', () {
      final raw = jsonDecode(
        File('assets/data/champion_matchups.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final real = MatchupDataset.fromJson(raw);

      final played = {for (final m in real.matchups) m.championId};
      final without = [
        for (final id in played)
          if (CounterService.strongAgainst(id, real).isEmpty) id,
      ];

      expect(played, isNotEmpty);
      expect(without, isEmpty);
    });
  });
}
