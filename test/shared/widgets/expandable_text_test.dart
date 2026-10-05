import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/shared/widgets/expandable_text/expandable_text.dart';

Widget _host(String text) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: 200,
          child: ExpandableText(
            text: text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('un texte court s affiche sans lien', (tester) async {
    await tester.pumpWidget(_host('Un texte court.'));

    expect(find.text('Un texte court.'), findsOneWidget);
    expect(find.text('Lire la suite'), findsNothing);
  });

  testWidgets('un long texte est replié puis se déplie à la demande', (
    tester,
  ) async {
    final longText = List.filled(60, 'beaucoup de mots').join(' ');

    await tester.pumpWidget(_host(longText));
    expect(find.text('Lire la suite'), findsOneWidget);

    await tester.tap(find.text('Lire la suite'));
    await tester.pumpAndSettle();

    expect(find.text('Réduire'), findsOneWidget);
    expect(find.text('Lire la suite'), findsNothing);

    // Une fois déplié, le lien est sous le bas de l'écran de test.
    await tester.ensureVisible(find.text('Réduire'));
    await tester.tap(find.text('Réduire'));
    await tester.pumpAndSettle();

    expect(find.text('Lire la suite'), findsOneWidget);
  });
}
