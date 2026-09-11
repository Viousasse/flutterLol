import 'package:flutter/material.dart';
import 'models/item.dart';
import 'services/item_service.dart';
import 'widgets/item_card/item_card.dart';
import 'widgets/items_search_bar/items_search_bar.dart';
import 'widgets/item_tier_bar/item_tier_bar.dart';
import 'widgets/item_sort_button/item_sort_button.dart';
import 'widgets/item_detail_sheet/item_detail_sheet.dart';
import '../theme/app_colors.dart';
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
  String query = '';
  ItemTier? selectedTier;
  ItemSort sort = ItemSort.name;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    final result = await ItemService.fetchAll();
    setState(() {
      allItems = result;
      filteredItems = result;
      isLoading = false;
    });
  }

  void applyFilters() {
    var list = allItems.where((i) {
      final matchesQuery =
          i.name.toLowerCase().contains(query.toLowerCase());
      final matchesTier = selectedTier == null || i.tier == selectedTier;
      return matchesQuery && matchesTier;
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
                    childAspectRatio: 0.72,
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
