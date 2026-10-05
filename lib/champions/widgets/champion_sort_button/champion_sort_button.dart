import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../models/champion_sort.dart';

/// Bouton qui fait défiler les tris à chaque appui, comme celui des objets.
class ChampionSortButton extends StatelessWidget {
  final ChampionSort current;
  final ValueChanged<ChampionSort> onChanged;

  const ChampionSortButton({
    super.key,
    required this.current,
    required this.onChanged,
  });

  String get _label {
    switch (current) {
      case ChampionSort.name:
        return 'A-Z';
      case ChampionSort.difficultyAsc:
        return 'Plus facile';
      case ChampionSort.difficultyDesc:
        return 'Plus dur';
      case ChampionSort.winRate:
        return 'Victoires';
    }
  }

  IconData get _icon {
    switch (current) {
      case ChampionSort.name:
        return Icons.sort_by_alpha;
      case ChampionSort.difficultyAsc:
        return Icons.arrow_upward;
      case ChampionSort.difficultyDesc:
        return Icons.arrow_downward;
      case ChampionSort.winRate:
        return Icons.emoji_events_outlined;
    }
  }

  ChampionSort get _next {
    final values = ChampionSort.values;

    return values[(current.index + 1) % values.length];
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Trier les champions, tri actuel : $_label',
      excludeSemantics: true,
      onTap: () => onChanged(_next),
      child: GestureDetector(
        onTap: () => onChanged(_next),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_icon, size: 14, color: AppColors.accent),
              const SizedBox(width: 5),
              Text(
                _label,
                style: AppTheme.mono(size: 11, color: AppColors.accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
