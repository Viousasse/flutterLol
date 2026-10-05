import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class AppFilterChip extends StatelessWidget {
  /// Zone tactile minimale recommandée (RGAA, 44 px).
  static const double minTapHeight = 44;

  /// Hauteur visible de la puce quand la zone tactile est agrandie : l'aspect
  /// reste celui des puces de 32 px posées jusque-là.
  static const double visibleHeight = 32;

  final String label;
  final bool selected;
  final VoidCallback onTap;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Si l'appelant offre une hauteur imposée d'au moins 44 px, la zone
            // tactile prend toute cette hauteur et seule la pastille reste de
            // 32 px. Sinon la puce garde sa taille d'origine, pour ne pas
            // casser les mises en page qui imposent une hauteur plus basse.
            final roomy =
                constraints.hasTightHeight &&
                constraints.maxHeight >= minTapHeight;
            final pill = _pill();

            if (!roomy) {
              return pill;
            }

            return Center(
              widthFactor: 1,
              child: SizedBox(height: visibleHeight, child: pill),
            );
          },
        ),
      ),
    );
  }

  Widget _pill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: selected ? AppColors.accentSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? AppColors.accent : AppColors.border,
        ),
      ),
      // Une Row `min` plutôt qu'un `alignment` : avec un alignment, le
      // Container s'étire sur toute la largeur offerte dès qu'il n'est pas
      // dans une liste horizontale, et la puce occupait alors une ligne
      // entière dans un Wrap.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: selected ? AppColors.accent : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
