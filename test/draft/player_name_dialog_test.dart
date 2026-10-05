import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/draft/widgets/player_name_dialog/player_name_dialog.dart';

Widget _host(void Function(String?) onResult) {
  return MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () async {
            final name = await PlayerNameDialog.show(
              context,
              currentName: 'Joueur 1',
              otherName: 'Tom',
            );
            onResult(name);
          },
          child: const Text('Ouvrir'),
        ),
      ),
    ),
  );
}

void main() {
  group('validatePlayerName', () {
    test('refuse un nom vide ou fait d espaces', () {
      expect(validatePlayerName('', otherName: 'Tom'), isNotNull);
      expect(validatePlayerName('   ', otherName: 'Tom'), isNotNull);
    });

    test('refuse le nom de l autre joueur, sans tenir compte de la casse', () {
      expect(validatePlayerName('tom', otherName: 'Tom'), isNotNull);
      expect(validatePlayerName(' TOM ', otherName: 'Tom'), isNotNull);
    });

    test('accepte un nom distinct', () {
      expect(validatePlayerName('Léa', otherName: 'Tom'), isNull);
    });
  });

  testWidgets('renvoie le nom saisi, sans espaces autour', (tester) async {
    String? result;
    await tester.pumpWidget(_host((name) => result = name));

    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  Léa ');
    await tester.tap(find.text('Valider'));
    await tester.pumpAndSettle();

    expect(result, 'Léa');
  });

  testWidgets('garde la boîte ouverte et explique un nom déjà pris', (
    tester,
  ) async {
    String? result = 'inchangé';
    await tester.pumpWidget(_host((name) => result = name));

    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Tom');
    await tester.tap(find.text('Valider'));
    await tester.pumpAndSettle();

    expect(
      find.text('Ce nom est déjà pris par l’autre joueur.'),
      findsOneWidget,
    );
    expect(result, 'inchangé');
  });

  testWidgets('annuler ne renvoie aucun nom', (tester) async {
    String? result = 'inchangé';
    await tester.pumpWidget(_host((name) => result = name));

    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });
}
