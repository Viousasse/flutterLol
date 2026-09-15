import 'package:flutter/material.dart';
import 'models/item.dart';
import 'models/item_profile.dart';
import 'services/item_service.dart';
import 'widgets/item_card/item_card.dart';
import 'widgets/items_search_bar/items_search_bar.dart';
import 'widgets/item_tier_bar/item_tier_bar.dart';
import 'widgets/item_profile_bar/item_profile_bar.dart';
import 'widgets/item_sort_button/item_sort_button.dart';
import 'widgets/item_detail_sheet/item_detail_sheet.dart';
import '../shared/errors/user_message.dart';
import '../shared/widgets/error_retry_view/error_retry_view.dart';
import '../theme/app_theme.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  List<Item> allItems = [];
  List<Item> filteredItems = [];
  bool isLoading = true;
  String? errorMessage;
  String query = '';
  ItemTier? selectedTier;
  ItemProfile? selectedProfile;
  ItemSort sort = ItemSort.name;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      final result = await ItemService.fetchAll();
      if (!mounted) return;
      setState(() {
        allItems = result;
        filteredItems = result;
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

  void applyFilters() {
    final lowerCaseQuery = query.toLowerCase();

    var list = allItems.where((item) {
      final matchesQuery = item.name.toLowerCase().contains(lowerCaseQuery);
      final matchesTier = selectedTier == null || item.tier == selectedTier;
      final matchesProfile =
          selectedProfile == null || item.profile == selectedProfile;

      return matchesQuery && matchesTier && matchesProfile;
    }).toList();

    switch (sort) {
      case ItemSort.name:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case ItemSort.priceAsc:
        list.sort((a, b) => a.gold.compareTo(b.gold));
        break;
      case ItemSort.priceDesc:
        list.sort((a, b) => b.gold.compareTo(a.gold));
        break;
    }

    setState(() {
      filteredItems = list;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Objets', style: AppTheme.serif(size: 32)),
                  ItemSortButton(
                    current: sort,
                    onChanged: (s) {
                      sort = s;
                      applyFilters();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ItemsSearchBar(
                onChanged: (value) {
                  query = value;
                  applyFilters();
                },
              ),
              const SizedBox(height: 12),
              ItemProfileBar(
                selectedProfile: selectedProfile,
                onSelect: (profile) {
                  selectedProfile = profile;
                  applyFilters();
                },
              ),
              const SizedBox(height: 8),
              ItemTierBar(
                selectedTier: selectedTier,
                onSelect: (tier) {
                  selectedTier = tier;
                  applyFilters();
                },
              ),
              const SizedBox(height: 14),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    // Assez haut pour un nom sur deux lignes jusqu'à 360px de
                    // large, sans quoi la deuxième ligne est rognée.
                    childAspectRatio: 0.66,
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return ItemCard(
                      item: item,
                      onTap: () => ItemDetailSheet.show(context, item),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
