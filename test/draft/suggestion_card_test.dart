import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/draft/widgets/suggestion_card/suggestion_card.dart';

import 'draft_support.dart';

Widget _host(VoidCallback onTap) {
  return MaterialApp(
    home: Scaffold(
      body: SuggestionCard(
        champion: champion('Ahri'),
        role: 'Milieu',
        reasons: const ['Bat Zed au milieu.', 'Gagne 54 %.'],
        onTap: onTap,
      ),
    ),
  );
}

void main() {
  testWidgets('affiche le nom, le rôle et chaque raison', (tester) async {
    await tester.pumpWidget(_host(() {}));

    expect(find.text('Ahri'), findsOneWidget);
    expect(find.text('MILIEU'), findsOneWidget);
    expect(find.text('Bat Zed au milieu.'), findsOneWidget);
    expect(find.text('Gagne 54 %.'), findsOneWidget);
  });

  testWidgets('le toucher appelle onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_host(() => taps++));

    await tester.tap(find.text('Ahri'));

    expect(taps, 1);
  });

  testWidgets('le libellé sémantique résume le conseil', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(() {}));

    expect(
      find.bySemanticsLabel(
        'Conseil : Ahri au rôle Milieu. Bat Zed au milieu. Gagne 54 %. '
        'Appuyer pour le choisir.',
      ),
      findsOneWidget,
    );
    handle.dispose();
  });
}
