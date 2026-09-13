import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../champions/models/champion.dart';
import '../models/daily_quiz_question.dart';

class QuizService {
  static const _answerKeyPrefix = 'daily_quiz_answer_';

  /// Le quiz est le même pour tout le monde toute la journée : la question
  /// et l'ordre des options sont dérivés du quantième du jour, sans aléa.
  ///
  /// Le décalage évite de tomber sur le même champion que la carte "Champion
  /// du jour" de l'accueil, qui utilise directement le quantième du jour.
  static DailyQuizQuestion buildTodayQuestion(List<Champion> champions) {
    final dayOfYear = _dayOfYear();
    final random = Random(dayOfYear);

    final answerIndex = (dayOfYear * 37 + 11) % champions.length;
    final answer = champions[answerIndex];

    final distractorPool = List<Champion>.from(champions)
      ..removeAt(answerIndex)
      ..shuffle(random);

    final options = [answer, ...distractorPool.take(3)]..shuffle(random);

    return DailyQuizQuestion(answer: answer, options: options);
  }

  static Future<String?> loadTodayAnswerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_todayKey());
  }

  static Future<void> saveTodayAnswerId(String championId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_todayKey(), championId);
  }

  static String _todayKey() {
    final now = DateTime.now();
    return '$_answerKeyPrefix${now.year}-${now.month}-${now.day}';
  }

  static int _dayOfYear() {
    final now = DateTime.now();
    return now.difference(DateTime(now.year, 1, 1)).inDays;
  }
}
