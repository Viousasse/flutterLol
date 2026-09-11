import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../champions/models/champion.dart';
import '../champions/services/champion_service.dart';
import '../theme/app_colors.dart';
import 'widgets/home_greeting/home_greeting.dart';
import 'widgets/champion_hero_card/champion_hero_card.dart';
import 'widgets/role_scroller/role_scroller.dart';
import 'widgets/story_list/story_list.dart';
import 'widgets/favorites_shortcut/favorites_shortcut.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Champion> champions = [];
  Champion? championOfTheDay;
  List<Champion> storyPicks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final result = await ChampionService.fetchAll();
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = dayOfYear % result.length;

    setState(() {
      champions = result;
      championOfTheDay = result[index];
      storyPicks = [
        result[(index + 7) % result.length],
        result[(index + 21) % result.length],
      ];
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

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const HomeGreeting(),
            ChampionHeroCard(champion: championOfTheDay!),
            const SizedBox(height: 26),
            const _SectionTitle('Par rôle'),
            const SizedBox(height: 11),
            RoleScroller(champions: champions),
            const SizedBox(height: 24),
            const _SectionTitle('Histoires à lire'),
            const SizedBox(height: 11),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: StoryList(stories: storyPicks),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: FavoritesShortcut(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;

  const _SectionTitle(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        label,
        style: GoogleFonts.instrumentSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
