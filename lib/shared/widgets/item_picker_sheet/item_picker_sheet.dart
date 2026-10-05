import 'package:flutter/material.dart';

import '../../../items/models/item.dart';
import '../../text/search_text.dart';
import '../remote_image/remote_image.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

/// Feuille de choix d'un objet : une recherche et la liste de la boutique.
class ItemPickerSheet extends StatefulWidget {
  final List<Item> items;

  const ItemPickerSheet({super.key, required this.items});

  static Future<Item?> show(BuildContext context, {required List<Item> items}) {
    return showModalBottomSheet<Item>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ItemPickerSheet(items: items),
    );
  }

  @override
  State<ItemPickerSheet> createState() => _ItemPickerSheetState();
}

class _ItemPickerSheetState extends State<ItemPickerSheet> {
  String query = '';

  List<Item> get _matches {
    final normalizedQuery = normalizeSearchText(query);

    return widget.items
        .where((item) => normalizeSearchText(item.name).contains(normalizedQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final matches = _matches;
    final height = MediaQuery.sizeOf(context).height * 0.8;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: TextField(
                autofocus: true,
                onChanged: (value) => setState(() => query = value),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14.5,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, size: 18),
                  hintText: 'Rechercher un objet',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  border: InputBorder.none,
                ),
              ),
            ),
            Expanded(
              child: matches.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun objet ne correspond.',
                        style: AppTheme.serif(
                          size: 15,
                          color: AppColors.textMuted,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final item = matches[index];

                        return ListTile(
                          onTap: () => Navigator.pop(context, item),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: RemoteImage(
                              url: item.imageUrl,
                              width: 40,
                              height: 40,
                            ),
                          ),
                          title: Text(item.name, style: AppTheme.serif(size: 16)),
                          trailing: Text(
                            '${item.gold}',
                            style: AppTheme.mono(
                              size: 11,
                              color: AppColors.accent,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
