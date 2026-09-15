import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../favorites/favorites_page.dart';
import '../../../theme/app_colors.dart';

class FavoritesShortcut extends StatelessWidget {
  const FavoritesShortcut({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FavoritesPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mes champions favoris',
              style: GoogleFonts.instrumentSans(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
                color: AppColors.textPrimary,
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
