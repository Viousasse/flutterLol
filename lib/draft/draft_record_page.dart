import 'package:flutter/material.dart';

import '../champions/models/champion.dart';
import '../shared/services/clipboard_copy/clipboard_copy.dart';
import '../team/constants/team_roles.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'draft_page.dart';
import 'models/draft_record.dart';
import 'services/draft_share_text.dart';
import 'widgets/ban_row/ban_row.dart';
import 'widgets/draft_history_tile/draft_history_tile.dart';
import 'widgets/draft_slot/draft_slot.dart';

/// Une draft de l'historique en détail : les deux équipes, les bannissements,
/// le verdict, de quoi la copier et la rejouer.
class DraftRecordPage extends StatelessWidget {
  final DraftRecord record;

  /// Icône de chaque champion, par identifiant. Un champion absent (retiré du
  /// jeu depuis) s'affiche sans image.
  final Map<String, String> imageUrls;

  const DraftRecordPage({
    super.key,
    required this.record,
    this.imageUrls = const {},
  });

  /// Les cases de [DraftSlot] et [BanRow] attendent des champions : on en
  /// reconstruit un à partir de ce que la draft a gardé. Un identifiant vide
  /// (rôle ou ban non rempli) reste une case vide.
  Champion? _champion(String id) {
    if (id.isEmpty) return null;

    return Champion(
      id: id,
      name: record.nameOf(id),
      title: '',
      blurb: '',
      imageUrl: imageUrls[id] ?? '',
      tags: const [],
    );
  }

  String _score(double score) {
    return score == score.roundToDouble()
        ? '${score.round()}'
        : score.toStringAsFixed(1).replaceAll('.', ',');
  }

  Widget _team(String owner, List<String> picks, List<String> bans) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            owner.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.mono(size: 10, color: AppColors.accent),
          ),
          const SizedBox(height: 8),
          BanRow(owner: owner, bans: [for (final id in bans) _champion(id)]),
          for (var index = 0; index < teamRoles.length; index++)
            DraftSlot(
              role: teamRoles[index],
              champion: _champion(picks[index]),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détail de la draft', style: AppTheme.serif(size: 24)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${record.blueName} contre ${record.redName}',
              style: AppTheme.serif(size: 22),
            ),
            const SizedBox(height: 4),
            Text(
              '${draftOutcomeLabel(record)} · '
              '${formatDraftDate(record.playedAt)}',
              style: AppTheme.mono(size: 10, color: AppColors.accent),
            ),
            const SizedBox(height: 4),
            Text(
              'Score : ${_score(record.blueScore)} contre '
              '${_score(record.redScore)}'
              '${record.assisted ? ' · jouée avec aide' : ''}',
              style: AppTheme.serif(size: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _team(record.blueName, record.blue, record.blueBans),
                const SizedBox(width: 12),
                _team(record.redName, record.red, record.redBans),
              ],
            ),
            if (record.verdict.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                record.verdict,
                style: AppTheme.serif(size: 15, color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => copyToClipboard(
                    context,
                    DraftShareText.of(record),
                    message: 'Résumé de la draft copié',
                  ),
                  icon: const Icon(Icons.copy_outlined, size: 18),
                  label: const Text('Copier le résumé'),
                ),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => DraftPage(replayOf: record),
                    ),
                  ),
                  icon: const Icon(Icons.replay, size: 18),
                  label: const Text('Rejouer avec les mêmes bannissements'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
