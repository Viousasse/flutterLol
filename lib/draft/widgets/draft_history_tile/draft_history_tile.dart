import 'package:flutter/material.dart';

import '../../../shared/widgets/remote_image/remote_image.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../models/draft_record.dart';
import '../../models/draft_report.dart';

const _months = [
  'janv.',
  'févr.',
  'mars',
  'avr.',
  'mai',
  'juin',
  'juil.',
  'août',
  'sept.',
  'oct.',
  'nov.',
  'déc.',
];

/// « 5 oct. 2026, 15 h 42 » : la date d'une draft, lisible d'un coup d'œil.
String formatDraftDate(DateTime date) {
  final minutes = date.minute.toString().padLeft(2, '0');

  return '${date.day} ${_months[date.month - 1]} ${date.year}, '
      '${date.hour} h $minutes';
}

/// Qui l'emporte, dit du point de vue du joueur quand il joue contre le site.
String draftOutcomeLabel(DraftRecord record) {
  // Contre le site, « Victoire de Vous » se lirait mal : on parle au joueur.
  if (!record.versusFriend) {
    return switch (record.winner) {
      DraftWinner.blue => 'Vous l’emportez',
      DraftWinner.red => 'Le site l’emporte',
      DraftWinner.tie => 'Égalité',
    };
  }

  return switch (record.winner) {
    DraftWinner.blue => 'Victoire de ${record.blueName}',
    DraftWinner.red => 'Victoire de ${record.redName}',
    DraftWinner.tie => 'Égalité',
  };
}

/// Une draft de l'historique : qui jouait, qui l'a emporté, les dix champions,
/// et de quoi la partager ou la supprimer.
class DraftHistoryTile extends StatelessWidget {
  final DraftRecord record;

  /// Icône de chaque champion, par identifiant. Un champion absent de la liste
  /// (retiré du jeu depuis) s'affiche sans image.
  final Map<String, String> imageUrls;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  /// Ouvre le détail de la draft. Sans lui, la tuile n'est pas touchable.
  final VoidCallback? onTap;

  const DraftHistoryTile({
    super.key,
    required this.record,
    required this.imageUrls,
    required this.onShare,
    required this.onDelete,
    this.onTap,
  });

  String get _semanticLabel =>
      '${record.blueName} contre ${record.redName}, ${draftOutcomeLabel(record)}, '
      '${formatDraftDate(record.playedAt)}'
      '${record.assisted ? ', jouée avec aide' : ''}'
      '${record.imported ? ', importée' : ''}';

  @override
  Widget build(BuildContext context) {
    // Un Material (et non un Container décoré) pour que l'effet de toucher de
    // l'InkWell se dessine au-dessus du fond.
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Semantics(
              button: onTap != null,
              label: _semanticLabel,
              excludeSemantics: true,
              onTap: onTap,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 0, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${record.blueName} contre ${record.redName}',
                        style: AppTheme.serif(size: 16),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${draftOutcomeLabel(record)} · '
                        '${formatDraftDate(record.playedAt)}',
                        style: AppTheme.mono(size: 10, color: AppColors.accent),
                      ),
                      if (record.assisted || record.imported) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (final label in [
                              if (record.assisted) 'AVEC AIDE',
                              if (record.imported) 'IMPORTÉE',
                            ])
                              Text(
                                label,
                                style: AppTheme.mono(
                                  size: 9,
                                  color: AppColors.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                      _Picks(
                        record: record,
                        picks: record.blue,
                        imageUrls: imageUrls,
                      ),
                      const SizedBox(height: 6),
                      _Picks(
                        record: record,
                        picks: record.red,
                        imageUrls: imageUrls,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 4, 12),
            child: Column(
              children: [
                IconButton(
                  tooltip: 'Copier le résumé de cette draft',
                  onPressed: onShare,
                  icon: Icon(
                    Icons.share_outlined,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                ),
                IconButton(
                  tooltip: 'Supprimer cette draft',
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: AppColors.textMuted,
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

class _Picks extends StatelessWidget {
  final DraftRecord record;
  final List<String> picks;
  final Map<String, String> imageUrls;

  const _Picks({
    required this.record,
    required this.picks,
    required this.imageUrls,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: [
        for (final id in picks)
          Tooltip(
            message: id.isEmpty ? 'Rôle vide' : record.nameOf(id),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: SizedBox(
                width: 34,
                height: 34,
                child: imageUrls[id] == null
                    ? ColoredBox(color: AppColors.border)
                    : RemoteImage(url: imageUrls[id]!, width: 34, height: 34),
              ),
            ),
          ),
      ],
    );
  }
}
