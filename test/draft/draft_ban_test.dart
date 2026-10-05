import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/draft/models/draft_state.dart';
import 'package:monapp/draft/services/draft_bot.dart';

import 'draft_support.dart';

/// Joue tous les bannissements : chaque camp écarte `Ban<camp><n>`.
DraftState _afterBans() {
  var state = DraftState.empty(withBans: true);
  var index = 0;
  while (state.isBanPhase) {
    final side = state.nextSide!;
    state = state.ban(side, champion('Ban${side.name}${index++}'));
  }

  return state;
}

void main() {
  group('bannissements', () {
    test('sans bannissements, la draft commence par un choix', () {
      final state = DraftState.empty();

      expect(state.hasBans, isFalse);
      expect(state.isBanPhase, isFalse);
      expect(state.nextSide, DraftSide.blue);
      expect(state.totalBans, 0);
    });

    test('les bannissements alternent un à un, le bleu en premier', () {
      var state = DraftState.empty(withBans: true);
      final sides = <DraftSide>[];

      while (state.isBanPhase) {
        final side = state.nextSide!;
        sides.add(side);
        state = state.ban(side, champion('C${sides.length}'));
      }

      expect(sides, draftBanOrder);
      expect(sides.where((s) => s == DraftSide.blue), hasLength(bansPerSide));
      expect(sides.where((s) => s == DraftSide.red), hasLength(bansPerSide));
    });

    test('aucun choix n est possible avant la fin des bannissements', () {
      final state = DraftState.empty(withBans: true);

      expect(state.isBanPhase, isTrue);
      expect(
        () => state.pick(DraftSide.blue, 0, champion('Ahri')),
        throwsStateError,
      );
    });

    test('après les bannissements, le bleu ouvre les choix', () {
      final state = _afterBans();

      expect(state.isBanPhase, isFalse);
      expect(state.banCount, 10);
      expect(state.pickCount, 0);
      expect(state.nextSide, DraftSide.blue);
    });

    test('un champion banni ne peut plus être choisi ni rebanni', () {
      final state = DraftState.empty(withBans: true)
          .ban(DraftSide.blue, champion('Zed'));

      expect(state.unavailableIds, {'Zed'});
      expect(state.pickedIds, isEmpty);
      expect(() => state.ban(DraftSide.red, champion('Zed')), throwsStateError);
    });

    test('un champion banni est refusé au moment du choix', () {
      final state = _afterBans();

      expect(
        () => state.pick(DraftSide.blue, 0, champion('Banblue0')),
        throwsStateError,
      );
      expect(
        state.pick(DraftSide.blue, 0, champion('Libre')).blue[0]!.id,
        'Libre',
      );
    });

    test('refuse de bannir hors de son tour', () {
      final state = DraftState.empty(withBans: true);

      expect(() => state.ban(DraftSide.red, champion('Zed')), throwsStateError);
    });

    test('refuse de bannir une fois les bannissements finis', () {
      final state = _afterBans();

      expect(
        () => state.ban(DraftSide.blue, champion('Tard')),
        throwsStateError,
      );
    });

    test('un bannissement ne modifie pas l état précédent', () {
      final before = DraftState.empty(withBans: true);
      final after = before.ban(DraftSide.blue, champion('Zed'));

      expect(before.banCount, 0);
      expect(after.banCount, 1);
      expect(after.blueBans.first!.id, 'Zed');
    });
  });

  group('DraftBot : bannissements', () {
    final pool = [for (var index = 0; index < 20; index++) champion('C$index')];

    // C0 gagne beaucoup et se joue souvent ; C1 perd ; les autres sont rares.
    final data = dataset([
      duel('C0', 'X', lane: 'TOP', games: 400, wins: 260),
      duel('C1', 'X', lane: 'TOP', games: 400, wins: 120),
      for (var index = 2; index < 20; index++)
        duel('C$index', 'X', lane: 'TOP', games: 12, wins: 6),
    ]);

    test('bannit un champion encore libre', () {
      var state = DraftState.empty(withBans: true);
      final bot = DraftBot(dataset: data, random: Random(2));

      while (state.isBanPhase) {
        final side = state.nextSide!;
        final banned = bot.chooseBan(state: state, pool: pool);

        expect(state.unavailableIds, isNot(contains(banned.id)));
        state = state.ban(side, banned);
      }

      expect(state.banCount, 10);
    });

    test('vise d abord les champions forts et très joués', () {
      final state = DraftState.empty(withBans: true);

      for (var seed = 0; seed < 30; seed++) {
        final bot = DraftBot(dataset: data, random: Random(seed));
        final banned = bot.chooseBan(state: state, pool: pool);

        // Le champion qui perd 70 % du temps ne figure jamais parmi les bans.
        expect(banned.id, isNot('C1'));
      }
    });

    test('ne choisit jamais un champion banni', () {
      final state = _afterBans();
      final bot = DraftBot(dataset: data, random: Random(4));
      final banned = {...state.unavailableIds};

      for (var turn = 0; turn < 20; turn++) {
        final choice = bot.choose(
          state: state,
          side: DraftSide.blue,
          pool: [...pool, for (final id in banned) champion(id)],
        );

        expect(banned, isNot(contains(choice.champion.id)));
      }
    });
  });
}
