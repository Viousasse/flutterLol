import 'package:flutter/material.dart';
import '../../models/champion.dart';
import '../../services/favorites_service.dart';
import '../../../champion_detail/champion_detail_page.dart';
import '../../../theme/app_colors.dart';
import 'champion_card_favorite_badge.dart';
import 'champion_card_info.dart';

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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.6,
                  child: Image.network(splashUrl, fit: BoxFit.cover),
                ),
                ChampionCardFavoriteBadge(
                  isFavorite: isFavorite,
                  onTap: toggleFavorite,
                ),
              ],
            ),
            ChampionCardInfo(
              name: widget.champion.name,
              title: widget.champion.title,
              role: role,
            ),
          ],
        ),
      ),
    );
  }
}
