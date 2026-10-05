import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/draft/models/draft_state.dart';

import 'draft_support.dart';

void main() {
  test('le camp bleu ouvre, puis les camps se répondent par deux', () {
    var state = DraftState.empty();
    final sides = <DraftSide>[];

    // On remplit dans l'ordre des rôles de chaque camp.
    final nextRole = {DraftSide.blue: 0, DraftSide.red: 0};

    while (!state.isComplete) {
      final side = state.nextSide!;
      sides.add(side);
      final role = nextRole[side]!;
      nextRole[side] = role + 1;
      state = state.pick(side, role, champion('${side.name}$role'));
    }

    expect(sides, draftPickOrder);
    expect(state.nextSide, isNull);
    expect(state.pickCount, 10);
  });

  test('chaque camp joue exactement cinq fois', () {
    final blue = draftPickOrder.where((side) => side == DraftSide.blue);
    final red = draftPickOrder.where((side) => side == DraftSide.red);

    expect(blue, hasLength(5));
    expect(red, hasLength(5));
  });

  test('un choix ne modifie pas l état précédent', () {
    final before = DraftState.empty();
    final after = before.pick(DraftSide.blue, 0, champion('Ahri'));

    expect(before.pickCount, 0);
    expect(after.pickCount, 1);
    expect(after.blue[0]!.id, 'Ahri');
  });

  test('refuse un rôle déjà pris', () {
    final state = DraftState.empty().pick(DraftSide.blue, 0, champion('Ahri'));

    expect(
      () => state.pick(DraftSide.blue, 0, champion('Zed')),
      throwsStateError,
    );
  });

  test('refuse un champion déjà choisi, même par l autre camp', () {
    final state = DraftState.empty().pick(DraftSide.blue, 0, champion('Ahri'));

    expect(
      () => state.pick(DraftSide.red, 1, champion('Ahri')),
      throwsStateError,
    );
    expect(state.pickedIds, {'Ahri'});
  });

  test('le côté opposé est l autre camp', () {
    expect(DraftSide.blue.opposite, DraftSide.red);
    expect(DraftSide.red.opposite, DraftSide.blue);
  });
}
