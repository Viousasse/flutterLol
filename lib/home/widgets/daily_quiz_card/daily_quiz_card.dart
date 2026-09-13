import 'package:flutter/material.dart';

import '../../../champions/models/champion.dart';
import '../../../quiz/models/daily_quiz_question.dart';
import '../../../quiz/services/quiz_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import 'quiz_option.dart';
import 'quiz_thumbnail.dart';

class DailyQuizCard extends StatefulWidget {
  final List<Champion> champions;

  const DailyQuizCard({super.key, required this.champions});

  @override
  State<DailyQuizCard> createState() => _DailyQuizCardState();
}

class _DailyQuizCardState extends State<DailyQuizCard> {
  late final DailyQuizQuestion question;
  String? selectedId;
  bool isLoadingSavedAnswer = true;

  @override
  void initState() {
    super.initState();
    question = QuizService.buildTodayQuestion(widget.champions);
    _loadSavedAnswer();
  }

  Future<void> _loadSavedAnswer() async {
    final saved = await QuizService.loadTodayAnswerId();
    if (!mounted) return;

    setState(() {
      selectedId = saved;
      isLoadingSavedAnswer = false;
    });
  }

  Future<void> _selectOption(Champion champion) async {
    if (selectedId != null) return;

    setState(() => selectedId = champion.id);
    await QuizService.saveTodayAnswerId(champion.id);
  }

  @override
  Widget build(BuildContext context) {
    final answered = selectedId != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              QuizThumbnail(champion: question.answer, revealed: answered),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QUIZ DU JOUR',
                      style: AppTheme.mono(size: 9, color: AppColors.accent),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quel champion se cache derrière cette icône ?',
                      style: AppTheme.serif(size: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isLoadingSavedAnswer)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else ...[
            _optionsRow(question.options.sublist(0, 2)),
            const SizedBox(height: 8),
            _optionsRow(question.options.sublist(2, 4)),
            if (answered) ...[
              const SizedBox(height: 12),
              Text(
                selectedId == question.answer.id
                    ? "Bien joué, c'était ${question.answer.name} !"
                    : "Raté, c'était ${question.answer.name}.",
                style: AppTheme.mono(
                  size: 10,
                  color: selectedId == question.answer.id
                      ? quizCorrectColor
                      : quizWrongColor,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _optionsRow(List<Champion> options) {
    return Row(
      children: [
        for (final champion in options) ...[
          Expanded(
            child: QuizOption(
              champion: champion,
              state: _stateFor(champion),
              onTap: () => _selectOption(champion),
            ),
          ),
          if (champion != options.last) const SizedBox(width: 8),
        ],
      ],
    );
  }

  QuizOptionState _stateFor(Champion champion) {
    if (selectedId == null) return QuizOptionState.idle;
    if (champion.id == question.answer.id) return QuizOptionState.correct;
    if (champion.id == selectedId) return QuizOptionState.wrong;
    return QuizOptionState.dimmed;
  }
}
