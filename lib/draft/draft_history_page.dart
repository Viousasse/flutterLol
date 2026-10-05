import 'package:flutter/material.dart';

import '../champions/models/champion.dart';
import '../champions/services/champion_service.dart';
import '../shared/errors/user_message.dart';
import '../shared/services/clipboard_copy/clipboard_copy.dart';
import '../shared/widgets/error_retry_view/error_retry_view.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'models/draft_record.dart';
import 'services/draft_history_stats.dart';
import 'services/draft_history_store.dart';
import 'services/draft_share_text.dart';
import 'widgets/draft_history_tile/draft_history_tile.dart';
import 'widgets/draft_stats_card/draft_stats_card.dart';

/// Les drafts déjà jouées, avec le bilan contre le site et les champions les
/// plus choisis.
class DraftHistoryPage extends StatefulWidget {
  const DraftHistoryPage({super.key});

  @override
  State<DraftHistoryPage> createState() => _DraftHistoryPageState();
}

class _DraftHistoryPageState extends State<DraftHistoryPage> {
  Map<String, String> imageUrls = const {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final storeRequest = DraftHistoryStore.ensureLoaded();
      final champions = await ChampionService.fetchAll();
      await storeRequest;

      if (!mounted) return;
      setState(() {
        imageUrls = {
          for (final Champion champion in champions)
            champion.id: champion.imageUrl,
        };
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

  Future<void> confirmDelete(DraftRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Supprimer cette draft ?', style: AppTheme.serif(size: 20)),
        content: Text(
          '« ${record.blueName} contre ${record.redName} » sera définitivement '
          'supprimée de l’historique.',
          style: AppTheme.serif(size: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer la draft'),
          ),
        ],
      ),
    );

    if (confirmed == true) await DraftHistoryStore.delete(record.id);
  }

  Future<void> confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Vider l’historique ?', style: AppTheme.serif(size: 20)),
        content: Text(
          'Toutes les drafts enregistrées seront définitivement supprimées.',
          style: AppTheme.serif(size: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tout supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) await DraftHistoryStore.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des drafts', style: AppTheme.serif(size: 24)),
        actions: [
          ValueListenableBuilder<List<DraftRecord>>(
            valueListenable: DraftHistoryStore.records,
            builder: (context, records, _) => records.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Vider l’historique',
                    onPressed: confirmClear,
                    icon: const Icon(Icons.delete_sweep_outlined),
                  ),
          ),
        ],
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

    return ValueListenableBuilder<List<DraftRecord>>(
      valueListenable: DraftHistoryStore.records,
      builder: (context, records, _) {
        if (records.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Aucune draft pour l’instant. Jouez-en une avec l’entraîneur '
                'de draft : elle apparaîtra ici dès qu’elle sera jugée.',
                textAlign: TextAlign.center,
                style: AppTheme.serif(size: 15, color: AppColors.textMuted),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          itemCount: records.length + 1,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index == 0) {
              return DraftStatsCard(
                stats: DraftHistoryStats.of(records),
                imageUrls: imageUrls,
              );
            }

            final record = records[index - 1];

            return DraftHistoryTile(
              record: record,
              imageUrls: imageUrls,
              onShare: () => copyToClipboard(
                context,
                DraftShareText.of(record),
                message: 'Résumé de la draft copié',
              ),
              onDelete: () => confirmDelete(record),
            );
          },
        );
      },
    );
  }
}
