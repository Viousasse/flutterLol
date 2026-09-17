import 'package:flutter/material.dart';

import '../../../shared/widgets/remote_image/remote_image.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../models/quiz_question.dart';
import '../quiz_answer_button/quiz_answer_button.dart';

/// La carte d'une question : sa famille, son illustration, son énoncé, ses
/// quatre propositions, et après réponse, la correction.
class QuizQuestionCard extends StatelessWidget {
  final QuizQuestion question;

  /// Index choisi, ou `null` tant qu'on n'a pas répondu.
  final int? chosenIndex;

  final ValueChanged<int> onAnswer;
  final VoidCallback onNext;

  const QuizQuestionCard({
    super.key,
    required this.question,
    required this.chosenIndex,
    required this.onAnswer,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final chosen = chosenIndex;
    final answered = chosen != null;
    final imageUrl = question.imageUrl;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            quizCategoryLabels[question.category]!.toUpperCase(),
            style: AppTheme.mono(size: 9, color: AppColors.accent),
          ),
          const SizedBox(height: 12),
          if (imageUrl != null) ...[
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: RemoteImage(url: imageUrl, width: 96, height: 96),
              ),
            ),
            const SizedBox(height: 14),
          ],
          Text(
            question.prompt,
            style: AppTheme.serif(size: 16).copyWith(height: 1.45),
          ),
          const SizedBox(height: 14),
          ...question.options.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: QuizAnswerButton(
                option: entry.value,
                state: _stateOf(entry.key, chosen),
                onTap: () => onAnswer(entry.key),
              ),
            );
          }),
          if (answered) _Verdict(question: question, chosenIndex: chosen),
          if (answered) ...[
            const SizedBox(height: 12),
            _NextButton(onTap: onNext),
          ],
        ],
      ),
    );
  }

  QuizAnswerState _stateOf(int index, int? chosen) {
    if (chosen == null) return QuizAnswerState.open;
    if (index == question.answerIndex) return QuizAnswerState.correct;
    if (index == chosen) return QuizAnswerState.wrong;

    return QuizAnswerState.dimmed;
  }
}

class _Verdict extends StatelessWidget {
  final QuizQuestion question;
  final int chosenIndex;

  const _Verdict({required this.question, required this.chosenIndex});

  @override
  Widget build(BuildContext context) {
    final right = chosenIndex == question.answerIndex;
    final explanation = question.explanation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 2),
        Text(
          right ? 'Bonne réponse.' : 'Raté : ${question.answer.label}.',
          style: AppTheme.mono(
            size: 10.5,
            color: right ? quizCorrectColor : quizWrongColor,
          ),
        ),
        if (explanation != null) ...[
          const SizedBox(height: 5),
          Text(
            explanation,
            style: AppTheme.mono(size: 9, color: AppColors.textMuted),
          ),
        ],
      ],
    );
  }
}

class _NextButton extends StatelessWidget {
  final VoidCallback onTap;

  const _NextButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.accentSoft,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.accent),
        ),
        child: Text(
          'Question suivante',
          style: const TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}
