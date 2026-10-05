import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../services/build_stats.dart';

/// Prix total et bonus cumulés d'une build.
class BuildStatsPanel extends StatelessWidget {
  final int totalGold;
  final List<StatLine> lines;

  const BuildStatsPanel({
    super.key,
    required this.totalGold,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('COÛT TOTAL', style: AppTheme.mono(size: 9)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.circle, size: 10, color: AppColors.accent),
              const SizedBox(width: 7),
              Text('$totalGold or', style: AppTheme.serif(size: 22)),
            ],
          ),
          const SizedBox(height: 16),
          Text('BONUS CUMULÉS', style: AppTheme.mono(size: 9)),
          const SizedBox(height: 8),
          if (lines.isEmpty)
            Text(
              'Ajoutez des objets pour voir leurs bonus.',
              style: AppTheme.serif(size: 13, color: AppColors.textMuted),
            )
          else
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      line.label,
                      style: AppTheme.serif(
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      line.value,
                      style: AppTheme.mono(size: 12, color: AppColors.accent),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
