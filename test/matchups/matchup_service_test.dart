import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/matchups/models/matchup.dart';
import 'package:monapp/matchups/services/matchup_service.dart';

Matchup _m(String opponent, {required int games, required int wins}) => Matchup(
  championId: 'Darius',
  opponentId: opponent,
  lane: 'TOP',
  games: games,
  wins: wins,
);

void main() {
  final dataset = MatchupDataset(
    patch: '16.18',
    matches: 100,
    matchups: [
      _m('Garen', games: 20, wins: 6), // 30 %
      _m('Fiora', games: 12, wins: 4), // 33 %
      _m('Nasus', games: 15, wins: 11), // 73 %
      _m('Teemo', games: 3, wins: 0), // trop peu de parties
      const Matchup(
        championId: 'Garen',
        opponentId: 'Darius',
        lane: 'TOP',
        games: 20,
        wins: 14,
      ),
    ],
  );

  test('classe les adversaires difficiles du pire au moins mauvais', () {
    final hardest = MatchupService.hardestFor('Darius', dataset);

    expect(hardest.map((m) => m.opponentId), ['Garen', 'Fiora', 'Nasus']);
  });

  test('classe les adversaires favorables du meilleur au moins bon', () {
    final easiest = MatchupService.easiestFor('Darius', dataset);

    expect(easiest.first.opponentId, 'Nasus');
  });

  test('tait les paires jouées trop peu de fois', () {
    final all = MatchupService.hardestFor('Darius', dataset);

    expect(all.map((m) => m.opponentId), isNot(contains('Teemo')));
  });

  test("ne mélange pas les matchups d'un autre champion", () {
    final all = MatchupService.hardestFor('Darius', dataset);

    expect(all.every((m) => m.championId == 'Darius'), isTrue);
  });

  test('lit le fichier généré et tolère un fichier vide', () {
    final empty = MatchupDataset.fromJson({'matches': 0, 'matchups': []});
    expect(empty.isEmpty, isTrue);

    final parsed = MatchupDataset.fromJson({
      'patch': '16.18',
      'matches': 1,
      'matchups': [
        {
          'champion': 'Ahri',
          'opponent': 'Zed',
          'lane': 'MIDDLE',
          'games': 9,
          'wins': 5,
        },
      ],
    });
    expect(parsed.matchups.single.winRate, closeTo(0.556, 0.001));
  });

  test('additionne toutes les parties d un champion en bilan global', () {
    final record = MatchupService.overallFor('Darius', dataset);

    // Toutes les paires comptent, même celles trop rares pour être affichées.
    expect(record.games, 20 + 12 + 15 + 3);
    expect(record.wins, 6 + 4 + 11 + 0);
    expect(record.isReliable, isFalse);
  });

  test('le bilan global n est fiable qu au-delà d un seuil de parties', () {
    const big = OverallRecord(games: OverallRecord.minReliableGames, wins: 52);

    expect(big.isReliable, isTrue);
    expect(big.winRate, closeTo(0.52, 0.001));
    expect(const OverallRecord.none().winRate, 0);
  });

  test('donne le bilan d un duel précis, ou rien s il est trop rare', () {
    final duel = MatchupService.headToHead('Darius', 'Garen', dataset);
    final rare = MatchupService.headToHead('Darius', 'Teemo', dataset);
    final unknown = MatchupService.headToHead('Darius', 'Ahri', dataset);

    expect(duel!.games, 20);
    expect(duel.winRate, closeTo(0.3, 0.001));
    expect(rare, isNull);
    expect(unknown, isNull);
  });
}
