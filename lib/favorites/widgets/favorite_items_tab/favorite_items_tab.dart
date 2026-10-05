import 'package:flutter/material.dart';

import '../../../items/models/item.dart';
import '../../../items/services/item_favorites_service.dart';
import '../../../items/services/item_service.dart';
import '../../../items/widgets/item_card/item_card.dart';
import '../../../items/widgets/item_detail_sheet/item_detail_sheet.dart';
import '../../../shared/errors/user_message.dart';
import '../../../shared/widgets/error_retry_view/error_retry_view.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

class FavoriteItemsTab extends StatefulWidget {
  const FavoriteItemsTab({super.key});

  @override
  State<FavoriteItemsTab> createState() => _FavoriteItemsTabState();
}

class _FavoriteItemsTabState extends State<FavoriteItemsTab> {
  List<Item> allItems = const [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      final items = await ItemService.fetchAll();
      await ItemFavoritesService.ensureLoaded();

      if (!mounted) return;
      setState(() {
        allItems = items;
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
    loadItems();
  }

  @override
  Widget build(BuildContext context) {
    final failure = errorMessage;
    if (failure != null) {
      return ErrorRetryView(message: failure, onRetry: retry);
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ValueListenableBuilder<Set<String>>(
      valueListenable: ItemFavoritesService.favorites,
      builder: (context, favoriteIds, _) {
        final favoriteItems = allItems
            .where((item) => favoriteIds.contains(item.id))
            .toList();

        if (favoriteItems.isEmpty) {
          return Center(
            child: Text(
              'Aucun objet favori pour le moment',
              style: AppTheme.serif(size: 15, color: AppColors.textMuted),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.66,
          ),
          itemCount: favoriteItems.length,
          itemBuilder: (context, index) {
            final item = favoriteItems[index];

            return ItemCard(
              item: item,
              onTap: () => ItemDetailSheet.show(context, item),
            );
          },
        );
      },
    );
  }
}
