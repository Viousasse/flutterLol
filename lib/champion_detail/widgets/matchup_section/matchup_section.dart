import 'package:flutter/material.dart';

import '../../../champions/models/champion.dart';
import '../../../matchups/models/matchup.dart';
import '../../../matchups/services/matchup_service.dart';
import '../../../shared/widgets/remote_image/remote_image.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../champion_detail_page.dart';

const _laneLabels = {
  'TOP': 'Top',
  'JUNGLE': 'Jungle',
  'MIDDLE': 'Mid',
  'BOTTOM': 'Bot',
  'UTILITY': 'Support',
};

/// Adversaires difficiles et favorables d'un champion, comptés sur de vraies
/// parties classées. Chaque ligne affiche le nombre de parties : c'est ce qui
/// dit ce que vaut le pourcentage.
class MatchupSection extends StatelessWidget {
  final String championId;
  final MatchupDataset dataset;
  final List<Champion> champions;

  const MatchupSection({
    super.key,
    required this.championId,
    required this.dataset,
    required this.champions,
  });

  static const _shown = 4;

  @override
  Widget build(BuildContext context) {
    if (dataset.isEmpty) {
      return _Notice(
        "Pas encore de données : lance tool/generate_matchups.dart avec une "
        "clé API Riot pour les calculer.",
      );
    }

    final hardest = MatchupService.hardestFor(
      championId,
      dataset,
    ).where((m) => m.winRate < 0.5).take(_shown).toList();
    final easiest = MatchupService.easiestFor(
      championId,
      dataset,
    ).where((m) => m.winRate > 0.5).take(_shown).toList();

    if (hardest.isEmpty && easiest.isEmpty) {
      return _Notice(
        "Pas assez de parties Master+ avec ce champion pour tirer une "
        "tendance (moins de ${MatchupService.minGames} par adversaire).",
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hardest.isNotEmpty) ...[
          _Heading('Difficile contre', color: AppColors.accent),
          const SizedBox(height: 8),
          ...hardest.map(_row),
        ],
        if (hardest.isNotEmpty && easiest.isNotEmpty)
          const SizedBox(height: 14),
        if (easiest.isNotEmpty) ...[
          const _Heading('Favorable contre', color: Color(0xFF6FBF73)),
          const SizedBox(height: 8),
          ...easiest.map(_row),
        ],
        const SizedBox(height: 10),
        Text(
          'Parties classées Master+ du patch ${dataset.patch ?? '?'}, '
          '${dataset.matches} parties analysées. Une paire jouée moins de '
          '${MatchupService.minGames} fois n\'est pas affichée.',
          style: AppTheme.mono(size: 8.5, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _row(Matchup matchup) {
    final opponent = champions.cast<Champion?>().firstWhere(
      (c) => c!.id == matchup.opponentId,
      orElse: () => null,
    );

    return _MatchupRow(matchup: matchup, opponent: opponent);
  }
}

class _MatchupRow extends StatelessWidget {
  final Matchup matchup;
  final Champion? opponent;

  const _MatchupRow({required this.matchup, required this.opponent});

  @override
  Widget build(BuildContext context) {
    final rate = (matchup.winRate * 100).round();
    final favorable = matchup.winRate > 0.5;
    final target = opponent;

    return GestureDetector(
      onTap: target == null
          ? null
          : () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChampionDetailPage(championId: target.id),
              ),
            ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: target == null
                  ? Container(width: 36, height: 36, color: AppColors.surface)
                  : RemoteImage(url: target.imageUrl, width: 36, height: 36),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    target?.name ?? matchup.opponentId,
                    style: const TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${_laneLabels[matchup.lane] ?? matchup.lane} · '
                    '${matchup.games} parties',
                    style: AppTheme.mono(size: 8.5, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Text(
              '$rate %',
              style: AppTheme.mono(
                size: 12,
                letterSpacing: 0,
                color: favorable ? const Color(0xFF6FBF73) : AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String label;
  final Color color;

  const _Heading(this.label, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTheme.mono(size: 9, color: color),
    );
  }
}

class _Notice extends StatelessWidget {
  final String message;

  const _Notice(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        style: AppTheme.mono(size: 9.5, color: AppColors.textMuted),
      ),
    );
  }
}
