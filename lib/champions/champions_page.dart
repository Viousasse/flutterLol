import 'package:flutter/material.dart';
import 'models/champion.dart';
import 'services/champion_service.dart';
import 'widgets/champion_card/champion_card.dart';
import 'widgets/champions_search_bar/champions_search_bar.dart';
import 'widgets/role_filter_bar/role_filter_bar.dart';
import '../shared/errors/user_message.dart';
import '../shared/widgets/error_retry_view/error_retry_view.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class ChampionsPage extends StatefulWidget {
  const ChampionsPage({super.key});

  @override
  State<ChampionsPage> createState() => _ChampionsPageState();
}

class _ChampionsPageState extends State<ChampionsPage> {
  List<Champion> allChampions = [];
  List<Champion> filteredChampions = [];
  bool isLoading = true;
  String? errorMessage;
  String query = '';
  String? selectedRole;

  @override
  void initState() {
    super.initState();
    loadChampions();
  }

  Future<void> loadChampions() async {
    try {
      final result = await ChampionService.fetchAll();
      if (!mounted) return;
      setState(() {
        allChampions = result;
        filteredChampions = result;
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

  void applyFilters() {
    setState(() {
      filteredChampions = allChampions.where((c) {
        final matchesQuery =
            c.name.toLowerCase().contains(query.toLowerCase());
        final matchesRole =
            selectedRole == null || c.tags.contains(selectedRole);
        return matchesQuery && matchesRole;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final failure = errorMessage;
    if (failure != null) {
      return Scaffold(
        body: SafeArea(
          child: ErrorRetryView(message: failure, onRetry: retry),
        ),
      );
    }

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  _buildGrid(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Champions', style: AppTheme.serif(size: 32)),
              Text(
                '${allChampions.length} au total',
                style: AppTheme.mono(color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ChampionsSearchBar(
            onChanged: (value) {
              query = value;
              applyFilters();
            },
          ),
          const SizedBox(height: 12),
          RoleFilterBar(
            selectedRole: selectedRole,
            onSelect: (role) {
              selectedRole = role;
              applyFilters();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    if (filteredChampions.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text(
              'Aucun champion ne correspond.',
              style: AppTheme.serif(size: 15, color: AppColors.textMuted),
            ),
          ),
        ),
      );
    }


    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => ChampionCard(champion: filteredChampions[index]),
          childCount: filteredChampions.length,
        ),
      ),
    );
  }
}
