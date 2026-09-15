import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../champions/widgets/champion_card/champion_card_favorite_badge.dart';

class ChampionHeroBanner extends StatelessWidget {
  final String championId;
  final String name;
  final String title;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const ChampionHeroBanner({
    super.key,
    required this.championId,
    required this.name,
    required this.title,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final splashUrl =
        'https://ddragon.leagueoflegends.com/cdn/img/champion/splash/${championId}_0.jpg';
    final screenWidth = MediaQuery.of(context).size.width;
    final bannerHeight = screenWidth / (1215 / 717);

    return SliverAppBar(
      expandedHeight: bannerHeight,
      pinned: true,
      backgroundColor: AppColors.background,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(splashUrl, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.background.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
            ChampionCardFavoriteBadge(
              isFavorite: isFavorite,
              onTap: onToggleFavorite,
            ),
            Positioned(
              left: 16,
              bottom: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTheme.serif(size: 30)),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: AppTheme.serif(
                      size: 14,
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
    );
  }
}
