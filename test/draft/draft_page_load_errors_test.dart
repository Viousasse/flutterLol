import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/champions/models/champion.dart';
import 'package:monapp/draft/draft_page.dart';
import 'package:monapp/draft/models/draft_mode.dart';
import 'package:monapp/draft/services/draft_history_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../counters/counter_pages_support.dart';
import 'draft_support.dart';

final _champions = [
  for (final id in ['A', 'B', 'C']) fakeChampion(id),
];
final _data = dataset([duel('A', 'B', lane: 'MIDDLE', games: 80, wins: 55)]);

void main() {
  testWidgets('le second chargeur échoue avant le premier : Réessayer, puis '
      'la draft', (tester) async {
    useTallScreen(tester);
    SharedPreferences.setMockInitialValues({});
    DraftHistoryStore.reset();
    final firstChampions = Completer<List<Champion>>();
    var championAttempts = 0;
    var datasetAttempts = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: DraftPage(
          mode: DraftMode.vsSite,
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
          loadDetail: (id) async => member(id).detail,
          botThinkingDelay: Duration.zero,
        ),
      ),
    );
    await settle(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    firstChampions.complete(_champions);
    await settle(tester);

    expect(find.text('Chargement impossible pour le moment.'), findsOneWidget);

    await tester.tap(find.text('Réessayer'));
    await settle(tester);

    expect(find.text('Chargement impossible pour le moment.'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
