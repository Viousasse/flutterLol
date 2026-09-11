import 'package:flutter/material.dart';
import '../../../roles/roles_page.dart';

class RolesLink extends StatelessWidget {
  const RolesLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: ListTile(
        leading: const Icon(Icons.category, color: Colors.deepPurple),
        title: const Text('Voir les champions par rôle'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RolesPage()),
          );
        },
      ),
    );
  }
}
