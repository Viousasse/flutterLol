import 'package:flutter/material.dart';
import '../champions/models/champion.dart';
import '../champions/services/champion_service.dart';
import '../champions/services/favorites_service.dart';
import '../champions/widgets/champion_card/champion_card.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => FavoritesPageState();
}

class FavoritesPageState extends State<FavoritesPage> {
  List<Champion> favoriteChampions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> reload() async {
    setState(() {
      isLoading = true;
    });
    await loadFavorites();
  }

  Future<void> loadFavorites() async {
    final allChampions = await ChampionService.fetchAll();
    final favoriteIds = await FavoritesService.getFavorites();

    setState(() {
      favoriteChampions =
          allChampions.where((c) => favoriteIds.contains(c.id)).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Favoris', style: AppTheme.serif(size: 24)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteChampions.isEmpty
              ? Center(
                  child: Text(
                    'Aucun champion favori pour le moment',
                    style: AppTheme.serif(size: 15, color: AppColors.textMuted),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: favoriteChampions.length,
                  itemBuilder: (context, index) {
                    return ChampionCard(
                      champion: favoriteChampions[index],
                      onFavoriteChanged: reload,
                    );
                  },
                ),
    );
  }
}
