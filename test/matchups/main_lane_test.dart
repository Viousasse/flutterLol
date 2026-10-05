import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/matchups/models/matchup.dart';
import 'package:monapp/matchups/services/matchup_service.dart';

Matchup _m(String lane, int games) => Matchup(
  championId: 'Ahri',
  opponentId: 'Zed',
  lane: lane,
  games: games,
  wins: games ~/ 2,
);

void main() {
  test('retient la voie où le champion a le plus joué', () {
    final dataset = MatchupDataset(
      patch: '16.18',
      matches: 1,
      matchups: [_m('MIDDLE', 60), _m('TOP', 10), _m('MIDDLE', 5)],
    );

    expect(MatchupService.mainLaneOf('Ahri', dataset), 'MIDDLE');
  });

  test('ne conclut pas quand les données sont trop rares', () {
    final dataset = MatchupDataset(
      patch: '16.18',
      matches: 1,
      matchups: [_m('MIDDLE', MatchupService.minGamesForMainLane - 1)],
    );

    expect(MatchupService.mainLaneOf('Ahri', dataset), isNull);
  });

  test('ignore les parties des autres champions', () {
    final dataset = MatchupDataset(
      patch: '16.18',
      matches: 1,
      matchups: [_m('MIDDLE', 60)],
    );

    expect(MatchupService.mainLaneOf('Garen', dataset), isNull);
  });
}
