import 'package:flutter/material.dart';
import '../matchups/services/matchup_service.dart';
import '../regions/models/lore_region.dart';
import '../compare/compare_page.dart';
import 'constants/champion_grid.dart';
import 'models/champion.dart';
import 'models/champion_sort.dart';
import 'services/champion_filter.dart';
import 'services/champion_service.dart';
import 'widgets/champion_card/champion_card.dart';
import 'widgets/champion_sort_button/champion_sort_button.dart';
import 'widgets/champions_search_bar/champions_search_bar.dart';
import 'widgets/region_filter_bar/region_filter_bar.dart';
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
  Map<String, double> winRates = const {};
  bool isLoading = true;
  String? errorMessage;
  String query = '';
  String? selectedRole;
  RegionId? selectedRegion;
  ChampionSort sort = ChampionSort.name;

  @override
  void initState() {
    super.initState();
    loadChampions();
    loadWinRates();
  }

  Future<void> loadChampions() async {
    try {
      final result = await ChampionService.fetchAll();
      if (!mounted) return;
      setState(() {
        allChampions = result;
        isLoading = false;
      });
      applyFilters();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        errorMessage = userMessageFor(error);
        isLoading = false;
      });
    }
  }

  /// Les taux de victoire ne servent qu'au tri : si le fichier embarqué ne se
  /// charge pas, ce tri place simplement tout le monde à égalité.
  Future<void> loadWinRates() async {
    try {
      // Déjà en cache dès que la liste est chargée : pas de second téléchargement.
      final champions = await ChampionService.fetchAll();
      final dataset = await MatchupService.load();
      final rates = <String, double>{};

      for (final champion in champions) {
        final record = MatchupService.overallFor(champion.id, dataset);
        if (record.isReliable) rates[champion.id] = record.winRate;
      }

      if (!mounted) return;
      winRates = rates;
      applyFilters();
    } catch (_) {
      // Tri par victoires indisponible, le reste de la page fonctionne.
    }
  }

  void retry() {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    loadChampions();
    loadWinRates();
  }

  void applyFilters() {
    setState(() {
      filteredChampions = ChampionFilter.apply(
        allChampions,
        query: query,
        role: selectedRole,
        region: selectedRegion,
        sort: sort,
        winRates: winRates,
      );
    });
  }

  void openComparison() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ComparePage()),
    );
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
                '${filteredChampions.length} sur ${allChampions.length}',
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
          const SizedBox(height: 8),
          RegionFilterBar(
            selectedRegion: selectedRegion,
            onSelect: (region) {
              selectedRegion = region;
              applyFilters();
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ChampionSortButton(
                current: sort,
                onChanged: (next) {
                  sort = next;
                  applyFilters();
                },
              ),
              const SizedBox(width: 8),
              _CompareButton(onTap: openComparison),
            ],
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
        gridDelegate: championGridDelegate,
        delegate: SliverChildBuilderDelegate(
          (context, index) => ChampionCard(champion: filteredChampions[index]),
          childCount: filteredChampions.length,
        ),
      ),
    );
  }
}

class _CompareButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CompareButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Comparer deux champions',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.compare_arrows, size: 14, color: AppColors.accent),
              const SizedBox(width: 5),
              Text(
                'Comparer',
                style: AppTheme.mono(size: 11, color: AppColors.accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
