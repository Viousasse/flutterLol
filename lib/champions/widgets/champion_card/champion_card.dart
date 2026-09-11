import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/champion.dart';
import '../../services/favorites_service.dart';
import '../../../champion_detail/champion_detail_page.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import 'champion_card_favorite_badge.dart';

class ChampionCard extends StatefulWidget {
  final Champion champion;
  final VoidCallback? onFavoriteChanged;

  const ChampionCard({
    super.key,
    required this.champion,
    this.onFavoriteChanged,
  });

  @override
  State<ChampionCard> createState() => _ChampionCardState();
}

class _ChampionCardState extends State<ChampionCard> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    loadFavoriteStatus();
  }

  Future<void> loadFavoriteStatus() async {
    final favorite = await FavoritesService.isFavorite(widget.champion.id);
    setState(() {
      isFavorite = favorite;
    });
  }

  Future<void> toggleFavorite() async {
    await FavoritesService.toggleFavorite(widget.champion.id);
    setState(() {
      isFavorite = !isFavorite;
    });
    widget.onFavoriteChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final splashUrl =
        'https://ddragon.leagueoflegends.com/cdn/img/champion/splash/${widget.champion.id}_0.jpg';
    final role =
        widget.champion.tags.isNotEmpty ? widget.champion.tags.first : '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChampionDetailPage(championId: widget.champion.id),
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
            Image.network(splashUrl, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.45, 1.0],
                  colors: [
                    Colors.transparent,
                    AppColors.background.withOpacity(0.92),
                  ],
                ),
              ),
            ),
            ChampionCardFavoriteBadge(
              isFavorite: isFavorite,
              onTap: toggleFavorite,
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
                    widget.champion.name,
                    style: GoogleFonts.instrumentSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.champion.title,
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
