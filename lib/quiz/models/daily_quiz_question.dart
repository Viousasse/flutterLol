import '../../champions/models/champion.dart';

/// Une question du quiz quotidien : deviner [answer] parmi [options].
class DailyQuizQuestion {
  final Champion answer;
  final List<Champion> options;

  const DailyQuizQuestion({required this.answer, required this.options});
}
