import 'package:flutter/material.dart';

import '../champions/models/champion.dart';
import '../champions/services/champion_service.dart';
import '../items/models/item.dart';
import '../items/services/item_service.dart';
import '../shared/errors/user_message.dart';
import '../shared/services/clipboard_copy/clipboard_copy.dart';
import '../shared/widgets/error_retry_view/error_retry_view.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'build_editor_page.dart';
import 'models/build.dart';
import 'services/build_share_text.dart';
import 'services/build_store.dart';
import 'widgets/build_tile/build_tile.dart';

/// Les builds que le joueur a enregistrées.
class BuildsPage extends StatefulWidget {
  const BuildsPage({super.key});

  @override
  State<BuildsPage> createState() => _BuildsPageState();
}

class _BuildsPageState extends State<BuildsPage> {
  List<Item> allItems = const [];
  List<Champion> champions = const [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final itemsRequest = ItemService.fetchAll();
      final championsRequest = ChampionService.fetchAll();
      final storeRequest = BuildStore.ensureLoaded();

      final loadedItems = await itemsRequest;
      final loadedChampions = await championsRequest;
      await storeRequest;

      if (!mounted) return;
      setState(() {
        allItems = loadedItems;
        champions = loadedChampions;
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

  void openEditor({Build? build}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BuildEditorPage(build: build)),
    );
  }

  List<Item> _itemsOf(Build build) {
    final byId = {for (final item in allItems) item.id: item};

    return [for (final id in build.itemIds) ?byId[id]];
  }

  String? _championNameOf(Build build) {
    for (final champion in champions) {
      if (champion.id == build.championId) return champion.name;
    }

    return null;
  }

  Future<void> confirmDelete(Build build) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Supprimer cette build ?', style: AppTheme.serif(size: 20)),
        content: Text(
          '« ${build.name} » sera définitivement supprimée.',
          style: AppTheme.serif(size: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer la build'),
          ),
        ],
      ),
    );

    if (confirmed == true) await BuildStore.delete(build.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mes builds', style: AppTheme.serif(size: 24))),
      floatingActionButton: isLoading || errorMessage != null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => openEditor(),
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.background,
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle build'),
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

    return ValueListenableBuilder<List<Build>>(
      valueListenable: BuildStore.builds,
      builder: (context, builds, _) {
        if (builds.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                "Aucune build pour l'instant. Composez-en une avec le bouton "
                'ci-dessous.',
                textAlign: TextAlign.center,
                style: AppTheme.serif(size: 15, color: AppColors.textMuted),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
          itemCount: builds.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final build = builds[index];

            return BuildTile(
              savedBuild: build,
              items: _itemsOf(build),
              championName: _championNameOf(build),
              onTap: () => openEditor(build: build),
              onDelete: () => confirmDelete(build),
              onShare: () => copyToClipboard(
                context,
                BuildShareText.of(build, _itemsOf(build), _championNameOf(build)),
                message: 'Résumé de la build copié',
              ),
            );
          },
        );
      },
    );
  }
}
