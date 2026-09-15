import 'package:flutter/material.dart';
import '../champions/models/champion.dart';
import '../champions/services/champion_service.dart';
import '../champions/widgets/champion_card/champion_card.dart';
import '../champions/widgets/champions_search_bar/champions_search_bar.dart';
import '../shared/errors/user_message.dart';
import '../shared/widgets/error_retry_view/error_retry_view.dart';
import '../theme/app_theme.dart';

class ChampionsByRolePage extends StatefulWidget {
  final String role;

  const ChampionsByRolePage({super.key, required this.role});

  @override
  State<ChampionsByRolePage> createState() => _ChampionsByRolePageState();
}

class _ChampionsByRolePageState extends State<ChampionsByRolePage> {
  List<Champion> allRoleChampions = [];
  List<Champion> filteredChampions = [];
  bool isLoading = true;
  String? errorMessage;
  String query = '';

  @override
  void initState() {
    super.initState();
    loadChampions();
  }

  Future<void> loadChampions() async {
    try {
      final allChampions = await ChampionService.fetchAll();
      if (!mounted) return;
      setState(() {
        allRoleChampions =
            allChampions.where((c) => c.tags.contains(widget.role)).toList();
        filteredChampions = allRoleChampions;
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
    loadChampions();
  }

  void applyFilter(String value) {
    setState(() {
      query = value;
      filteredChampions = allRoleChampions
          .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.role, style: AppTheme.serif(size: 24)),
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        children: [
          ChampionsSearchBar(onChanged: applyFilter),
          const SizedBox(height: 14),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemCount: filteredChampions.length,
              itemBuilder: (context, index) {
                return ChampionCard(champion: filteredChampions[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
