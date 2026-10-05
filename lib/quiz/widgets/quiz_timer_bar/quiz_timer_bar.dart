import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../quiz_answer_button/quiz_answer_button.dart';

/// Temps restant pour répondre, en barre et en secondes. La barre vire au rouge
/// sur les cinq dernières secondes, et le nombre reste lisible sans la couleur.
class QuizTimerBar extends StatelessWidget {
  static const urgentSeconds = 5;

  final int secondsLeft;
  final int totalSeconds;

  const QuizTimerBar({
    super.key,
    required this.secondsLeft,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final isUrgent = secondsLeft <= urgentSeconds;
    final color = isUrgent ? quizWrongColor : AppColors.accent;

    return Semantics(
      label: '$secondsLeft secondes restantes',
      excludeSemantics: true,
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: secondsLeft / totalSeconds),
                duration: const Duration(milliseconds: 900),
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  color: color,
                  backgroundColor: AppColors.textPrimary.withValues(
                    alpha: 0.06,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 30,
            child: Text(
              '$secondsLeft s',
              textAlign: TextAlign.end,
              style: AppTheme.mono(size: 11, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
