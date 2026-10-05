import 'package:flutter/material.dart';

import '../../../items/models/item.dart';
import '../../../shared/widgets/remote_image/remote_image.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../models/build.dart';
import '../../services/build_stats.dart';

/// Une build de la liste : son nom, son champion, ses objets et son prix.
class BuildTile extends StatelessWidget {
  final Build savedBuild;

  /// Les objets de la build, dans l'ordre. Un objet disparu des données de
  /// Riot n'y figure simplement plus.
  final List<Item> items;
  final String? championName;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const BuildTile({
    super.key,
    required this.savedBuild,
    required this.items,
    required this.championName,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      ?championName,
      '${BuildStats.totalGold(items)} or',
    ].join(' · ');

    return Semantics(
      button: true,
      label: 'Build ${savedBuild.name}, $subtitle',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 12, 4, 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(savedBuild.name, style: AppTheme.serif(size: 17)),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppTheme.mono(size: 10, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        for (final item in items)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: RemoteImage(
                              url: item.imageUrl,
                              width: 34,
                              height: 34,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Supprimer la build ${savedBuild.name}',
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
