import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/champions/models/champion.dart';
import 'package:monapp/counters/counters_page.dart';
import 'package:monapp/matchups/models/matchup.dart';
import 'package:monapp/shared/widgets/champion_picker_sheet/champion_picker_sheet.dart';
import 'package:monapp/shared/widgets/counter_tile/counter_tile.dart';
import 'package:monapp/shared/widgets/data_source_note/data_source_note.dart';

import '../draft/draft_support.dart';
import 'counter_pages_support.dart';

final _champions = [
  for (final id in ['Cible', 'Alpha', 'Bravo', 'Charlie', 'Delta'])
    fakeChampion(id),
];

/// Contre « Cible » : Alpha 69 % et Bravo 60 % au milieu, Charlie 56 % en
/// haut, Delta sur trois parties seulement (donc peu fiable).
final _data = dataset([
  duel('Alpha', 'Cible', lane: 'MIDDLE', games: 80, wins: 55),
  duel('Bravo', 'Cible', lane: 'MIDDLE', games: 100, wins: 60),
  duel('Charlie', 'Cible', lane: 'TOP', games: 50, wins: 28),
  duel('Delta', 'Cible', lane: 'TOP', games: 3, wins: 3),
]);

Widget _page({
  Future<List<Champion>> Function()? loadChampions,
  Future<MatchupDataset> Function()? loadDataset,
  String? initialOpponentId,
}) {
  return MaterialApp(
    home: CountersPage(
      initialOpponentId: initialOpponentId,
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

/// Les noms des champions proposés, dans l'ordre d'affichage.
List<String> _proposedNames(WidgetTester tester) {
  return [
    for (final tile in tester.widgetList<CounterTile>(find.byType(CounterTile)))
      tile.champion.name,
  ];
}

Future<void> _chooseOpponent(WidgetTester tester, String name) async {
  await tester.tap(find.text('Choisir un champion'));
  await settle(tester);
  await tester.tap(sheetEntry(name));
  await settle(tester);
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
    expect(find.text('Choisir un champion'), findsOneWidget);
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
    expect(find.text('Choisir un champion'), findsNothing);

    await tester.tap(find.text('Réessayer'));
    await settle(tester);

    expect(attempts, 2);
    expect(find.text('Chargement impossible pour le moment.'), findsNothing);
    expect(find.text('Choisir un champion'), findsOneWidget);
  });

  testWidgets('invite à choisir un adversaire tant qu il n y en a pas', (
    tester,
  ) async {
    await _open(tester, _page());

    expect(find.textContaining('Choisissez le champion'), findsOneWidget);
    expect(find.byType(CounterTile), findsNothing);
  });

  testWidgets('la feuille de choix a le filtre de rôle et exclut personne', (
    tester,
  ) async {
    await _open(tester, _page());

    await tester.tap(find.text('Choisir un champion'));
    await settle(tester);

    expect(find.byType(ChampionPickerSheet), findsOneWidget);
    for (final label in ['Tous', 'Top', 'Jungle', 'Milieu', 'Bot', 'Support']) {
      expect(sheetText(label), findsOneWidget, reason: label);
    }
    expect(sheetEntry('Cible'), findsOneWidget);
    expect(sheetEntry('Alpha'), findsOneWidget);

    // « Milieu » ne garde que les champions qui s'y jouent : Cible n'a aucune
    // partie à son nom, il disparaît.
    await tester.tap(sheetText('Milieu'));
    await settle(tester);

    expect(sheetEntry('Alpha'), findsOneWidget);
    expect(sheetEntry('Cible'), findsNothing);
    expect(sheetEntry('Charlie'), findsNothing);
  });

  testWidgets('liste les contre-picks du meilleur au moins bon', (
    tester,
  ) async {
    await _open(tester, _page());
    await _chooseOpponent(tester, 'Cible');

    expect(find.text('MEILLEURS CHOIX'), findsOneWidget);
    // Les bilans fiables d'abord (69, 60, 56 %), le peu fiable à la fin.
    expect(_proposedNames(tester), ['Alpha', 'Bravo', 'Charlie', 'Delta']);
    expect(find.text('69 %'), findsOneWidget);
    expect(
      find.text('Le pourcentage est celui du champion proposé face à Cible.'),
      findsOneWidget,
    );
  });

  testWidgets('ouvre directement l adversaire demandé par la fiche', (
    tester,
  ) async {
    await _open(tester, _page(initialOpponentId: 'Cible'));

    expect(_proposedNames(tester), ['Alpha', 'Bravo', 'Charlie', 'Delta']);
    expect(find.text('Cible'), findsOneWidget);
  });

  testWidgets('le filtre de voie restreint la liste', (tester) async {
    await _open(tester, _page(initialOpponentId: 'Cible'));

    expect(find.text('Toutes les voies'), findsOneWidget);

    await tester.tap(find.text('Top'));
    await settle(tester);

    expect(_proposedNames(tester), ['Charlie', 'Delta']);

    await tester.tap(find.text('Toutes les voies'));
    await settle(tester);

    expect(_proposedNames(tester), hasLength(4));
  });

  testWidgets('signale les bilans peu fiables', (tester) async {
    await _open(tester, _page(initialOpponentId: 'Cible'));

    expect(find.textContaining('peu de données'), findsWidgets);
    expect(
      find.textContaining('Peu de parties Master+ contre Cible'),
      findsOneWidget,
    );
  });

  testWidgets('pas de mention de prudence quand tous les bilans sont fiables', (
    tester,
  ) async {
    final reliable = dataset([
      for (final id in ['Alpha', 'Bravo', 'Charlie', 'Delta'])
        duel(id, 'Cible', lane: 'MIDDLE', games: 40, wins: 22),
    ]);
    // Moins de cinq bilans fiables : la liste est complétée, mais ici rien ne
    // manque, donc rien n'est peu fiable.
    await _open(
      tester,
      _page(initialOpponentId: 'Cible', loadDataset: () async => reliable),
    );

    expect(find.textContaining('Peu de parties Master+'), findsNothing);
  });

  testWidgets('affiche la provenance des données', (tester) async {
    await _open(tester, _page(initialOpponentId: 'Cible'));

    expect(find.byType(DataSourceNote), findsOneWidget);
    expect(find.text(DataSourceNote.textFor(_data)), findsOneWidget);
  });

  testWidgets('dit quand les matchups sont indisponibles', (tester) async {
    await _open(
      tester,
      _page(
        initialOpponentId: 'Cible',
        loadDataset: () async => const MatchupDataset.empty(),
      ),
    );

    expect(
      find.text('Les matchups ne sont pas disponibles pour le moment.'),
      findsOneWidget,
    );
    expect(find.byType(CounterTile), findsNothing);
  });

  testWidgets('dit quand aucun champion n a affronté l adversaire', (
    tester,
  ) async {
    await _open(tester, _page(initialOpponentId: 'Alpha'));

    expect(
      find.textContaining('Aucune partie Master+ analysée'),
      findsOneWidget,
    );
    expect(find.byType(CounterTile), findsNothing);
  });
}
