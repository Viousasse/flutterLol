import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../champions/models/champion.dart';
import '../../../champion_detail/champion_detail_page.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

class StoryList extends StatelessWidget {
  final List<Champion> stories;

  const StoryList({super.key, required this.stories});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: stories.map((champion) {
        return Container(
          margin: const EdgeInsets.only(bottom: 9),
          child: Material(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChampionDetailPage(championId: champion.id),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColors.accent, width: 2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      champion.name,
                      style: GoogleFonts.instrumentSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      champion.blurb,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.serif(
                        size: 12.5,
                        italic: true,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
