import 'package:flutter/material.dart';

import '../../../champions/models/champion.dart';
import '../../../champion_detail/champion_detail_page.dart';
import '../../../shared/widgets/remote_image/remote_image.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../models/lore_region.dart';

/// Fiche de la région sélectionnée : son histoire, son effectif, ses champions.
class RegionDetails extends StatelessWidget {
  final LoreRegion? region;
  final List<Champion> champions;

  const RegionDetails({
    super.key,
    required this.region,
    required this.champions,
  });

  @override
  Widget build(BuildContext context) {
    final selected = region;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: selected == null
          ? Text(
              'Touchez une région pour voir son histoire et ses champions.',
              style: AppTheme.mono(size: 10, color: AppColors.textMuted),
            )
          : _Details(region: selected, champions: champions),
    );
  }
}

class _Details extends StatelessWidget {
  final LoreRegion region;
  final List<Champion> champions;

  const _Details({required this.region, required this.champions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: region.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(region.name, style: AppTheme.serif(size: 18))),
            Text(
              '${champions.length} champions',
              style: AppTheme.mono(size: 9, color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          region.tagline,
          style: AppTheme.serif(
            size: 12,
            italic: true,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          region.description,
          style: TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 13,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        if (champions.isNotEmpty) ...[
          const SizedBox(height: 14),
          SizedBox(
            height: 78,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: champions.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) =>
                  _ChampionChip(champion: champions[index]),
            ),
          ),
        ],
      ],
    );
  }
}

class _ChampionChip extends StatelessWidget {
  final Champion champion;

  const _ChampionChip({required this.champion});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChampionDetailPage(championId: champion.id),
        ),
      ),
      child: SizedBox(
        width: 54,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: RemoteImage(url: champion.imageUrl, width: 48, height: 48),
            ),
            const SizedBox(height: 4),
            Text(
              champion.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
