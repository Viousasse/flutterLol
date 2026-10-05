import 'package:flutter/material.dart';

import '../../../champions/models/champion.dart';
import '../../../shared/widgets/remote_image/remote_image.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../models/counter_pick.dart';

const _winningColor = Color(0xFF6FBF73);

/// Une proposition de contre-pick : le champion, son taux de victoire face à
/// l'adversaire et le nombre de parties qui le fondent.
class CounterTile extends StatelessWidget {
  final CounterPick pick;
  final Champion champion;
  final int rank;
  final VoidCallback onTap;

  const CounterTile({
    super.key,
    required this.pick,
    required this.champion,
    required this.rank,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (pick.winRate * 100).round();
    final isWinning = pick.winRate > 0.5;

    return Semantics(
      button: true,
      label:
          '${champion.name}, $percent % de victoires sur ${pick.games} parties',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '$rank',
                  style: AppTheme.mono(size: 11, color: AppColors.textMuted),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: RemoteImage(
                  url: champion.imageUrl,
                  width: 44,
                  height: 44,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(champion.name, style: AppTheme.serif(size: 16)),
                    Text(
                      '${pick.games} parties',
                      style: AppTheme.mono(
                        size: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$percent %',
                style: AppTheme.serif(
                  size: 18,
                  color: isWinning ? _winningColor : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
