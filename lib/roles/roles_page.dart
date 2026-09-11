import 'package:flutter/material.dart';
import '../champions/constants/roles.dart';
import '../champions/services/champion_service.dart';
import '../champions_by_role/champions_by_role_page.dart';
import '../theme/app_theme.dart';
import 'widgets/role_row/role_row.dart';

class RolesPage extends StatefulWidget {
  const RolesPage({super.key});

  @override
  State<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {
  Map<String, int> counts = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCounts();
  }

  Future<void> loadCounts() async {
    final champions = await ChampionService.fetchAll();
    final result = <String, int>{};
    for (final role in roleList) {
      result[role] = champions.where((c) => c.tags.contains(role)).length;
    }
    setState(() {
      counts = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rôles', style: AppTheme.serif(size: 24)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: roleList.map((role) {
                return RoleRow(
                  role: role,
                  count: counts[role] ?? 0,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChampionsByRolePage(role: role),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
    );
  }
}
