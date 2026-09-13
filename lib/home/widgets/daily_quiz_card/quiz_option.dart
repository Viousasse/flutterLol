import 'package:flutter/material.dart';

import '../../../champions/models/champion.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

const quizCorrectColor = Color(0xFF6FCF97);
const quizWrongColor = Color(0xFFEB5757);

enum QuizOptionState { idle, correct, wrong, dimmed }

class QuizOption extends StatelessWidget {
  final Champion champion;
  final QuizOptionState state;
  final VoidCallback onTap;

  const QuizOption({
    super.key,
    required this.champion,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    final Color textColor;

    switch (state) {
      case QuizOptionState.idle:
        borderColor = AppColors.border;
        textColor = AppColors.textPrimary;
      case QuizOptionState.correct:
        borderColor = quizCorrectColor;
        textColor = quizCorrectColor;
      case QuizOptionState.wrong:
        borderColor = quizWrongColor;
        textColor = quizWrongColor;
      case QuizOptionState.dimmed:
        borderColor = AppColors.border;
        textColor = AppColors.textMuted;
    }

    return GestureDetector(
      onTap: state == QuizOptionState.idle ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: borderColor),
        ),
        alignment: Alignment.center,
        child: Text(
          champion.name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.mono(size: 10.5, color: textColor),
        ),
      ),
    );
  }
}
