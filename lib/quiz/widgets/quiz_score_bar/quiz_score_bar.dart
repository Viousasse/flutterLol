import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../services/quiz_score_service.dart';

/// Série en cours, bonnes réponses de la session, et record conservé.
class QuizScoreBar extends StatelessWidget {
  final int streak;
  final int correct;
  final int answered;

  const QuizScoreBar({
    super.key,
    required this.streak,
    required this.correct,
    required this.answered,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Stat(label: 'Série', value: '$streak'),
          _Stat(label: 'Session', value: '$correct / $answered'),
          ValueListenableBuilder<int>(
            valueListenable: QuizScoreService.bestStreak,
            builder: (context, best, _) =>
                _Stat(label: 'Record', value: '$best'),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTheme.mono(size: 8, color: AppColors.textMuted),
        ),
        const SizedBox(height: 3),
        Text(value, style: AppTheme.serif(size: 17)),
      ],
    );
  }
}
