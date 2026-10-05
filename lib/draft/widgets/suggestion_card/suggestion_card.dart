import 'package:flutter/material.dart';

import '../../../champions/models/champion.dart';
import '../../../shared/widgets/remote_image/remote_image.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

/// Un champion conseillé pour un rôle, avec ses raisons. Le toucher le joue.
class SuggestionCard extends StatelessWidget {
  final Champion champion;

  /// Le nom du rôle visé, tel qu'il s'affiche dans la grille.
  final String role;
  final List<String> reasons;
  final VoidCallback onTap;

  const SuggestionCard({
    super.key,
    required this.champion,
    required this.role,
    required this.reasons,
    required this.onTap,
  });

  /// Une seule phrase pour les lecteurs d'écran : la carte est un bouton, ses
  /// lignes ne se parcourent pas une à une.
  String get _semanticLabel =>
      'Conseil : ${champion.name} au rôle $role. ${reasons.join(' ')} '
      'Appuyer pour le choisir.';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: _semanticLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.accent.withValues(alpha: 0.5)),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: RemoteImage(
                    url: champion.imageUrl,
                    width: 44,
                    height: 44,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(champion.name, style: AppTheme.serif(size: 16)),
                      Text(
                        role.toUpperCase(),
                        style: AppTheme.mono(size: 10, color: AppColors.accent),
                      ),
                      const SizedBox(height: 4),
                      for (final reason in reasons)
                        Text(
                          reason,
                          style: AppTheme.serif(
                            size: 13,
                            italic: true,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
