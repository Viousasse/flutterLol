import 'package:flutter/material.dart';

import '../theme/app_fonts.dart';
import '../home/home_page.dart';
import '../champions/champions_page.dart';
import '../roles/roles_page.dart';
import '../items/items_page.dart';
import '../map/map_page.dart';
import '../theme/app_colors.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  /// Un onglet n'est construit qu'une fois ouvert, puis gardé vivant par
  /// l'IndexedStack : y revenir retrouve son défilement, sa recherche et ses
  /// filtres, sans pour autant télécharger au démarrage les données des
  /// onglets que l'utilisateur n'a jamais visités.
  final Set<int> visitedTabs = {0};

  final labels = const ['Accueil', 'Champions', 'Rôles', 'Objets', 'Carte'];

  Widget _buildPage(int index) {
    if (!visitedTabs.contains(index)) return const SizedBox.shrink();

    switch (index) {
      case 1:
        return const ChampionsPage();
      case 2:
        return const RolesPage();
      case 3:
        return const ItemsPage();
      case 4:
        return const MapPage();
      default:
        return const HomePage();
    }
  }

  void _openTab(int index) {
    setState(() {
      currentIndex = index;
      visitedTabs.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          for (var index = 0; index < labels.length; index++) _buildPage(index),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          color: AppColors.background,
          child: Row(
            children: List.generate(labels.length, (index) {
              final selected = currentIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _openTab(index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.accentSoft
                          : AppColors.textPrimary.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppColors.accent.withValues(alpha: 0.35)
                            : AppColors.border,
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        labels[index],
                        style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? AppColors.accent
                              : AppColors.textMuted,
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
