import 'package:flutter/material.dart';
import '../../models/champion.dart';
import '../../services/favorites_service.dart';

class ChampionTile extends StatefulWidget {
  final Champion champion;

  const ChampionTile({super.key, required this.champion});

  @override
  State<ChampionTile> createState() => _ChampionTileState();
}

class _ChampionTileState extends State<ChampionTile> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    loadFavoriteStatus();
  }

  Future<void> loadFavoriteStatus() async {
    final favorite = await FavoritesService.isFavorite(widget.champion.id);
    setState(() {
      isFavorite = favorite;
    });
  }

  Future<void> toggleFavorite() async {
    await FavoritesService.toggleFavorite(widget.champion.id);
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(widget.champion.imageUrl, width: 50, height: 50),
      title: Text(widget.champion.name),
      subtitle: Text(widget.champion.title),
      trailing: IconButton(
        icon: Icon(
          isFavorite ? Icons.star : Icons.star_border,
          color: isFavorite ? Colors.amber : null,
        ),
        onPressed: toggleFavorite,
      ),
    );
  }
}
