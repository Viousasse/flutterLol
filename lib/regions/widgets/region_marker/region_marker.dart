import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../models/lore_region.dart';

/// Pastille d'une région sur la carte : son nom et son nombre de champions.
class RegionMarker extends StatelessWidget {
  final LoreRegion region;
  final int championCount;
  final bool selected;
  final VoidCallback onTap;

  const RegionMarker({
    super.key,
    required this.region,
    required this.championCount,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? region.color.withValues(alpha: 0.30)
              : AppColors.background.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected
                ? region.color
                : region.color.withValues(alpha: 0.45),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              region.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.mono(
                size: 8.5,
                letterSpacing: 0.2,
                color: selected ? region.color : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              '$championCount',
              style: AppTheme.mono(
                size: 10,
                letterSpacing: 0,
                color: region.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
