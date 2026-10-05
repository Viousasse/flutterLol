import 'package:flutter/material.dart';

import '../champions/models/champion.dart';
import '../builds/build_editor_page.dart';
import '../compare/compare_page.dart';
import '../counters/counters_page.dart';
import '../strengths/strengths_page.dart';
import '../shared/widgets/action_link/action_link.dart';
import '../shared/widgets/expandable_text/expandable_text.dart';
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
import 'widgets/matchup_section/matchup_section.dart';
import 'widgets/rune_plan_section/rune_plan_section.dart';
import 'widgets/skin_gallery/skin_gallery.dart';
import 'widgets/summoner_spell_section/summoner_spell_section.dart';
import '../summoner_spells/models/summoner_spell.dart';
import '../summoner_spells/services/summoner_spell_recommender.dart';
import '../summoner_spells/services/summoner_spell_service.dart';
import '../matchups/models/matchup.dart';
import '../matchups/services/matchup_service.dart';
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

  RoleRecommendation? recommendation;
  List<Item> recommendedItems = const [];
  bool isLoadingRecommendation = true;

  MatchupDataset matchups = const MatchupDataset.empty();
  List<Champion> allChampions = const [];
  bool isLoadingMatchups = true;

  List<SummonerSpell> summonerSpells = const [];
  String summonerSpellReason = '';

  @override
  void initState() {
    super.initState();
    loadDetail();
    loadMatchups();
  }

  /// Les matchups viennent d'un fichier embarqué et de la liste des champions
  /// déjà en cache : un échec masque simplement la section.
  Future<void> loadMatchups() async {
    try {
      final loaded = await Future.wait([
        MatchupService.load(),
        ChampionService.fetchAll(),
      ]);

      if (!mounted) return;
      setState(() {
        matchups = loaded[0] as MatchupDataset;
        allChampions = loaded[1] as List<Champion>;
        isLoadingMatchups = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoadingMatchups = false);
    }
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
      loadSummonerSpells(result.tags);
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

  /// Les sorts conseillés sont un bonus : sans eux, la fiche reste complète.
  /// La voie la plus jouée vient des matchups ; sans elle, c'est le profil du
  /// champion qui décide.
  Future<void> loadSummonerSpells(List<String> tags) async {
    try {
      final dataset = await MatchupService.load();
      final plan = SummonerSpellRecommender.recommend(
        tags: tags,
        lane: MatchupService.mainLaneOf(widget.championId, dataset),
      );
      final spells = await SummonerSpellService.byIds(plan.spellIds);

      if (!mounted) return;
      setState(() {
        summonerSpells = spells;
        summonerSpellReason = plan.reason;
      });
    } catch (_) {
      // Pas de section de sorts, rien d'autre à signaler à l'utilisateur.
    }
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
          ValueListenableBuilder<Set<String>>(
            valueListenable: FavoritesService.favorites,
            builder: (context, favorites, _) => ChampionHeroBanner(
              championId: widget.championId,
              name: detail!.name,
              title: detail!.title,
              isFavorite: favorites.contains(widget.championId),
              onToggleFavorite: () =>
                  FavoritesService.toggleFavorite(widget.championId),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text('Histoire', style: AppTheme.serif(size: 20)),
                const SizedBox(height: 10),
                ExpandableText(
                  text: detail!.lore,
                  style: AppTheme.serif(
                    size: 14,
                    color: AppColors.textSecondary,
                  ).copyWith(height: 1.6),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionLink(
                      icon: Icons.compare_arrows,
                      label: 'Comparer avec un autre champion',
                      semanticLabel: 'Comparer ce champion avec un autre',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ComparePage(
                            initialChampionId: widget.championId,
                          ),
                        ),
                      ),
                    ),
                    ActionLink(
                      icon: Icons.military_tech,
                      label: 'Contre qui est-il fort ?',
                      semanticLabel: 'Voir contre qui ce champion est fort',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StrengthsPage(
                            initialChampionId: widget.championId,
                          ),
                        ),
                      ),
                    ),
                    ActionLink(
                      icon: Icons.person_search,
                      label: 'Qui jouer contre lui ?',
                      semanticLabel: 'Voir les meilleurs contre-picks',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CountersPage(
                            initialOpponentId: widget.championId,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text('Capacités', style: AppTheme.serif(size: 20)),
                const SizedBox(height: 6),
                AbilityTile(label: 'P', ability: detail!.passive),
                ...detail!.spells.asMap().entries.map((entry) {
                  return AbilityTile(
                    label: labels[entry.key],
                    ability: entry.value,
                  );
                }),
                if (detail!.skins.length > 1) ...[
                  const SizedBox(height: 22),
                  Text(
                    'Apparences (${detail!.skins.length})',
                    style: AppTheme.serif(size: 20),
                  ),
                  const SizedBox(height: 10),
                  SkinGallery(skins: detail!.skins),
                ],
                if (!isLoadingRecommendation && recommendation != null) ...[
                  const SizedBox(height: 14),
                  Text('Runes conseillées', style: AppTheme.serif(size: 20)),
                  const SizedBox(height: 10),
                  RunePlanSection(plan: recommendation!.runes),
                  if (summonerSpells.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Text(
                      "Sorts d'invocateur",
                      style: AppTheme.serif(size: 20),
                    ),
                    const SizedBox(height: 10),
                    SummonerSpellSection(
                      spells: summonerSpells,
                      reason: summonerSpellReason,
                    ),
                  ],
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
                  const SizedBox(height: 12),
                  ActionLink(
                    icon: Icons.construction,
                    label: 'Créer une build avec ces objets',
                    semanticLabel: 'Créer une build avec les objets conseillés',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BuildEditorPage(
                          initialChampionId: widget.championId,
                          initialItemIds: recommendedItems
                              .map((item) => item.id)
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ],
                if (!isLoadingMatchups) ...[
                  const SizedBox(height: 28),
                  Text('Matchups', style: AppTheme.serif(size: 20)),
                  const SizedBox(height: 10),
                  MatchupSection(
                    championId: widget.championId,
                    dataset: matchups,
                    champions: allChampions,
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
