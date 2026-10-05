import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/map/map_page.dart';
import 'package:monapp/map/widgets/summoners_rift_map/summoners_rift_map.dart';
import 'package:monapp/shared/widgets/error_retry_view/error_retry_view.dart';

Future<void> _settle(WidgetTester tester) async {
  // Pas de pumpAndSettle : l'image réseau de la carte boucle en test.
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('échec puis succès : Réessayer relance le chargement', (
    tester,
  ) async {
    var calls = 0;
    Future<String> loadVersion() async {
      calls++;
      if (calls == 1) throw Exception('hors ligne');
      return '14.1.1';
    }

    await tester.pumpWidget(
      MaterialApp(home: MapPage(loadVersion: loadVersion)),
    );
    await _settle(tester);

    expect(find.byType(ErrorRetryView), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
    expect(find.byType(SummonersRiftMap), findsNothing);
    expect(calls, 1);

    await tester.tap(find.text('Réessayer'));
    await _settle(tester);

    expect(calls, 2);
    expect(find.byType(ErrorRetryView), findsNothing);
    expect(find.byType(SummonersRiftMap), findsOneWidget);
  });
}
