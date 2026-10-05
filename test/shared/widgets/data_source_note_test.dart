import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/matchups/models/matchup.dart';
import 'package:monapp/shared/widgets/data_source_note/data_source_note.dart';

MatchupDataset _dataset({String? patch, int matches = 7600}) =>
    MatchupDataset(patch: patch, matches: matches, matchups: const []);

Future<void> _pump(WidgetTester tester, MatchupDataset dataset) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: DataSourceNote(dataset: dataset)),
    ),
  );
}

void main() {
  testWidgets('affiche une plage de patchs et les milliers', (tester) async {
    await _pump(tester, _dataset(patch: '16.16–16.19'));

    expect(
      find.text(
        'Données : 7 600 parties classées Master+ (EUW), '
        'patchs 16.16–16.19.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('reste au singulier pour un seul patch', (tester) async {
    await _pump(tester, _dataset(patch: '16.19', matches: 420));

    expect(
      find.text('Données : 420 parties classées Master+ (EUW), patch 16.19.'),
      findsOneWidget,
    );
  });

  testWidgets('sépare les millions comme les milliers', (tester) async {
    expect(
      DataSourceNote.textFor(_dataset(patch: '16.1', matches: 1234567)),
      contains('1 234 567'),
    );
  });

  testWidgets('dit qu il n y a pas de données quand le jeu est vide', (
    tester,
  ) async {
    await _pump(tester, const MatchupDataset.empty());
    expect(find.text(DataSourceNote.emptyText), findsOneWidget);

    expect(
      DataSourceNote.textFor(_dataset(patch: null)),
      DataSourceNote.emptyText,
    );
    expect(
      DataSourceNote.textFor(_dataset(patch: '16.19', matches: 0)),
      DataSourceNote.emptyText,
    );
  });

  testWidgets('expose le texte entier à l accessibilité', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, _dataset(patch: '16.19', matches: 420));

    expect(
      find.bySemanticsLabel(
        'Données : 420 parties classées Master+ (EUW), patch 16.19.',
      ),
      findsOneWidget,
    );
    handle.dispose();
  });
}
