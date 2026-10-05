import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/draft/draft_history_page.dart';
import 'package:monapp/draft/models/draft_record.dart';
import 'package:monapp/draft/models/draft_report.dart';
import 'package:monapp/draft/services/draft_history_store.dart';
import 'package:monapp/draft/services/draft_share_code.dart';
import 'package:monapp/team/constants/team_roles.dart';
import 'package:shared_preferences/shared_preferences.dart';

DraftRecord _record() {
  final blue = [for (var i = 0; i < teamRoles.length; i++) 'B$i'];
  final red = [for (var i = 0; i < teamRoles.length; i++) 'R$i'];

  return DraftRecord(
    id: 'a',
    playedAt: DateTime(2026, 10, 5, 15, 42),
    versusFriend: false,
    blueName: 'Vous',
    redName: 'Le site',
    blue: blue,
    red: red,
    blueBans: const [],
    redBans: const [],
    championNames: {
      for (final id in [...blue, ...red]) id: id,
    },
    winner: DraftWinner.blue,
    blueScore: 3,
    redScore: 2,
    verdict: '',
  );
}

/// Pas de `pumpAndSettle` : les vignettes affichent un effet de chargement qui
/// boucle tant que l'image n'est pas arrivée.
Future<void> _settle(WidgetTester tester) async {
  for (var frame = 0; frame < 10; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _importCode(WidgetTester tester, String text) async {
  await tester.tap(find.byTooltip('Importer une draft'));
  await _settle(tester);
  await tester.enterText(find.byType(TextField), text);
  await tester.tap(find.text('Importer'));
  await _settle(tester);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    DraftHistoryStore.reset();
  });

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(home: DraftHistoryPage(loadChampions: () async => [])),
    );
    await _settle(tester);
  }

  testWidgets('importe une draft collée, une seule fois', (tester) async {
    await open(tester);
    final code = DraftShareCode.encode(_record());

    await _importCode(tester, 'Ma draft\nCode : $code');
    expect(find.text('Draft importée'), findsOneWidget);
    expect(DraftHistoryStore.records.value, hasLength(1));
    expect(DraftHistoryStore.records.value.single.imported, isTrue);
    expect(find.text('IMPORTÉE'), findsOneWidget);

    await _importCode(tester, code);
    expect(
      find.text('Cette draft est déjà dans votre historique.'),
      findsOneWidget,
    );
    expect(DraftHistoryStore.records.value, hasLength(1));
  });

  testWidgets('un texte sans code garde la boîte ouverte', (tester) async {
    await open(tester);

    await _importCode(tester, 'bonjour');

    expect(
      find.text('Ce texte ne contient pas de code de draft valide.'),
      findsOneWidget,
    );
    expect(DraftHistoryStore.records.value, isEmpty);
  });
}
