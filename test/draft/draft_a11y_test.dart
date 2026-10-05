import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/draft/models/draft_report.dart';
import 'package:monapp/draft/widgets/draft_report_view/draft_report_view.dart';
import 'package:monapp/theme/widgets/theme_mode_sheet/theme_mode_sheet.dart';

void main() {
  testWidgets('les titres du bilan sont annoncés comme des titres', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    const report = DraftReport(
      blueScore: 60,
      redScore: 40,
      winner: DraftWinner.blue,
      verdict: 'Une draft solide.',
      criteria: [],
      strengths: ['Bonne synergie'],
      improvements: ['Peu de dégâts magiques'],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: DraftReportView(report: report)),
        ),
      ),
    );

    for (final title in [
      'VERDICT',
      'POURQUOI',
      'CE QUI VA BIEN',
      'À AMÉLIORER',
    ]) {
      expect(
        tester.getSemantics(find.text(title)),
        isSemantics(isHeader: true),
        reason: title,
      );
    }
    handle.dispose();
  });

  testWidgets('la feuille d affichage a un titre annoncé', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ThemeModeSheet())),
    );

    expect(
      tester.getSemantics(find.text('Affichage')),
      isSemantics(isHeader: true),
    );
    handle.dispose();
  });
}
