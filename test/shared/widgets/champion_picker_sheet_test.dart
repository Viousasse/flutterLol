import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/champions/models/champion.dart';
import 'package:monapp/shared/widgets/champion_picker_sheet/champion_picker_sheet.dart';
import 'package:monapp/shared/widgets/champion_picker_sheet/champion_role_filter.dart';

Champion _champion(String id) {
  return Champion(
    id: id,
    name: id,
    title: 'titre',
    blurb: '',
    imageUrl: '',
    tags: const [],
  );
}

/// Garen et Fiora vont en haut, Ahri au milieu, Lux se joue aux deux.
const _lanes = {
  'Garen': {'TOP'},
  'Fiora': {'TOP'},
  'Ahri': {'MIDDLE'},
  'Lux': {'MIDDLE', 'UTILITY'},
};

ChampionRoleFilter _filter({String? initialLane}) {
  return ChampionRoleFilter(
    roles: const {'Top': 'TOP', 'Milieu': 'MIDDLE', 'Support': 'UTILITY'},
    fits: (id, lane) => _lanes[id]?.contains(lane) ?? false,
    initialLane: initialLane,
  );
}

Future<void> _open(
  WidgetTester tester, {
  ChampionRoleFilter? filter,
  Set<String> excluded = const {},
}) async {
  tester.view.physicalSize = const Size(800, 1600);
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ChampionPickerSheet(
          champions: [
            _champion('Garen'),
            _champion('Fiora'),
            _champion('Ahri'),
            _champion('Lux'),
            _champion('Inconnu'),
          ],
          excludedIds: excluded,
          roleFilter: filter,
        ),
      ),
    ),
  );
}

Finder _name(String id) => find.widgetWithText(ListTile, id);

void main() {
  testWidgets('sans filtre de rôle, aucune puce n est affichée', (
    tester,
  ) async {
    await _open(tester);

    expect(find.text('Tous'), findsNothing);
    expect(_name('Garen'), findsOneWidget);
    expect(_name('Inconnu'), findsOneWidget);
  });

  testWidgets('démarre sur le rôle demandé', (tester) async {
    await _open(tester, filter: _filter(initialLane: 'MIDDLE'));

    expect(_name('Ahri'), findsOneWidget);
    expect(_name('Lux'), findsOneWidget);
    expect(_name('Garen'), findsNothing);
    expect(_name('Inconnu'), findsNothing);
  });

  testWidgets('sans rôle de départ, montre tous les champions', (tester) async {
    await _open(tester, filter: _filter());

    expect(_name('Garen'), findsOneWidget);
    expect(_name('Ahri'), findsOneWidget);
    // Un champion inconnu des données reste accessible via « Tous ».
    expect(_name('Inconnu'), findsOneWidget);
  });

  testWidgets('une puce change de rôle, « Tous » les montre tous', (
    tester,
  ) async {
    await _open(tester, filter: _filter(initialLane: 'MIDDLE'));

    await tester.tap(find.text('Top'));
    await tester.pump();
    expect(_name('Garen'), findsOneWidget);
    expect(_name('Fiora'), findsOneWidget);
    expect(_name('Ahri'), findsNothing);

    await tester.tap(find.text('Tous'));
    await tester.pump();
    expect(_name('Ahri'), findsOneWidget);
    expect(_name('Inconnu'), findsOneWidget);
  });

  testWidgets('un champion polyvalent figure dans chacun de ses rôles', (
    tester,
  ) async {
    await _open(tester, filter: _filter(initialLane: 'UTILITY'));

    expect(_name('Lux'), findsOneWidget);
    expect(_name('Ahri'), findsNothing);
  });

  testWidgets('le filtre de rôle se combine avec la recherche', (tester) async {
    await _open(tester, filter: _filter(initialLane: 'TOP'));

    await tester.enterText(find.byType(TextField), 'fio');
    await tester.pump();

    expect(_name('Fiora'), findsOneWidget);
    expect(_name('Garen'), findsNothing);
  });

  testWidgets('les champions exclus restent absents, quel que soit le rôle', (
    tester,
  ) async {
    await _open(
      tester,
      filter: _filter(initialLane: 'TOP'),
      excluded: {'Garen'},
    );

    expect(_name('Garen'), findsNothing);
    expect(_name('Fiora'), findsOneWidget);
  });
}
