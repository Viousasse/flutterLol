import 'package:flutter/material.dart';
import 'widgets/role_tile/role_tile.dart';
import '../champions_by_role/champions_by_role_page.dart';

class RolesPage extends StatelessWidget {
  const RolesPage({super.key});

  final roles = const [
    {'name': 'Tank', 'icon': Icons.shield},
    {'name': 'Fighter', 'icon': Icons.sports_martial_arts},
    {'name': 'Assassin', 'icon': Icons.flash_on},
    {'name': 'Mage', 'icon': Icons.auto_fix_high},
    {'name': 'Marksman', 'icon': Icons.gps_fixed},
    {'name': 'Support', 'icon': Icons.favorite},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rôles'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: roles.map((role) {
          return RoleTile(
            name: role['name'] as String,
            icon: role['icon'] as IconData,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChampionsByRolePage(role: role['name'] as String),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
