import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/item.dart';
import '../../models/item_stack.dart';
import '../../services/item_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../item_recipe_section/item_recipe_section.dart';
import 'item_detail_header.dart';

class ItemDetailSheet extends StatefulWidget {
  final Item item;

  const ItemDetailSheet({super.key, required this.item});

  static void show(BuildContext context, Item item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ItemDetailSheet(item: item),
    );
  }

  @override
  State<ItemDetailSheet> createState() => _ItemDetailSheetState();
}

class _ItemDetailSheetState extends State<ItemDetailSheet> {
  late final List<Item> _visitedItems = [widget.item];

  Item get _currentItem => _visitedItems.last;

  bool get _canGoBack => _visitedItems.length > 1;

  void _open(Item item) {
    setState(() {
      _visitedItems.add(item);
    });
  }

  void _goBack() {
    setState(() {
      _visitedItems.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.8;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _DragHandle(),
              const SizedBox(height: 14),
              ItemDetailHeader(
                item: _currentItem,
                onBack: _canGoBack ? _goBack : null,
              ),
              const SizedBox(height: 16),
              Text(
                _currentItem.description,
                style: GoogleFonts.instrumentSans(
                  fontSize: 13.5,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              ..._buildRecipeSections(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRecipeSections() {
    final components = ItemService.componentsOf(_currentItem);
    final upgrades = ItemService.upgradesOf(_currentItem);
    final finalBuilds = ItemService.finalBuildsOf(_currentItem);

    return [
      if (components.isNotEmpty) ...[
        const SizedBox(height: 20),
        ItemRecipeSection(
          title: 'Se compose de',
          stacks: components,
          onSelect: _open,
        ),
      ],
      if (upgrades.isNotEmpty) ...[
        const SizedBox(height: 20),
        ItemRecipeSection(
          title: 'Permet de construire',
          stacks: upgrades,
          onSelect: _open,
        ),
      ],
      if (_hasDeeperBuildPath(upgrades, finalBuilds)) ...[
        const SizedBox(height: 20),
        ItemRecipeSection(
          title: 'Objets finaux atteignables',
          stacks: finalBuilds,
          onSelect: _open,
        ),
      ],
      if (upgrades.isEmpty) ...[
        const SizedBox(height: 20),
        const _FinalItemNotice(),
      ],
    ];
  }

  /// La liste des objets finaux n'est affichée que si elle apporte plus que les
  /// évolutions directes, sinon les deux sections seraient identiques.
  bool _hasDeeperBuildPath(
    List<ItemStack> upgrades,
    List<ItemStack> finalBuilds,
  ) {
    if (finalBuilds.isEmpty) return false;

    final upgradeIds = upgrades.map((stack) => stack.item.id).toSet();

    return finalBuilds.any((stack) => !upgradeIds.contains(stack.item.id));
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 38,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _FinalItemNotice extends StatelessWidget {
  const _FinalItemNotice();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 14,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: 7),
        // Sans Flexible, la phrase déborde la largeur de la fiche sur un
        // téléphone au lieu de passer à la ligne.
        Flexible(
          child: Text(
            'Objet final, il ne se construit pas davantage.',
            style: AppTheme.mono(size: 10, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}
