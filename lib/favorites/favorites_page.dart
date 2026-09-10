import 'package:flutter/material.dart';
import '../champions/models/champion.dart';
import '../champions/services/champion_service.dart';
import '../champions/services/favorites_service.dart';
import '../champions/widgets/champion_tile/champion_tile.dart';

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
        title: const Text('Mes favoris'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteChampions.isEmpty
              ? const Center(child: Text('Aucun champion favori pour le moment'))
              : ListView.builder(
                  itemCount: favoriteChampions.length,
                  itemBuilder: (context, index) {
                    return ChampionTile(champion: favoriteChampions[index]);
                  },
                ),
    );
  }
}
