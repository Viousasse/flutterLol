import 'package:flutter/material.dart';

import '../theme/app_fonts.dart';
import '../champions/models/champion.dart';
import '../champions/services/champion_service.dart';
import '../data_dragon/data_dragon_exception.dart';
import '../data_dragon/data_dragon_service.dart';
import '../patch_notes/models/patch_notes.dart';
import '../roles/roles_page.dart';
import '../search/search_page.dart';
import '../shared/errors/user_message.dart';
import '../shared/widgets/error_retry_view/error_retry_view.dart';
import '../theme/app_colors.dart';
import 'widgets/home_greeting/home_greeting.dart';
import 'widgets/champion_hero_card/champion_hero_card.dart';
import 'widgets/daily_quiz_card/daily_quiz_card.dart';
import 'widgets/patch_notes_card/patch_notes_card.dart';import 'widgets/role_scroller/role_scroller.dart';
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
  PatchNotes? patchNotes;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadData();
    loadPatchNotes();
  }

  /// La carte du patch est un bonus : sans la version du jeu, elle est
  /// simplement absente et l'accueil reste complet.
  Future<void> loadPatchNotes() async {
    try {
      final version = await DataDragonService.latestVersion();
      final notes = PatchNotes.fromVersion(version);
      if (!mounted) return;
      setState(() => patchNotes = notes);
    } catch (_) {
      // Pas de carte de patch, rien d'autre à signaler à l'utilisateur.
    }
  }

  Future<void> loadData() async {
    try {
      final result = await ChampionService.fetchAll();
      if (result.isEmpty) {
        throw const DataDragonException('Aucun champion reçu.');
      }

      final now = DateTime.now();
      final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
      final index = dayOfYear % result.length;

      if (!mounted) return;
      setState(() {
        champions = result;
        championOfTheDay = result[index];
        storyPicks = [
          result[(index + 7) % result.length],
          result[(index + 21) % result.length],
        ];
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
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final failure = errorMessage;
    if (failure != null) {
      return Scaffold(
        body: SafeArea(
          child: ErrorRetryView(message: failure, onRetry: retry),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            HomeGreeting(
              onSearch: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              ),
            ),
            ChampionHeroCard(champion: championOfTheDay!),
            if (patchNotes != null) ...[
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PatchNotesCard(notes: patchNotes!),
              ),
            ],
            const SizedBox(height: 26),
            _SectionTitle(
              'Par rôle',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RolesPage()),
              ),
            ),
            const SizedBox(height: 11),
            RoleScroller(champions: champions),
            const SizedBox(height: 24),
            const _SectionTitle('Histoires à lire'),
            const SizedBox(height: 11),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: StoryList(stories: storyPicks),
            ),
            const SizedBox(height: 24),
            const _SectionTitle('Quiz du jour'),
            const SizedBox(height: 11),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DailyQuizCard(champions: champions),
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

  /// Quand elle est fournie, le titre devient cliquable et une flèche l'indique.
  final VoidCallback? onTap;

  const _SectionTitle(this.label, {this.onTap});

  @override
  Widget build(BuildContext context) {
    final title = Text(
      label,
      style: TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: onTap == null
          ? title
          : GestureDetector(
              onTap: onTap,
              child: Row(
                children: [
                  title,
                  const SizedBox(width: 5),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
    );
  }
}
