import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/champions/models/champion.dart';
import 'package:monapp/draft/models/draft_state.dart';
import 'package:monapp/draft/services/draft_advisor.dart';
import 'package:monapp/matchups/models/matchup.dart';
import 'package:monapp/team/constants/team_roles.dart';

import 'draft_support.dart';

/// Un champion qui a joué `games` parties dans `lane`, à moitié gagnées.
Matchup _plays(String id, String lane, {int games = 40}) {
  return duel(id, 'Dummy', lane: lane, games: games, wins: games ~/ 2);
}

/// Le camp bleu a rempli ses cinq rôles, le rouge n'a rien choisi.
DraftState _blueDone({Champion? mid}) {
  var state = DraftState.empty();
  for (var role = 0; role < teamRoles.length; role++) {
    final picked = role == 2 && mid != null ? mid : champion('Blue$role');
    state = state.pick(DraftSide.blue, role, picked);
  }

  return state;
}

void main() {
  final mids = [for (var i = 0; i < 4; i++) champion('Mid$i')];
  final tops = [for (var i = 0; i < 2; i++) champion('Top$i')];
  final pool = [...mids, ...tops];

  final baseMatchups = [
    for (final c in mids) _plays(c.id, 'MIDDLE'),
    for (final c in tops) _plays(c.id, 'TOP'),
  ];

  group('DraftAdvisor', () {
    test('ne conseille rien pendant les bannissements', () {
      final advisor = DraftAdvisor(dataset: dataset(baseMatchups));

      final result = advisor.suggest(
        state: DraftState.empty(withBans: true),
        side: DraftSide.blue,
        pool: pool,
      );

      expect(result, isEmpty);
    });

    test('ne conseille rien quand la draft est finie', () {
      final advisor = DraftAdvisor(dataset: dataset(baseMatchups));
      var state = DraftState.empty();
      for (var role = 0; role < teamRoles.length; role++) {
        state = state.pick(DraftSide.blue, role, champion('Blue$role'));
        state = state.pick(DraftSide.red, role, champion('Red$role'));
      }

      final result = advisor.suggest(
        state: state,
        side: DraftSide.blue,
        pool: pool,
      );

      expect(result, isEmpty);
    });

    test('est déterministe', () {
      final advisor = DraftAdvisor(dataset: dataset(baseMatchups));
      final state = _blueDone();

      final first = advisor.suggest(
        state: state,
        side: DraftSide.red,
        pool: pool,
      );
      final second = advisor.suggest(
        state: state,
        side: DraftSide.red,
        pool: pool,
      );

      expect(first, isNotEmpty);
      expect(
        [for (final s in first) (s.champion.id, s.roleIndex, s.score)],
        [for (final s in second) (s.champion.id, s.roleIndex, s.score)],
      );
    });

    test('privilégie le contre de l adversaire de voie', () {
      final data = dataset([
        ...baseMatchups,
        duel('Mid1', 'Zed', lane: 'MIDDLE', games: 40, wins: 28),
        duel('Mid2', 'Zed', lane: 'MIDDLE', games: 40, wins: 12),
      ]);
      final advisor = DraftAdvisor(dataset: data);

      final result = advisor.suggest(
        state: _blueDone(mid: champion('Zed')),
        side: DraftSide.red,
        pool: pool,
      );

      final best = result.first;
      expect(best.champion.id, 'Mid1');
      expect(best.roleIndex, 2);
      expect(
        best.reasons.first,
        'Gagne 70 % contre Zed au milieu (40 parties).',
      );
    });

    test('ne propose ni un champion banni ni un champion pris', () {
      final advisor = DraftAdvisor(dataset: dataset(baseMatchups));
      var state = DraftState.empty(withBans: true);
      // Neuf bannissements hors pool, le dernier vise Mid0.
      for (var turn = 0; turn < draftBanOrder.length; turn++) {
        final banned = turn == draftBanOrder.length - 1
            ? mids[0]
            : champion('Ban$turn');
        state = state.ban(draftBanOrder[turn], banned);
      }
      state = state.pick(DraftSide.blue, 0, tops[0]);

      final result = advisor.suggest(
        state: state,
        side: DraftSide.red,
        pool: pool,
        count: 10,
      );

      expect(result, isNotEmpty);
      final ids = [for (final s in result) s.champion.id];
      expect(ids, isNot(contains('Mid0')));
      expect(ids, isNot(contains('Top0')));
    });

    test('propose des champions différents', () {
      final advisor = DraftAdvisor(dataset: dataset(baseMatchups));

      final result = advisor.suggest(
        state: _blueDone(),
        side: DraftSide.red,
        pool: pool,
        count: 5,
      );

      final ids = [for (final s in result) s.champion.id];
      expect(ids.toSet().length, ids.length);
    });

    test('respecte count', () {
      final advisor = DraftAdvisor(dataset: dataset(baseMatchups));
      final state = _blueDone();

      expect(
        advisor.suggest(state: state, side: DraftSide.red, pool: pool).length,
        3,
      );
      expect(
        advisor
            .suggest(state: state, side: DraftSide.red, pool: pool, count: 1)
            .length,
        1,
      );
    });

    test('reste honnête quand les données manquent', () {
      final advisor = DraftAdvisor(dataset: dataset(const []));

      final result = advisor.suggest(
        state: _blueDone(),
        side: DraftSide.red,
        pool: pool,
      );

      expect(result, isNotEmpty);
      for (final suggestion in result) {
        expect(suggestion.reasons, [DraftAdvisor.fallbackReason]);
      }
    });

    test('ne cite pas un duel trop peu joué', () {
      final data = dataset([
        ...baseMatchups,
        duel('Mid1', 'Zed', lane: 'MIDDLE', games: 5, wins: 5),
      ]);
      final advisor = DraftAdvisor(dataset: data);

      final result = advisor.suggest(
        state: _blueDone(mid: champion('Zed')),
        side: DraftSide.red,
        pool: pool,
        count: 10,
      );

      for (final suggestion in result) {
        expect(suggestion.reasons.join(' '), isNot(contains('contre Zed')));
      }
    });

    test('signale le comble du manque de dégâts magiques', () {
      final mage = champion('Mage', attack: 3, magic: 8);
      final data = dataset([...baseMatchups, _plays('Mage', 'MIDDLE')]);
      final advisor = DraftAdvisor(dataset: data);

      var state = _blueDone();
      state = state.pick(
        DraftSide.red,
        0,
        champion('Brute', attack: 8, magic: 0),
      );

      final result = advisor.suggest(
        state: state,
        side: DraftSide.red,
        pool: [...pool, mage],
        count: 10,
      );

      final suggestion = result.firstWhere((s) => s.champion.id == 'Mage');
      expect(
        suggestion.reasons,
        contains('Comble le manque de dégâts magiques de votre équipe.'),
      );
    });
  });
}
