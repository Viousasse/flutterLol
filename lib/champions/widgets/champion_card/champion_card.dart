import 'package:flutter/material.dart';

import '../../../theme/app_fonts.dart';
import '../../../shared/widgets/remote_image/remote_image.dart';
import '../../models/champion.dart';
import '../../services/favorites_service.dart';
import '../../../champion_detail/champion_detail_page.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import 'champion_card_favorite_badge.dart';

class ChampionCard extends StatelessWidget {
  final Champion champion;

  const ChampionCard({super.key, required this.champion});

  @override
  Widget build(BuildContext context) {
    final role = champion.tags.isNotEmpty ? champion.tags.first : '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChampionDetailPage(championId: champion.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            RemoteImage(url: champion.imageUrl),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.45, 1.0],
                  colors: [
                    Colors.transparent,
                    AppColors.background.withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
            // Seul le badge se reconstruit quand les favoris changent, et il
            // lit l'état partagé : le mettre en favori depuis la fiche du
            // champion met cette carte à jour toute seule.
            ValueListenableBuilder<Set<String>>(
              valueListenable: FavoritesService.favorites,
              builder: (context, favorites, _) => ChampionCardFavoriteBadge(
                isFavorite: favorites.contains(champion.id),
                onTap: () => FavoritesService.toggleFavorite(champion.id),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    champion.name,
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    champion.title,
                    style: AppTheme.serif(
                      size: 11.5,
                      italic: true,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (role.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentSoft,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        role,
                        style: AppTheme.mono(
                          size: 9,
                          color: AppColors.accent,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
