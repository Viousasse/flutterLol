import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class ChampionCardFavoriteBadge extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const ChampionCardFavoriteBadge({
    super.key,
    required this.isFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 6,
      right: 6,
      // Une icône seule n'a pas de nom : sans cette étiquette, un lecteur
      // d'écran annonce « bouton » sans dire ce qu'il fait ni son état.
      child: Semantics(
        button: true,
        label: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
        excludeSemantics: true,
        onTap: onTap,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              size: 16,
              color: isFavorite ? AppColors.accent : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
