import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/draft/models/draft_mode.dart';
import 'package:monapp/draft/models/draft_report.dart';
import 'package:monapp/draft/widgets/draft_report_view/draft_report_view.dart';

DraftReport _report({DraftPlayers? players}) {
  return DraftReport(
    criteria: const [
      DraftCriterion(
        title: 'Contrôle',
        winner: DraftWinner.red,
        blueText: '1 sort',
        redText: '4 sorts',
        explanation: 'Explication.',
      ),
    ],
    blueScore: 2,
    redScore: 3,
    winner: DraftWinner.red,
    verdict: 'Verdict détaillé.',
    strengths: const ['Force du bleu.'],
    improvements: const ['Conseil du bleu.'],
    players: players,
    redStrengths: players == null ? const [] : const ['Force du rouge.'],
    redImprovements: players == null ? const [] : const ['Conseil du rouge.'],
  );
}

Widget _view(DraftReport report) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(child: DraftReportView(report: report)),
    ),
  );
}

void main() {
  testWidgets('contre le site, le bilan parle au joueur', (tester) async {
    await tester.pumpWidget(_view(_report()));

    expect(find.text('La draft du site l’emporte'), findsOneWidget);
    expect(find.text('VOUS'), findsOneWidget);
    expect(find.text('SITE'), findsOneWidget);
    expect(find.text('Conseil du bleu.'), findsOneWidget);
    expect(find.text('Conseil du rouge.'), findsNothing);
  });

  testWidgets('à deux, le bilan nomme les joueurs et conseille chacun', (
    tester,
  ) async {
    await tester.pumpWidget(_view(_report(players: friendPlayers)));

    expect(find.text('La draft de Joueur 2 l’emporte'), findsOneWidget);
    expect(find.text('Avantage à Joueur 2'), findsOneWidget);
    expect(find.text('JOUEUR 1'), findsOneWidget);
    expect(find.text('JOUEUR 2'), findsOneWidget);
    expect(find.text('VOUS'), findsNothing);
    expect(find.text('SITE'), findsNothing);

    expect(find.text('Conseil du bleu.'), findsOneWidget);
    expect(find.text('Conseil du rouge.'), findsOneWidget);
    expect(find.text('À AMÉLIORER · JOUEUR 1'), findsOneWidget);
    expect(find.text('À AMÉLIORER · JOUEUR 2'), findsOneWidget);
  });
}
