import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../models/draft_report.dart';

const _goodColor = Color(0xFF3F9E5A);
const _badColor = Color(0xFFD08A1E);

/// Un critère de la comparaison : ce que fait chaque camp, qui l'emporte et
/// pourquoi. Le vainqueur est dit en toutes lettres, pas seulement par la
/// couleur.
class CriterionTile extends StatelessWidget {
  final DraftCriterion criterion;
  final DraftPlayers? players;

  const CriterionTile({super.key, required this.criterion, this.players});

  @override
  Widget build(BuildContext context) {
    final duel = players;
    final (icon, color, label) = switch (criterion.winner) {
      // En duel, aucun camp n'est « le mauvais » : les deux avantages ont la
      // même couleur.
      DraftWinner.blue when duel != null => (
        Icons.check_circle_outline,
        _goodColor,
        'Avantage à ${duel.blue}',
      ),
      DraftWinner.red when duel != null => (
        Icons.check_circle_outline,
        _goodColor,
        'Avantage à ${duel.red}',
      ),
      DraftWinner.blue => (
        Icons.check_circle_outline,
        _goodColor,
        'Avantage à vous',
      ),
      DraftWinner.red => (
        Icons.warning_amber_rounded,
        _badColor,
        'Avantage au site',
      ),
      DraftWinner.tie => (Icons.drag_handle, AppColors.textMuted, 'Égalité'),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(criterion.title, style: AppTheme.serif(size: 16)),
              ),
              Text(label, style: AppTheme.mono(size: 10, color: color)),
            ],
          ),
          const SizedBox(height: 10),
          _SideLine(side: duel?.blue ?? 'VOUS', text: criterion.blueText),
          const SizedBox(height: 4),
          _SideLine(side: duel?.red ?? 'SITE', text: criterion.redText),
          const SizedBox(height: 10),
          Text(
            criterion.explanation,
            style: AppTheme.serif(size: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SideLine extends StatelessWidget {
  final String side;
  final String text;

  const _SideLine({required this.side, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 78,
          child: Text(
            side.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.mono(size: 9, color: AppColors.textMuted),
          ),
        ),
        Expanded(child: Text(text, style: AppTheme.serif(size: 14))),
      ],
    );
  }
}
