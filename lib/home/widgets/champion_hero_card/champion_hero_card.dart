import 'package:flutter/material.dart';

import '../../../shared/widgets/remote_image/remote_image.dart';
import '../../../theme/app_fonts.dart';
import '../../../champions/models/champion.dart';
import '../../../champion_detail/champion_detail_page.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

class ChampionHeroCard extends StatelessWidget {
  final Champion champion;

  const ChampionHeroCard({super.key, required this.champion});

  @override
  Widget build(BuildContext context) {
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
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 240,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            RemoteImage(
              url:
                  'https://ddragon.leagueoflegends.com/cdn/img/champion/splash/${champion.id}_0.jpg',
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.08, 0.62],
                  colors: [
                    AppColors.background.withValues(alpha: 0.95),
                    AppColors.background.withValues(alpha: 0.15),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  'Champion du jour',
                  style: AppTheme.mono(
                    size: 9,
                    color: AppColors.background,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 15,
              child: _HeroCaption(champion: champion),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCaption extends StatelessWidget {
  final Champion champion;

  const _HeroCaption({required this.champion});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(champion.name, style: AppTheme.serif(size: 30)),
        const SizedBox(height: 4),
        Text(
          champion.title,
          style: AppTheme.serif(
            size: 14,
            italic: true,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (champion.tags.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  champion.tags.first,
                  style: AppTheme.mono(size: 9, color: AppColors.accent),
                ),
              ),
            const SizedBox(width: 8),
            Text(
              'Lire son histoire ›',
              style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 11.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
