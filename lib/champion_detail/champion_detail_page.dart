import 'package:flutter/material.dart';
import '../champions/models/champion_detail.dart';
import '../champions/services/champion_service.dart';
import 'widgets/ability_tile/ability_tile.dart';
import 'widgets/champion_hero_banner/champion_hero_banner.dart';
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

  @override
  void initState() {
    super.initState();
    loadDetail();
  }

  Future<void> loadDetail() async {
    final result = await ChampionService.fetchDetail(widget.championId);
    setState(() {
      detail = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
