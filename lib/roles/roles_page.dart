import 'package:flutter/material.dart';
import '../champions/constants/roles.dart';
import '../champions/services/champion_service.dart';
import '../champions_by_role/champions_by_role_page.dart';
import '../shared/errors/user_message.dart';
import '../shared/widgets/error_retry_view/error_retry_view.dart';
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
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadCounts();
  }

  Future<void> loadCounts() async {
    try {
      final champions = await ChampionService.fetchAll();
      final result = <String, int>{};
      for (final role in roleList) {
        result[role] = champions.where((c) => c.tags.contains(role)).length;
      }

      if (!mounted) return;
      setState(() {
        counts = result;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        errorMessage = userMessageFor(error);
        isLoading = false;
      });
    }
  }

  void retry() {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    loadCounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rôles', style: AppTheme.serif(size: 24)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final failure = errorMessage;
    if (failure != null) {
      return ErrorRetryView(message: failure, onRetry: retry);
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
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
    );
  }
}
