import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../models/stat_comparison.dart';

/// Une caractéristique : valeurs de part et d'autre, barres qui se font face.
/// La plus forte valeur est teintée, et le gagnant est aussi dit en toutes
/// lettres pour ne pas reposer sur la seule couleur.
class StatCompareRow extends StatelessWidget {
  final StatComparison stat;

  const StatCompareRow({super.key, required this.stat});

  String _format(double value) => value.toStringAsFixed(stat.decimals);

  @override
  Widget build(BuildContext context) {
    final winner = stat.winner;
    final summary = switch (winner) {
      ComparisonWinner.left => 'avantage au champion de gauche',
      ComparisonWinner.right => 'avantage au champion de droite',
      ComparisonWinner.tie => 'égalité',
    };

    return Semantics(
      label:
          '${stat.label} : ${_format(stat.left)} contre ${_format(stat.right)}, '
          '$summary',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Column(
          children: [
            Text(
              stat.label.toUpperCase(),
              style: AppTheme.mono(size: 9, color: AppColors.textMuted),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                SizedBox(
                  width: 52,
                  child: Text(
                    _format(stat.left),
                    style: AppTheme.serif(
                      size: 15,
                      color: winner == ComparisonWinner.left
                          ? AppColors.accent
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: _Bar(
                    fraction: stat.leftFraction,
                    highlighted: winner == ComparisonWinner.left,
                    alignRight: true,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _Bar(
                    fraction: stat.rightFraction,
                    highlighted: winner == ComparisonWinner.right,
                    alignRight: false,
                  ),
                ),
                SizedBox(
                  width: 52,
                  child: Text(
                    _format(stat.right),
                    textAlign: TextAlign.end,
                    style: AppTheme.serif(
                      size: 15,
                      color: winner == ComparisonWinner.right
                          ? AppColors.accent
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double fraction;
  final bool highlighted;
  final bool alignRight;

  const _Bar({
    required this.fraction,
    required this.highlighted,
    required this.alignRight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: fraction.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: highlighted
                ? AppColors.accent
                : AppColors.textPrimary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
