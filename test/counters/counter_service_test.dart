import 'package:flutter_test/flutter_test.dart';
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

  test('écarte les champions trop peu rencontrés', () {
    final dataset = _dataset([
      _m('Ahri', 'Zed', games: 20, wins: 12),
      _m('Teemo', 'Zed', games: 3, wins: 3),
    ]);

    final picks = CounterService.counters('Zed', dataset);

    expect(picks.map((p) => p.championId), ['Ahri']);
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
