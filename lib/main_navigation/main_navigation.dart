import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/home_page.dart';
import '../champions/champions_page.dart';
import '../roles/roles_page.dart';
import '../items/items_page.dart';
import '../map/map_page.dart';
import '../favorites/favorites_page.dart';
import '../theme/app_colors.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  final labels = const [
    'Accueil',
    'Champions',
    'Rôles',
    'Objets',
    'Carte',
    'Favoris',
  ];

  Widget _buildPage() {
    switch (currentIndex) {
      case 0:
        return const HomePage();
      case 1:
        return const ChampionsPage();
      case 2:
        return const RolesPage();
      case 3:
        return const ItemsPage();
      case 4:
        return const MapPage();
      case 5:
        return const FavoritesPage();
      default:
        return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPage(),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          color: AppColors.background,
          child: Row(
            children: List.generate(labels.length, (index) {
              final selected = currentIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.accentSoft
                          : AppColors.textPrimary.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppColors.accent.withOpacity(0.35)
                            : AppColors.border,
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        labels[index],
                        style: GoogleFonts.instrumentSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color:
                              selected ? AppColors.accent : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
