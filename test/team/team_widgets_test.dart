import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/team/models/team_insight.dart';
import 'package:monapp/team/widgets/damage_split_bar/damage_split_bar.dart';
import 'package:monapp/team/widgets/insight_tile/insight_tile.dart';

Widget _host(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)),
  );
}

void main() {
  testWidgets('la barre de dégâts écrit les pourcentages', (tester) async {
    await tester.pumpWidget(
      _host(const DamageSplitBar(physicalShare: 0.7, magicShare: 0.3)),
    );

    expect(find.text('Physiques 70 %'), findsOneWidget);
    expect(find.text('Magiques 30 %'), findsOneWidget);
  });

  testWidgets('une équipe 100 % physique ne casse pas la barre', (tester) async {
    await tester.pumpWidget(
      _host(const DamageSplitBar(physicalShare: 1, magicShare: 0)),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Magiques 0 %'), findsOneWidget);
  });

  testWidgets('sans dégâts, la barre reste affichable', (tester) async {
    await tester.pumpWidget(
      _host(const DamageSplitBar(physicalShare: 0, magicShare: 0)),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('un constat montre son titre, son message et une icône', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const InsightTile(
          insight: TeamInsight(
            kind: InsightKind.warning,
            title: 'Pas de première ligne',
            message: 'Aucun tank.',
          ),
        ),
      ),
    );

    expect(find.text('Pas de première ligne'), findsOneWidget);
    expect(find.text('Aucun tank.'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });
}
