import 'package:flutter/material.dart';

import '../../../champions/models/champion.dart';
import '../../../matchups/models/matchup.dart';
import '../../../matchups/services/matchup_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

/// Ce que disent les parties classées Master+ de ce duel précis, et du niveau
/// de chacun des deux champions en général.
class HeadToHeadCard extends StatelessWidget {
  final Champion left;
  final Champion right;
  final MatchupDataset dataset;

  const HeadToHeadCard({
    super.key,
    required this.left,
    required this.right,
    required this.dataset,
  });

  @override
  Widget build(BuildContext context) {
    final duel = MatchupService.headToHead(left.id, right.id, dataset);
    final leftRecord = MatchupService.overallFor(left.id, dataset);
    final rightRecord = MatchupService.overallFor(right.id, dataset);

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
          Text('EN DUEL', style: AppTheme.mono(size: 9)),
          const SizedBox(height: 8),
          Text(_duelSentence(duel), style: AppTheme.serif(size: 15)),
          const SizedBox(height: 14),
          Text('TAUX DE VICTOIRE GLOBAL', style: AppTheme.mono(size: 9)),
          const SizedBox(height: 8),
          _OverallLine(champion: left, record: leftRecord),
          const SizedBox(height: 4),
          _OverallLine(champion: right, record: rightRecord),
        ],
      ),
    );
  }

  String _duelSentence(Matchup? duel) {
    if (duel == null) {
      return 'Pas assez de parties Master+ entre ${left.name} et ${right.name} '
          'pour en tirer une tendance.';
    }

    final percent = (duel.winRate * 100).round();
    final verdict = percent == 50
        ? 'Le duel est à égalité'
        : percent > 50
        ? '${left.name} l\'emporte'
        : '${right.name} l\'emporte';

    return '$verdict : ${left.name} gagne $percent % de ses ${duel.games} '
        'parties face à ${right.name}.';
  }
}

class _OverallLine extends StatelessWidget {
  final Champion champion;
  final OverallRecord record;

  const _OverallLine({required this.champion, required this.record});

  @override
  Widget build(BuildContext context) {
    final value = record.isReliable
        ? '${(record.winRate * 100).toStringAsFixed(1)} % (${record.games} parties)'
        : 'données insuffisantes';

    return Text(
      '${champion.name} : $value',
      style: AppTheme.serif(size: 13, color: AppColors.textSecondary),
    );
  }
}
