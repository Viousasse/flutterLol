import 'package:flutter/material.dart';
import '../champions/models/champion.dart';
import '../champions/services/champion_service.dart';
import '../champions/services/favorites_service.dart';
import '../champions/widgets/champion_card/champion_card.dart';
import '../shared/errors/user_message.dart';
import '../shared/widgets/error_retry_view/error_retry_view.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Champion> allChampions = const [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadChampions();
  }

  Future<void> loadChampions() async {
    try {
      final champions = await ChampionService.fetchAll();
      await FavoritesService.ensureLoaded();

      if (!mounted) return;
      setState(() {
        allChampions = champions;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoris', style: AppTheme.serif(size: 24)),
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

    // La liste se recompose dès qu'un favori change, y compris quand il est
    // retiré depuis la fiche d'un champion ouverte par-dessus.
    return ValueListenableBuilder<Set<String>>(
      valueListenable: FavoritesService.favorites,
      builder: (context, favoriteIds, _) {
        final favoriteChampions = allChampions
            .where((c) => favoriteIds.contains(c.id))
            .toList();

        if (favoriteChampions.isEmpty) {
          return Center(
            child: Text(
              'Aucun champion favori pour le moment',
              style: AppTheme.serif(size: 15, color: AppColors.textMuted),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.82,
          ),
          itemCount: favoriteChampions.length,
          itemBuilder: (context, index) {
            return ChampionCard(champion: favoriteChampions[index]);
          },
        );
      },
    );
  }
}
