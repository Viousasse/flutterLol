import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/champions/models/champion.dart';
import 'package:monapp/counters/counters_page.dart';

import '../draft/draft_support.dart';
import 'counter_pages_support.dart';

final _champions = [fakeChampion('Cible'), fakeChampion('Alpha')];
final _data = dataset([
  duel('Alpha', 'Cible', lane: 'MIDDLE', games: 80, wins: 55),
]);

void main() {
  testWidgets('le second chargeur échoue avant le premier : Réessayer, puis '
      'les données', (tester) async {
    useTallScreen(tester);
    final firstChampions = Completer<List<Champion>>();
    var championAttempts = 0;
    var datasetAttempts = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: CountersPage(
          loadChampions: () {
            championAttempts++;
            if (championAttempts == 1) return firstChampions.future;

            return Future.value(_champions);
          },
          loadDataset: () async {
            datasetAttempts++;
            if (datasetAttempts == 1) throw Exception('matchups hors ligne');

            return _data;
          },
        ),
      ),
    );
    // Le second chargeur a déjà échoué ; le premier n'est pas fini.
    await settle(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    firstChampions.complete(_champions);
    await settle(tester);

    expect(find.text('Chargement impossible pour le moment.'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);

    await tester.tap(find.text('Réessayer'));
    await settle(tester);

    expect(find.text('Chargement impossible pour le moment.'), findsNothing);
    expect(find.text('Choisir un champion'), findsOneWidget);
  });
}
