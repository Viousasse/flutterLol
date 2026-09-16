import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../models/lore_region.dart';

/// Pastille d'une région sur la carte : son nom et son nombre de champions.
///
/// Volontairement compacte : une douzaine de pastilles se partagent une carte
/// de 335 px de large sur téléphone.
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: selected
              ? region.color.withValues(alpha: 0.32)
              : AppColors.background.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? region.color
                : region.color.withValues(alpha: 0.55),
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
                size: 7.5,
                letterSpacing: 0.1,
                color: selected ? region.color : AppColors.textPrimary,
              ),
            ),
            Text(
              '$championCount',
              style: AppTheme.mono(
                size: 9.5,
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
