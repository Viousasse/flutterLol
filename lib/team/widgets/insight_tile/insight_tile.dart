import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../models/team_insight.dart';

const _goodColor = Color(0xFF6FBF73);
const _warningColor = Color(0xFFE0A53C);

/// Un constat sur l'équipe. L'icône et le titre disent s'il s'agit d'un point
/// fort ou d'un manque : la couleur seule ne porterait pas l'information.
class InsightTile extends StatelessWidget {
  final TeamInsight insight;

  const InsightTile({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (insight.kind) {
      InsightKind.good => (Icons.check_circle_outline, _goodColor),
      InsightKind.warning => (Icons.warning_amber_rounded, _warningColor),
      InsightKind.info => (Icons.info_outline, AppColors.textMuted),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(insight.title, style: AppTheme.serif(size: 15)),
                const SizedBox(height: 2),
                Text(
                  insight.message,
                  style: AppTheme.serif(
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
