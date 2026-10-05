import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'widgets/favorite_champions_tab/favorite_champions_tab.dart';
import 'widgets/favorite_items_tab/favorite_items_tab.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Favoris', style: AppTheme.serif(size: 24)),
          bottom: TabBar(
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.textMuted,
            dividerColor: AppColors.border,
            tabs: const [
              Tab(text: 'Champions'),
              Tab(text: 'Objets'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [FavoriteChampionsTab(), FavoriteItemsTab()],
        ),
      ),
    );
  }
}
