import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/item.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const ItemCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item.imageUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const _MissingIcon(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Le nom prend la place qui reste au lieu de la réclamer : sur un
            // écran étroit, un nom sur deux lignes faisait déborder la carte.
            Expanded(
              child: Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.instrumentSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.circle, size: 8, color: AppColors.accent),
                const SizedBox(width: 5),
                Text(
                  '${item.gold}',
                  style: AppTheme.mono(size: 11, color: AppColors.accent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Remplace l'icône quand Riot ne la sert pas : sans ça, `Image.network`
/// affiche son propre bloc d'erreur et casse la grille.
class _MissingIcon extends StatelessWidget {
  const _MissingIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      color: AppColors.background,
      child: const Icon(
        Icons.hide_image_outlined,
        size: 20,
        color: AppColors.textMuted,
      ),
    );
  }
}
