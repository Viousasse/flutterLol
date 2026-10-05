import 'package:flutter/material.dart';

import '../home/home_page.dart';
import '../champions/champions_page.dart';
import '../quiz/quiz_page.dart';
import '../items/items_page.dart';
import '../map/map_page.dart';
import '../tools/tools_page.dart';
import 'widgets/app_nav_bar/app_nav_bar.dart';

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

  final destinations = const [
    AppNavDestination(
      label: 'Accueil',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    AppNavDestination(
      label: 'Champions',
      icon: Icons.shield_outlined,
      selectedIcon: Icons.shield,
    ),
    AppNavDestination(
      label: 'Quiz',
      icon: Icons.quiz_outlined,
      selectedIcon: Icons.quiz,
    ),
    AppNavDestination(
      label: 'Objets',
      icon: Icons.backpack_outlined,
      selectedIcon: Icons.backpack,
    ),
    AppNavDestination(
      label: 'Outils',
      icon: Icons.build_outlined,
      selectedIcon: Icons.build,
    ),
    AppNavDestination(
      label: 'Carte',
      icon: Icons.map_outlined,
      selectedIcon: Icons.map,
    ),
  ];

  Widget _buildPage(int index) {
    if (!visitedTabs.contains(index)) return const SizedBox.shrink();

    switch (index) {
      case 1:
        return const ChampionsPage();
      case 2:
        return const QuizPage();
      case 3:
        return const ItemsPage();
      case 4:
        return const ToolsPage();
      case 5:
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
          for (var index = 0; index < destinations.length; index++)
            _buildPage(index),
        ],
      ),
      bottomNavigationBar: AppNavBar(
        destinations: destinations,
        currentIndex: currentIndex,
        onSelect: _openTab,
      ),
    );
  }
}
