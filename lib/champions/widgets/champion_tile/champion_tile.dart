import 'package:flutter/material.dart';
import '../../models/champion.dart';

class ChampionTile extends StatelessWidget {
  final Champion champion;

  const ChampionTile({super.key, required this.champion});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(champion.imageUrl, width: 50, height: 50),
      title: Text(champion.name),
      subtitle: Text(champion.title),
    );
  }
}
