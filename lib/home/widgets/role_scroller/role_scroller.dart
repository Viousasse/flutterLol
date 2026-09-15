import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../champions/constants/roles.dart';
import '../../../champions/models/champion.dart';
import '../../../champions_by_role/champions_by_role_page.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

class RoleScroller extends StatelessWidget {
  final List<Champion> champions;

  const RoleScroller({super.key, required this.champions});

  int _countForRole(String role) {
    return champions.where((c) => c.tags.contains(role)).length;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        children: roleList.map((role) {
          return Padding(
            padding: const EdgeInsets.only(right: 9),
            child: _RoleCard(role: role, count: _countForRole(role)),
          );
        }).toList(),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String role;
  final int count;

  const _RoleCard({required this.role, required this.count});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChampionsByRolePage(role: role),
          ),
        );
      },
      child: Container(
        width: 104,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(roleIcons[role], size: 15, color: AppColors.accent),
            ),
            const Spacer(),
            Text(
              role,
              style: GoogleFonts.instrumentSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '$count champions',
              style: AppTheme.mono(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
