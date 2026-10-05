import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/shared/widgets/paste_code_dialog/paste_code_dialog.dart';

const _invalid = 'Code illisible.';

Future<void> _open(WidgetTester tester, void Function(int?) onResult) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async => onResult(
            await PasteCodeDialog.show<int>(
              context,
              title: 'Titre',
              hint: 'Collez',
              parse: int.tryParse,
              invalidMessage: _invalid,
            ),
          ),
          child: const Text('ouvrir'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('ouvrir'));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renvoie le résultat de parse et se ferme', (tester) async {
    int? result;
    await _open(tester, (value) => result = value);

    await tester.enterText(find.byType(TextField), '42');
    await tester.tap(find.text('Importer'));
    await tester.pumpAndSettle();

    expect(result, 42);
    expect(find.text('Importer'), findsNothing);
  });

  testWidgets('reste ouverte et explique quand le texte est illisible', (
    tester,
  ) async {
    int? result = -1;
    await _open(tester, (value) => result = value);

    await tester.enterText(find.byType(TextField), 'abc');
    await tester.tap(find.text('Importer'));
    await tester.pumpAndSettle();

    expect(find.text(_invalid), findsOneWidget);
    expect(result, -1);

    await tester.enterText(find.byType(TextField), '7');
    await tester.pump();
    expect(find.text(_invalid), findsNothing);
  });

  testWidgets('Annuler renvoie null', (tester) async {
    int? result = -1;
    await _open(tester, (value) => result = value);

    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });

  testWidgets('Coller lit le presse-papiers', (tester) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async =>
          call.method == 'Clipboard.getData' ? {'text': '99'} : null,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await _open(tester, (_) {});

    await tester.tap(find.text('Coller'));
    await tester.pumpAndSettle();

    expect(find.text('99'), findsOneWidget);
  });
}
