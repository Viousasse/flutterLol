import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/quiz/models/quiz_question.dart';
import 'package:monapp/quiz/widgets/quiz_category_bar/quiz_category_bar.dart';

/// Monte la barre à la largeur d'un téléphone : toutes les puces doivent être
/// visibles d'un coup, sans défilement ni débordement.
Future<void> _pumpBar(WidgetTester tester, {required double width}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: width,
          child: QuizCategoryBar(selected: null, onSelect: (_) {}),
        ),
      ),
    ),
  );
}

void main() {
  for (final width in [360.0, 375.0]) {
    testWidgets('les cinq puces tiennent à ${width.toInt()} px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await _pumpBar(tester, width: width);

      for (final label in [
        'Tout',
        ...QuizCategory.values.map((c) => quizCategoryLabels[c]!),
      ]) {
        final chip = find.text(label);
        expect(chip, findsOneWidget, reason: label);

        // Hors écran ou à cheval sur le bord, la puce serait rognée.
        final box = tester.getRect(chip);
        expect(box.left, greaterThanOrEqualTo(0), reason: label);
        expect(box.right, lessThanOrEqualTo(width), reason: label);
      }

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('une puce garde la largeur de son texte', (tester) async {
    await _pumpBar(tester, width: 375);

    final court = tester.getRect(find.text('Tout')).width;
    final long = tester.getRect(find.text('Matchups')).width;

    expect(court, lessThan(long));
  });
}
