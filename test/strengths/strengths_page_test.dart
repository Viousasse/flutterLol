import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/champions/models/champion.dart';
import 'package:monapp/matchups/models/matchup.dart';
import 'package:monapp/shared/widgets/champion_picker_sheet/champion_picker_sheet.dart';
import 'package:monapp/shared/widgets/counter_tile/counter_tile.dart';
import 'package:monapp/shared/widgets/data_source_note/data_source_note.dart';
import 'package:monapp/strengths/strengths_page.dart';

import '../counters/counter_pages_support.dart';
import '../draft/draft_support.dart';

final _champions = [
  for (final id in ['Moi', 'Alpha', 'Bravo', 'Charlie', 'Delta'])
    fakeChampion(id),
];

/// « Moi » écrase Alpha (70 %), tient face à Bravo (55 %), s'écroule contre
/// Charlie (30 %, en haut) et n'a que trois parties contre Delta.
final _data = dataset([
  duel('Moi', 'Alpha', lane: 'MIDDLE', games: 100, wins: 70),
  duel('Moi', 'Bravo', lane: 'MIDDLE', games: 100, wins: 55),
  duel('Moi', 'Charlie', lane: 'TOP', games: 60, wins: 18),
  duel('Moi', 'Delta', lane: 'TOP', games: 3, wins: 3),
]);

Widget _page({
  Future<List<Champion>> Function()? loadChampions,
  Future<MatchupDataset> Function()? loadDataset,
  String? initialChampionId,
}) {
  return MaterialApp(
    home: StrengthsPage(
      initialChampionId: initialChampionId,
      loadChampions: loadChampions ?? () async => _champions,
      loadDataset: loadDataset ?? () async => _data,
    ),
  );
}

Future<void> _open(WidgetTester tester, Widget page) async {
  useTallScreen(tester);
  await tester.pumpWidget(page);
  await settle(tester);
}

List<String> _opponentNames(WidgetTester tester) {
  return [
    for (final tile in tester.widgetList<CounterTile>(find.byType(CounterTile)))
      tile.champion.name,
  ];
}

void main() {
  testWidgets('affiche un indicateur pendant le chargement', (tester) async {
    final champions = Completer<List<Champion>>();
    useTallScreen(tester);

    await tester.pumpWidget(_page(loadChampions: () => champions.future));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    champions.complete(_champions);
    await settle(tester);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Choisir mon champion'), findsOneWidget);
  });

  testWidgets('un échec propose Réessayer, puis la page se charge', (
    tester,
  ) async {
    var attempts = 0;

    await _open(
      tester,
      _page(
        loadChampions: () async {
          attempts++;
          if (attempts == 1) throw Exception('hors ligne');

          return _champions;
        },
      ),
    );

    expect(find.text('Chargement impossible pour le moment.'), findsOneWidget);

    await tester.tap(find.text('Réessayer'));
    await settle(tester);

    expect(attempts, 2);
    expect(find.text('Chargement impossible pour le moment.'), findsNothing);
    expect(find.text('Choisir mon champion'), findsOneWidget);
  });

  testWidgets('invite à choisir son champion', (tester) async {
    await _open(tester, _page());

    expect(find.textContaining('Choisissez votre champion'), findsOneWidget);
    expect(find.byType(CounterTile), findsNothing);
  });

  testWidgets('la feuille de choix a le filtre de rôle', (tester) async {
    await _open(tester, _page());

    await tester.tap(find.text('Choisir mon champion'));
    await settle(tester);

    expect(find.byType(ChampionPickerSheet), findsOneWidget);
    for (final label in ['Tous', 'Top', 'Jungle', 'Milieu', 'Bot', 'Support']) {
      expect(sheetText(label), findsOneWidget, reason: label);
    }

    // « Moi » se joue au milieu et en haut ; les autres n'ont aucune partie à
    // leur nom.
    await tester.tap(sheetText('Milieu'));
    await settle(tester);

    expect(sheetEntry('Moi'), findsOneWidget);
    expect(sheetEntry('Alpha'), findsNothing);
  });

  testWidgets('sépare les adversaires faciles et difficiles', (tester) async {
    await _open(tester, _page());

    await tester.tap(find.text('Choisir mon champion'));
    await settle(tester);
    await tester.tap(sheetEntry('Moi'));
    await settle(tester);

    expect(find.text('FORT CONTRE'), findsOneWidget);
    expect(find.text('DIFFICILE CONTRE'), findsOneWidget);

    final weakTitle = tester.getTopLeft(find.text('DIFFICILE CONTRE')).dy;
    final tiles = find.byType(CounterTile);

    // Fort contre : du meilleur au moins bon, le peu fiable à la fin. Charlie
    // (30 %) y figure aussi, faute de mieux, puis seul sous « DIFFICILE ».
    expect(_opponentNames(tester), [
      'Alpha',
      'Bravo',
      'Charlie',
      'Delta',
      'Charlie',
    ]);
    expect(tester.getTopLeft(tiles.first).dy, lessThan(weakTitle));
    expect(tester.getTopLeft(tiles.last).dy, greaterThan(weakTitle));
    expect(find.text('70 %'), findsOneWidget);
    expect(find.text('30 %'), findsNWidgets(2));
  });

  testWidgets('le filtre de voie restreint les deux sections', (tester) async {
    await _open(tester, _page(initialChampionId: 'Moi'));

    await tester.tap(find.text('Top'));
    await settle(tester);

    expect(_opponentNames(tester), containsAll(['Charlie', 'Delta']));
    expect(_opponentNames(tester), isNot(contains('Alpha')));

    await tester.tap(find.text('Mid'));
    await settle(tester);

    expect(_opponentNames(tester), ['Alpha', 'Bravo']);
    // Aucune faiblesse au milieu : la section disparaît.
    expect(find.text('DIFFICILE CONTRE'), findsNothing);
  });

  testWidgets('signale les bilans peu fiables', (tester) async {
    await _open(tester, _page(initialChampionId: 'Moi'));

    expect(find.textContaining('peu de données'), findsWidgets);
    expect(
      find.textContaining('Peu de parties Master+ avec Moi'),
      findsOneWidget,
    );
  });

  testWidgets('affiche la provenance des données', (tester) async {
    await _open(tester, _page(initialChampionId: 'Moi'));

    expect(find.byType(DataSourceNote), findsOneWidget);
    expect(find.text(DataSourceNote.textFor(_data)), findsOneWidget);
  });

  testWidgets('dit quand les matchups sont indisponibles', (tester) async {
    await _open(
      tester,
      _page(
        initialChampionId: 'Moi',
        loadDataset: () async => const MatchupDataset.empty(),
      ),
    );

    expect(
      find.text('Les matchups ne sont pas disponibles pour le moment.'),
      findsOneWidget,
    );
  });

  testWidgets('dit quand le champion n a aucune partie analysée', (
    tester,
  ) async {
    await _open(tester, _page(initialChampionId: 'Alpha'));

    expect(
      find.textContaining('Aucune partie Master+ analysée'),
      findsOneWidget,
    );
    expect(find.byType(CounterTile), findsNothing);
  });
}
