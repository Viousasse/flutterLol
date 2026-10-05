import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/quiz/widgets/quiz_answer_button/quiz_answer_button.dart';
import 'package:monapp/quiz/widgets/quiz_timer_bar/quiz_timer_bar.dart';

Widget _host(int secondsLeft) {
  return MaterialApp(
    home: Scaffold(
      body: QuizTimerBar(secondsLeft: secondsLeft, totalSeconds: 15),
    ),
  );
}

Color _barColor(WidgetTester tester) {
  final indicator = tester.widget<LinearProgressIndicator>(
    find.byType(LinearProgressIndicator),
  );

  return indicator.color!;
}

void main() {
  testWidgets('affiche les secondes restantes', (tester) async {
    await tester.pumpWidget(_host(12));
    await tester.pumpAndSettle();

    expect(find.text('12 s'), findsOneWidget);
  });

  testWidgets('la barre vire au rouge sur les dernières secondes', (
    tester,
  ) async {
    await tester.pumpWidget(_host(10));
    await tester.pumpAndSettle();
    expect(_barColor(tester), isNot(quizWrongColor));

    await tester.pumpWidget(_host(QuizTimerBar.urgentSeconds));
    await tester.pumpAndSettle();
    expect(_barColor(tester), quizWrongColor);
  });
}
