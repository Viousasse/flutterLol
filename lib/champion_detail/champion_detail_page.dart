import 'package:flutter/material.dart';
import '../champions/models/champion_detail.dart';
import '../champions/services/champion_service.dart';
import '../champions/services/favorites_service.dart';
import '../items/models/item.dart';
import '../items/models/item_stack.dart';
import '../items/services/item_service.dart';
import '../items/widgets/item_detail_sheet/item_detail_sheet.dart';
import '../items/widgets/item_recipe_section/item_recipe_section.dart';
import '../recommendations/models/champion_recommendations.dart';
import '../recommendations/models/role_recommendation.dart';
import '../runes/services/rune_service.dart';
import '../shared/errors/user_message.dart';
import '../shared/widgets/error_retry_view/error_retry_view.dart';
import 'widgets/ability_tile/ability_tile.dart';
import 'widgets/champion_hero_banner/champion_hero_banner.dart';
import 'widgets/rune_plan_section/rune_plan_section.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class ChampionDetailPage extends StatefulWidget {
  final String championId;

  const ChampionDetailPage({super.key, required this.championId});

  @override
  State<ChampionDetailPage> createState() => _ChampionDetailPageState();
}

class _ChampionDetailPageState extends State<ChampionDetailPage> {
  ChampionDetail? detail;
  bool isLoading = true;
  String? errorMessage;
  bool isFavorite = false;

  RoleRecommendation? recommendation;
  List<Item> recommendedItems = const [];
  bool isLoadingRecommendation = true;

  @override
  void initState() {
    super.initState();
    loadDetail();
    loadFavoriteStatus();
  }

  Future<void> loadDetail() async {
    try {
      final result = await ChampionService.fetchDetail(widget.championId);
      if (!mounted) return;
      setState(() {
        detail = result;
        isLoading = false;
      });
      loadRecommendation(result.tags);
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
      isLoadingRecommendation = true;
    });
    loadDetail();
  }

  /// Les conseils sont un bonus : s'ils ne chargent pas, la fiche du champion
  /// reste lisible, on masque simplement la section.
  Future<void> loadRecommendation(List<String> tags) async {
    final roleRecommendation = ChampionRecommendations.forChampion(
      widget.championId,
      tags,
    );

    try {
      final loaded = await Future.wait([
        RuneService.fetchAll(),
        ItemService.byIds(roleRecommendation.itemIds),
      ]);

      if (!mounted) return;
      setState(() {
        recommendation = roleRecommendation;
        recommendedItems = loaded[1] as List<Item>;
        isLoadingRecommendation = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoadingRecommendation = false);
    }
  }

  Future<void> loadFavoriteStatus() async {
    final favorite = await FavoritesService.isFavorite(widget.championId);
    setState(() {
      isFavorite = favorite;
    });
  }

  Future<void> toggleFavorite() async {
    await FavoritesService.toggleFavorite(widget.championId);
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final failure = errorMessage;
    if (failure != null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorRetryView(message: failure, onRetry: retry),
      );
    }

    final labels = ['A', 'Z', 'E', 'R'];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          ChampionHeroBanner(
            championId: widget.championId,
            name: detail!.name,
            title: detail!.title,
            isFavorite: isFavorite,
            onToggleFavorite: toggleFavorite,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text('Histoire', style: AppTheme.serif(size: 20)),
                const SizedBox(height: 10),
                Text(
                  detail!.lore,
                  style: AppTheme.serif(
                    size: 14,
                    color: AppColors.textSecondary,
                  ).copyWith(height: 1.6),
                ),
                const SizedBox(height: 28),
                Text('Capacités', style: AppTheme.serif(size: 20)),
                const SizedBox(height: 6),
                AbilityTile(label: 'P', ability: detail!.passive),
                ...detail!.spells.asMap().entries.map((entry) {
                  return AbilityTile(
                    label: labels[entry.key],
                    ability: entry.value,
                  );
                }),
                if (!isLoadingRecommendation && recommendation != null) ...[
                  const SizedBox(height: 14),
                  Text('Runes conseillées', style: AppTheme.serif(size: 20)),
                  const SizedBox(height: 10),
                  RunePlanSection(plan: recommendation!.runes),
                  const SizedBox(height: 28),
                  Text('Objets conseillés', style: AppTheme.serif(size: 20)),
                  const SizedBox(height: 10),
                  ItemRecipeSection(
                    title: 'Cœur de build',
                    stacks: recommendedItems
                        .map((item) => ItemStack(item: item, count: 1))
                        .toList(),
                    onSelect: (item) => ItemDetailSheet.show(context, item),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
