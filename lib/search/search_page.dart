import 'package:flutter/material.dart';

import '../champion_detail/champion_detail_page.dart';
import '../champions/models/champion.dart';
import '../champions/services/champion_service.dart';
import '../items/models/item.dart';
import '../items/services/item_service.dart';
import '../items/widgets/item_detail_sheet/item_detail_sheet.dart';
import '../shared/errors/user_message.dart';
import '../shared/widgets/error_retry_view/error_retry_view.dart';
import '../shared/widgets/remote_image/remote_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'services/global_search.dart';

/// Une seule barre pour retrouver un champion ou un objet, sans savoir dans
/// quel onglet il se trouve.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Champion> champions = const [];
  List<Item> items = const [];
  bool isLoading = true;
  String? errorMessage;
  String query = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final championsRequest = ChampionService.fetchAll();
      final itemsRequest = ItemService.fetchAll();

      final loadedChampions = await championsRequest;
      final loadedItems = await itemsRequest;

      if (!mounted) return;
      setState(() {
        champions = loadedChampions;
        items = loadedItems;
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
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          autofocus: true,
          onChanged: (value) => setState(() => query = value),
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Champion ou objet',
            hintStyle: TextStyle(color: AppColors.textMuted),
            border: InputBorder.none,
          ),
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

    if (query.trim().isEmpty) {
      return const _Hint('Tapez le nom d\'un champion ou d\'un objet.');
    }

    final results = GlobalSearch.run(query, champions: champions, items: items);
    if (results.isEmpty) {
      return const _Hint('Aucun résultat.');
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        if (results.champions.isNotEmpty) ...[
          const _SectionTitle('Champions'),
          for (final champion in results.champions)
            _ResultTile(
              imageUrl: champion.imageUrl,
              title: champion.name,
              subtitle: champion.title,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChampionDetailPage(championId: champion.id),
                ),
              ),
            ),
        ],
        if (results.items.isNotEmpty) ...[
          const _SectionTitle('Objets'),
          for (final item in results.items)
            _ResultTile(
              imageUrl: item.imageUrl,
              title: item.name,
              subtitle: '${item.gold} or',
              onTap: () => ItemDetailSheet.show(context, item),
            ),
        ],
      ],
    );
  }
}

class _Hint extends StatelessWidget {
  final String message;

  const _Hint(this.message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: AppTheme.serif(size: 15, color: AppColors.textMuted),
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
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(label.toUpperCase(), style: AppTheme.mono(size: 10)),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ResultTile({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: RemoteImage(url: imageUrl, width: 44, height: 44),
      ),
      title: Text(title, style: AppTheme.serif(size: 16)),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.serif(
          size: 12,
          italic: true,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
