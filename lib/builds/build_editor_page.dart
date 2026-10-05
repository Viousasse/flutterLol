import 'package:flutter/material.dart';

import '../champions/models/champion.dart';
import '../champions/services/champion_service.dart';
import '../shared/widgets/champion_picker_sheet/champion_picker_sheet.dart';
import '../items/models/item.dart';
import '../items/services/item_service.dart';
import '../shared/errors/user_message.dart';
import '../shared/widgets/error_retry_view/error_retry_view.dart';
import '../shared/widgets/remote_image/remote_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'models/build.dart';
import 'services/build_stats.dart';
import 'services/build_store.dart';
import 'widgets/build_slot/build_slot.dart';
import 'widgets/build_stats_panel/build_stats_panel.dart';
import '../shared/widgets/item_picker_sheet/item_picker_sheet.dart';

const _defaultName = 'Ma build';
const _slotColumns = 3;

/// Compose une build : six emplacements, le prix total et les bonus cumulés.
class BuildEditorPage extends StatefulWidget {
  /// Build à modifier, ou `null` pour en créer une.
  final Build? build;

  /// Champion et objets de départ d'une nouvelle build, quand on arrive depuis
  /// les conseils d'une fiche champion.
  final String? initialChampionId;
  final List<String> initialItemIds;

  const BuildEditorPage({
    super.key,
    this.build,
    this.initialChampionId,
    this.initialItemIds = const [],
  });

  @override
  State<BuildEditorPage> createState() => _BuildEditorPageState();
}

class _BuildEditorPageState extends State<BuildEditorPage> {
  late final TextEditingController nameController = TextEditingController(
    text: widget.build?.name ?? '',
  );

  List<Item> allItems = const [];
  List<Champion> champions = const [];
  late final List<String?> slots = _initialSlots();
  late String? championId = widget.build?.championId ?? widget.initialChampionId;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  List<String?> _initialSlots() {
    final ids = widget.build?.itemIds ?? widget.initialItemIds;
    final padded = <String?>[...ids.take(Build.maxItems)];
    while (padded.length < Build.maxItems) {
      padded.add(null);
    }

    return padded;
  }

  Future<void> loadData() async {
    try {
      final itemsRequest = ItemService.fetchAll();
      final championsRequest = ChampionService.fetchAll();

      final loadedItems = await itemsRequest;
      final loadedChampions = await championsRequest;

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

  Item? _itemAt(int index) {
    final id = slots[index];
    if (id == null) return null;

    for (final item in allItems) {
      if (item.id == id) return item;
    }

    return null;
  }

  List<Item> get _chosenItems {
    return [
      for (var index = 0; index < slots.length; index++) ?_itemAt(index),
    ];
  }

  Champion? get _champion {
    for (final champion in champions) {
      if (champion.id == championId) return champion;
    }

    return null;
  }

  Future<void> pickItem(int index) async {
    final item = await ItemPickerSheet.show(context, items: allItems);
    if (item == null || !mounted) return;

    setState(() => slots[index] = item.id);
  }

  Future<void> pickChampion() async {
    final champion = await ChampionPickerSheet.show(
      context,
      champions: champions,
    );
    if (champion == null || !mounted) return;

    setState(() => championId = champion.id);
  }

  Future<void> save() async {
    final name = nameController.text.trim();
    final build = Build(
      id: widget.build?.id ?? BuildStore.newId(),
      name: name.isEmpty ? _defaultName : name,
      championId: championId,
      itemIds: [for (final id in slots) ?id],
    );

    final navigator = Navigator.of(context);
    await BuildStore.save(build);

    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.build == null ? 'Nouvelle build' : 'Modifier la build',
          style: AppTheme.serif(size: 24),
        ),
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

    final chosen = _chosenItems;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        TextField(
          controller: nameController,
          maxLength: 40,
          style: AppTheme.serif(size: 18),
          decoration: const InputDecoration(
            hintText: _defaultName,
            hintStyle: TextStyle(color: AppColors.textMuted),
            labelText: 'Nom de la build',
          ),
        ),
        const SizedBox(height: 10),
        _ChampionRow(
          champion: _champion,
          onPick: pickChampion,
          onClear: () => setState(() => championId = null),
        ),
        const SizedBox(height: 18),
        GridView.count(
          crossAxisCount: _slotColumns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.9,
          children: [
            for (var index = 0; index < Build.maxItems; index++)
              BuildSlot(
                item: _itemAt(index),
                position: index + 1,
                onTap: () => pickItem(index),
                onClear: () => setState(() => slots[index] = null),
              ),
          ],
        ),
        const SizedBox(height: 18),
        BuildStatsPanel(
          totalGold: BuildStats.totalGold(chosen),
          lines: BuildStats.total(chosen),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: chosen.isEmpty ? null : save,
          child: const Text('Enregistrer la build'),
        ),
      ],
    );
  }
}

class _ChampionRow extends StatelessWidget {
  final Champion? champion;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _ChampionRow({
    required this.champion,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final selected = champion;

    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            label: selected == null
                ? 'Choisir un champion pour cette build'
                : 'Champion ${selected.name}, appuyer pour changer',
            excludeSemantics: true,
            onTap: onPick,
            child: GestureDetector(
              onTap: onPick,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    if (selected != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: RemoteImage(
                          url: selected.imageUrl,
                          width: 36,
                          height: 36,
                        ),
                      )
                    else
                      const Icon(
                        Icons.person_add_alt,
                        color: AppColors.accent,
                        size: 22,
                      ),
                    const SizedBox(width: 10),
                    Text(
                      selected?.name ?? 'Choisir un champion (facultatif)',
                      style: AppTheme.serif(
                        size: 15,
                        color: selected == null
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (selected != null)
          IconButton(
            tooltip: 'Retirer le champion',
            onPressed: onClear,
            icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
          ),
      ],
    );
  }
}
