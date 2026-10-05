import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/quiz/services/quiz_score_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('retient les séries terminées, la plus récente en premier', () async {
    SharedPreferences.setMockInitialValues({
      'quiz_recent_streaks': ['4', '2'],
    });

    await QuizScoreService.ensureLoaded();
    expect(QuizScoreService.recentStreaks.value, [4, 2]);

    await QuizScoreService.recordFinished(7);
    expect(QuizScoreService.recentStreaks.value, [7, 4, 2]);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('quiz_recent_streaks'), ['7', '4', '2']);
  });

  test('une série de zéro n est pas retenue', () async {
    await QuizScoreService.ensureLoaded();
    final before = List<int>.from(QuizScoreService.recentStreaks.value);

    await QuizScoreService.recordFinished(0);

    expect(QuizScoreService.recentStreaks.value, before);
  });

  test('l historique est borné', () async {
    await QuizScoreService.ensureLoaded();

    for (var streak = 1; streak <= QuizScoreService.maxRecentStreaks + 4; streak++) {
      await QuizScoreService.recordFinished(streak);
    }

    expect(
      QuizScoreService.recentStreaks.value,
      hasLength(QuizScoreService.maxRecentStreaks),
    );
    expect(
      QuizScoreService.recentStreaks.value.first,
      QuizScoreService.maxRecentStreaks + 4,
    );
  });
}
