import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/shared/widgets/error_retry_view/error_retry_view.dart';

void main() {
  testWidgets('affiche le message et relance au clic sur Réessayer', (
    tester,
  ) async {
    var retries = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorRetryView(
            message: 'Pas de connexion internet.',
            onRetry: () => retries++,
          ),
        ),
      ),
    );

    expect(find.text('Pas de connexion internet.'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);

    await tester.tap(find.text('Réessayer'));

    expect(retries, 1);
  });
}
