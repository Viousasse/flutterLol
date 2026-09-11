import 'package:flutter/material.dart';
import '../../models/champion.dart';
import '../../services/favorites_service.dart';
import '../../../champion_detail/champion_detail_page.dart';

class ChampionTile extends StatefulWidget {
  final Champion champion;
  final VoidCallback? onFavoriteChanged;

  const ChampionTile({
    super.key,
    required this.champion,
    this.onFavoriteChanged,
  });

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
    widget.onFavoriteChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(widget.champion.imageUrl, width: 50, height: 50),
      title: Text(widget.champion.name),
      subtitle: Text(widget.champion.title),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChampionDetailPage(championId: widget.champion.id),
          ),
        );
      },
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
