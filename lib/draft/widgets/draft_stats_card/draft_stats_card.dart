import 'package:flutter/material.dart';

import '../../../shared/widgets/remote_image/remote_image.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../services/draft_history_stats.dart';

/// Le haut de l'historique : le nombre de drafts, le bilan contre le site et
/// les champions qu'on choisit le plus.
class DraftStatsCard extends StatelessWidget {
  final DraftHistoryStats stats;
  final Map<String, String> imageUrls;

  const DraftStatsCard({
    super.key,
    required this.stats,
    required this.imageUrls,
  });

  String _plural(int count, String noun) =>
      '$count $noun${count > 1 ? 's' : ''}';

  String get _record {
    final rate = stats.winRate;
    if (rate == null) return 'Aucune draft contre le site';

    return '${_plural(stats.wins, 'victoire')}, '
        '${_plural(stats.ties, 'égalité')}, '
        '${_plural(stats.losses, 'défaite')} contre le site '
        '(${(rate * 100).round()} %)';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('BILAN', style: AppTheme.mono(size: 9, color: AppColors.accent)),
          const SizedBox(height: 6),
          Text(
            '${_plural(stats.total, 'draft')} '
            'jouée${stats.total > 1 ? 's' : ''}',
            style: AppTheme.serif(size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            _record,
            style: AppTheme.serif(size: 14, color: AppColors.textSecondary),
          ),
          if (stats.assistedCount > 0) ...[
            const SizedBox(height: 4),
            Text(
              'dont ${stats.assistedCount} avec aide '
              '(non comptées dans le taux)',
              style: AppTheme.serif(size: 13, color: AppColors.textMuted),
            ),
          ],
          if (stats.importedCount > 0) ...[
            const SizedBox(height: 4),
            Text(
              'dont ${stats.importedCount} '
              '${stats.importedCount > 1 ? 'importées' : 'importée'} '
              '(non comptées dans le taux)',
              style: AppTheme.serif(size: 13, color: AppColors.textMuted),
            ),
          ],
          if (stats.mostPicked.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text('LES PLUS CHOISIS', style: AppTheme.mono(size: 9)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                for (final pick in stats.mostPicked)
                  _PickBadge(pick: pick, imageUrl: imageUrls[pick.championId]),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PickBadge extends StatelessWidget {
  final PickCount pick;
  final String? imageUrl;

  const _PickBadge({required this.pick, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${pick.name}, choisi ${pick.count} fois',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 28,
              height: 28,
              child: imageUrl == null
                  ? ColoredBox(color: AppColors.border)
                  : RemoteImage(url: imageUrl!, width: 28, height: 28),
            ),
          ),
          const SizedBox(width: 6),
          Text('${pick.name} ×${pick.count}', style: AppTheme.serif(size: 13)),
        ],
      ),
    );
  }
}
