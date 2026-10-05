import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/draft/models/draft_state.dart';
import 'package:monapp/draft/services/draft_bot.dart';
import 'package:monapp/matchups/services/lane_profile.dart';
import 'package:monapp/matchups/models/matchup.dart';
import 'package:monapp/team/constants/team_roles.dart';

import 'draft_support.dart';

/// Un champion qui a joué `games` parties dans `lane`.
List<Matchup> _plays(String id, String lane, {int games = 40}) {
  return [duel(id, 'Dummy', lane: lane, games: games, wins: games ~/ 2)];
}

void main() {
  group('LaneProfile', () {
    final profile = LaneProfile.fromDataset(
      dataset([
        duel('Ahri', 'X', lane: 'MIDDLE', games: 90, wins: 45),
        duel('Ahri', 'X', lane: 'TOP', games: 10, wins: 5),
        duel('Garen', 'X', lane: 'TOP', games: 50, wins: 25),
      ]),
    );

    test('reconnaît la voie principale d un champion', () {
      expect(profile.fits('Ahri', 'MIDDLE'), isTrue);
      expect(profile.fits('Garen', 'TOP'), isTrue);
    });

    test('écarte un pari isolé dans une autre voie', () {
      // 10 parties sur 100 : sous le seuil de 15 %.
      expect(profile.fits('Ahri', 'TOP'), isFalse);
      expect(profile.fits('Garen', 'MIDDLE'), isFalse);
    });

    test('ne connaît pas un champion absent des données', () {
      expect(profile.fits('Inconnu', 'TOP'), isFalse);
    });
  });

  group('DraftBot', () {
    final midLaners = [
      for (var index = 0; index < 6; index++) champion('Mid$index'),
    ];
    final topLaners = [
      for (var index = 0; index < 6; index++) champion('Top$index'),
    ];
    final pool = [...midLaners, ...topLaners];

    final data = dataset([
      for (final c in midLaners) ..._plays(c.id, 'MIDDLE'),
      for (final c in topLaners) ..._plays(c.id, 'TOP'),
    ]);

    DraftState stateWithOnlyMidEmptyForRed() {
      var state = DraftState.empty();
      for (var role = 0; role < teamRoles.length; role++) {
        state = state.pick(DraftSide.blue, role, champion('Blue$role'));
        if (role != 2) state = state.pick(DraftSide.red, role, champion('Red$role'));
      }

      return state;
    }

    test('joue un champion qui se joue à ce poste', () {
      for (var seed = 0; seed < 20; seed++) {
        final bot = DraftBot(dataset: data, random: Random(seed));

        final choice = bot.choose(
          state: stateWithOnlyMidEmptyForRed(),
          side: DraftSide.red,
          pool: pool,
        );

        expect(choice.roleIndex, 2);
        expect(choice.champion.id, startsWith('Mid'));
      }
    });

    test('ne reprend jamais un champion déjà choisi', () {
      var state = DraftState.empty();
      final bot = DraftBot(dataset: data, random: Random(1));

      state = state.pick(DraftSide.blue, 2, midLaners.first);

      for (var turn = 0; turn < 5; turn++) {
        final choice = bot.choose(state: state, side: DraftSide.red, pool: pool);

        expect(state.pickedIds, isNot(contains(choice.champion.id)));
        state = state.pick(DraftSide.red, choice.roleIndex, choice.champion);
      }
    });

    test('préfère contrer un rôle que l adversaire a déjà pris', () {
      var state = DraftState.empty();
      state = state.pick(DraftSide.blue, 0, champion('Blue0'));
      final bot = DraftBot(dataset: data, random: Random(3));

      final choice = bot.choose(state: state, side: DraftSide.red, pool: pool);

      expect(choice.roleIndex, 0);
    });

    test('contre l adversaire de la voie quand un champion le bat nettement', () {
      final topWithCounter = dataset([
        for (final c in topLaners) ..._plays(c.id, 'TOP'),
        duel('Top5', 'Blue0', lane: 'TOP', games: 40, wins: 32),
      ]);
      var state = DraftState.empty();
      state = state.pick(DraftSide.blue, 0, champion('Blue0'));

      var counterPicks = 0;
      for (var seed = 0; seed < 30; seed++) {
        final bot = DraftBot(dataset: topWithCounter, random: Random(seed));
        final choice = bot.choose(state: state, side: DraftSide.red, pool: pool);

        if (choice.champion.id == 'Top5') counterPicks++;
      }

      // Le site tire parmi ses trois meilleures options : le contre-pick, bien
      // devant, y figure presque toujours.
      expect(counterPicks, greaterThan(5));
    });

    test('retombe sur n importe quel champion libre faute de données', () {
      final bot = DraftBot(dataset: const MatchupDataset.empty());

      final choice = bot.choose(
        state: DraftState.empty(),
        side: DraftSide.red,
        pool: pool,
      );

      expect(pool.map((c) => c.id), contains(choice.champion.id));
    });
  });
}
