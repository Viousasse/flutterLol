import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../models/draft_report.dart';
import '../criterion_tile/criterion_tile.dart';

/// Le bilan d'une draft terminée : le verdict, la comparaison point par point,
/// ce qui est bien et ce qu'il faut améliorer.
class DraftReportView extends StatelessWidget {
  final DraftReport report;

  const DraftReportView({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Verdict(report: report),
        const SizedBox(height: 22),
        Text('POURQUOI', style: AppTheme.mono(size: 9)),
        const SizedBox(height: 8),
        for (final criterion in report.criteria)
          CriterionTile(criterion: criterion, players: report.players),
        const SizedBox(height: 12),
        _Advice(
          owner: report.players?.blue,
          strengths: report.strengths,
          improvements: report.improvements,
        ),
        if (report.players case final players?) ...[
          const SizedBox(height: 16),
          _Advice(
            owner: players.red,
            strengths: report.redStrengths,
            improvements: report.redImprovements,
          ),
        ],
      ],
    );
  }
}

/// Les points forts et les conseils d'un camp. En duel, [owner] donne le nom du
/// joueur concerné ; contre le site, il n'y a qu'un seul bloc, sans titre.
class _Advice extends StatelessWidget {
  final String? owner;
  final List<String> strengths;
  final List<String> improvements;

  const _Advice({
    required this.owner,
    required this.strengths,
    required this.improvements,
  });

  @override
  Widget build(BuildContext context) {
    final suffix = owner == null ? '' : ' · ${owner!.toUpperCase()}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (strengths.isNotEmpty) ...[
          Text('CE QUI VA BIEN$suffix', style: AppTheme.mono(size: 9)),
          const SizedBox(height: 8),
          for (final strength in strengths) _Bullet(text: strength),
          const SizedBox(height: 12),
        ],
        Text('À AMÉLIORER$suffix', style: AppTheme.mono(size: 9)),
        const SizedBox(height: 8),
        for (final improvement in improvements) _Bullet(text: improvement),
      ],
    );
  }
}

class _Verdict extends StatelessWidget {
  final DraftReport report;

  const _Verdict({required this.report});

  @override
  Widget build(BuildContext context) {
    final players = report.players;
    final title = switch (report.winner) {
      DraftWinner.blue when players != null =>
        'La draft de ${players.blue} l’emporte',
      DraftWinner.red when players != null =>
        'La draft de ${players.red} l’emporte',
      DraftWinner.blue => 'Votre draft l’emporte',
      DraftWinner.red => 'La draft du site l’emporte',
      DraftWinner.tie => 'Drafts équivalentes',
    };

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
          Text(
            'VERDICT',
            style: AppTheme.mono(size: 9, color: AppColors.accent),
          ),
          const SizedBox(height: 6),
          Text(title, style: AppTheme.serif(size: 22)),
          const SizedBox(height: 6),
          Text(
            report.verdict,
            style: AppTheme.serif(size: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;

  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 10),
            child: Icon(Icons.circle, size: 6, color: AppColors.accent),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTheme.serif(size: 14, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
