import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../services/combat_stats_calculator.dart';

/// Curseur du niveau auquel les deux champions sont comparés.
class CompareLevelSlider extends StatelessWidget {
  final int level;
  final ValueChanged<int> onChanged;

  const CompareLevelSlider({
    super.key,
    required this.level,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const min = CombatStatsCalculator.minLevel;
    const max = CombatStatsCalculator.maxLevel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('NIVEAU', style: AppTheme.mono(size: 9)),
            Text('$level', style: AppTheme.serif(size: 20)),
          ],
        ),
        Slider(
          value: level.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          label: 'Niveau $level',
          activeColor: AppColors.accent,
          inactiveColor: AppColors.textPrimary.withValues(alpha: 0.12),
          semanticFormatterCallback: (value) => 'Niveau ${value.round()}',
          onChanged: (value) => onChanged(value.round()),
        ),
      ],
    );
  }
}
