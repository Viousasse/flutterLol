import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../services/quiz_score_service.dart';

/// Les dernières séries terminées, de la plus récente à la plus ancienne.
class QuizHistory extends StatelessWidget {
  const QuizHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<int>>(
      valueListenable: QuizScoreService.recentStreaks,
      builder: (context, streaks, _) {
        if (streaks.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            'DERNIÈRES SÉRIES  ${streaks.join(' · ')}',
            style: AppTheme.mono(size: 9, color: AppColors.textMuted),
          ),
        );
      },
    );
  }
}
