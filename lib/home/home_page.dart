import 'package:flutter/material.dart';
import 'widgets/champion_of_the_day/champion_of_the_day.dart';
import 'widgets/favorites_link/favorites_link.dart';
import 'widgets/roles_link/roles_link.dart';
import 'widgets/random_lore/random_lore.dart';
import '../champions/champions_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LoL App'),
      ),
      body: ListView(
        children: [
          const ChampionOfTheDay(),
          const FavoritesLink(),
          const RolesLink(),
          const RandomLore(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChampionsPage()),
                );
              },
              child: const Text('Voir tous les champions'),
            ),
          ),
        ],
      ),
    );
  }
}
