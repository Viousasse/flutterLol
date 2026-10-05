import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/draft/draft_page.dart';
import 'package:monapp/draft/draft_record_page.dart';
import 'package:monapp/draft/models/draft_record.dart';
import 'package:monapp/draft/models/draft_report.dart';

DraftRecord _record({bool assisted = false}) {
  final blue = ['Ahri', 'Garen', 'Lux', 'Jinx', 'Thresh'];
  final red = ['Zed', 'Fizz', 'Yone', 'Ashe', 'Nami'];

  return DraftRecord(
    id: 'a',
    playedAt: DateTime(2026, 10, 5, 9, 5),
    versusFriend: false,
    blueName: 'Vous',
    redName: 'Le site',
    blue: blue,
    red: red,
    blueBans: const ['Teemo'],
    redBans: const ['Yasuo'],
    championNames: {
      for (final id in [...blue, ...red, 'Teemo', 'Yasuo']) id: id,
    },
    winner: DraftWinner.blue,
    blueScore: 3.5,
    redScore: 2,
    verdict: 'Votre draft est plus solide.',
    assisted: assisted,
  );
}

Future<void> _open(WidgetTester tester, DraftRecord record) async {
  await tester.binding.setSurfaceSize(const Size(500, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(MaterialApp(home: DraftRecordPage(record: record)));
  await tester.pump();
}

void main() {
  testWidgets('montre l en-tête, les deux équipes et le verdict', (
    tester,
  ) async {
    await _open(tester, _record());

    expect(find.text('Vous contre Le site'), findsOneWidget);
    expect(find.textContaining('Vous l’emportez'), findsOneWidget);
    expect(find.text('Score : 3,5 contre 2'), findsOneWidget);
    expect(find.text('Ahri'), findsOneWidget);
    expect(find.text('Nami'), findsOneWidget);
    expect(find.text('Votre draft est plus solide.'), findsOneWidget);
  });

  testWidgets('signale une draft jouée avec aide', (tester) async {
    await _open(tester, _record(assisted: true));

    expect(find.textContaining('jouée avec aide'), findsOneWidget);
  });

  testWidgets('les cases sont en lecture seule', (tester) async {
    final handle = tester.ensureSemantics();
    await _open(tester, _record());

    expect(
      find.bySemanticsLabel('Bannissements de Vous : Teemo'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Top : Ahri'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('copie le résumé dans le presse-papiers', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }

        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await _open(tester, _record());

    await tester.tap(find.text('Copier le résumé'));
    await tester.pump();
    await tester.pump();

    expect(copied, contains('Vous contre Le site'));
    expect(find.text('Résumé de la draft copié'), findsOneWidget);
  });

  testWidgets('rejoue avec les mêmes bannissements', (tester) async {
    final record = _record();
    await _open(tester, record);

    await tester.tap(find.text('Rejouer avec les mêmes bannissements'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final page = tester.widget<DraftPage>(find.byType(DraftPage));
    expect(page.replayOf, same(record));
  });
}
