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

/// Une draft de l'historique : qui jouait, qui l'a emporté, les dix champions,
/// et de quoi la partager ou la supprimer.
class DraftHistoryTile extends StatelessWidget {
  final DraftRecord record;

  /// Icône de chaque champion, par identifiant. Un champion absent de la liste
  /// (retiré du jeu depuis) s'affiche sans image.
  final Map<String, String> imageUrls;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const DraftHistoryTile({
    super.key,
    required this.record,
    required this.imageUrls,
    required this.onShare,
    required this.onDelete,
  });

  String get _outcome {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${record.blueName} contre ${record.redName}',
                  style: AppTheme.serif(size: 16),
                ),
                const SizedBox(height: 3),
                Text(
                  '$_outcome · ${formatDraftDate(record.playedAt)}',
                  style: AppTheme.mono(size: 10, color: AppColors.accent),
                ),
                const SizedBox(height: 10),
                _Picks(
                  record: record,
                  picks: record.blue,
                  imageUrls: imageUrls,
                ),
                const SizedBox(height: 6),
                _Picks(record: record, picks: record.red, imageUrls: imageUrls),
              ],
            ),
          ),
          Column(
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
