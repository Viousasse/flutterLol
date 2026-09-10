import 'package:flutter/material.dart';
import '../../../favorites/favorites_page.dart';

class FavoritesLink extends StatelessWidget {
  const FavoritesLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: ListTile(
        leading: const Icon(Icons.star, color: Colors.amber),
        title: const Text('Mes champions favoris'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FavoritesPage()),
          );
        },
      ),
    );
  }
}
