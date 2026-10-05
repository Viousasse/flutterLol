import 'package:flutter/material.dart';

import '../../../champions/models/champion.dart';
import '../app_filter_chip/app_filter_chip.dart';
import '../remote_image/remote_image.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import 'champion_role_filter.dart';

/// Feuille de choix d'un champion : une recherche et la liste complète.
class ChampionPickerSheet extends StatefulWidget {
  final List<Champion> champions;

  /// Champions déjà placés ailleurs (l'autre côté d'une comparaison, le reste
  /// d'une équipe) : ils ne sont pas proposés une seconde fois.
  final Set<String> excludedIds;

  /// Quand il est fourni, une rangée de puces permet de ne garder que les
  /// champions d'un rôle.
  final ChampionRoleFilter? roleFilter;

  const ChampionPickerSheet({
    super.key,
    required this.champions,
    this.excludedIds = const {},
    this.roleFilter,
  });

  static Future<Champion?> show(
    BuildContext context, {
    required List<Champion> champions,
    Set<String> excludedIds = const {},
    ChampionRoleFilter? roleFilter,
  }) {
    return showModalBottomSheet<Champion>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ChampionPickerSheet(
        champions: champions,
        excludedIds: excludedIds,
        roleFilter: roleFilter,
      ),
    );
  }

  @override
  State<ChampionPickerSheet> createState() => _ChampionPickerSheetState();
}

class _ChampionPickerSheetState extends State<ChampionPickerSheet> {
  String query = '';

  /// Voie retenue par le filtre de rôle, ou `null` pour tous les champions.
  late String? lane = widget.roleFilter?.initialLane;

  List<Champion> get _matches {
    final lowerCaseQuery = query.toLowerCase();
    final filter = widget.roleFilter;
    final selectedLane = lane;

    return widget.champions
        .where(
          (champion) =>
              !widget.excludedIds.contains(champion.id) &&
              champion.name.toLowerCase().contains(lowerCaseQuery) &&
              (filter == null ||
                  selectedLane == null ||
                  filter.fits(champion.id, selectedLane)),
        )
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
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14.5),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, size: 18),
                  hintText: 'Rechercher un champion',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  border: InputBorder.none,
                ),
              ),
            ),
            if (widget.roleFilter case final filter?)
              _RoleChips(
                filter: filter,
                selectedLane: lane,
                onSelect: (value) => setState(() => lane = value),
              ),
            Expanded(
              child: matches.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun champion ne correspond.',
                        style: AppTheme.serif(
                          size: 15,
                          color: AppColors.textMuted,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final champion = matches[index];

                        return ListTile(
                          onTap: () => Navigator.pop(context, champion),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: RemoteImage(
                              url: champion.imageUrl,
                              width: 40,
                              height: 40,
                            ),
                          ),
                          title: Text(
                            champion.name,
                            style: AppTheme.serif(size: 16),
                          ),
                          subtitle: Text(
                            champion.title,
                            style: AppTheme.serif(
                              size: 12,
                              italic: true,
                              color: AppColors.textSecondary,
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

/// La rangée de puces des rôles, défilante pour tenir sur un petit écran.
class _RoleChips extends StatelessWidget {
  final ChampionRoleFilter filter;
  final String? selectedLane;
  final ValueChanged<String?> onSelect;

  const _RoleChips({
    required this.filter,
    required this.selectedLane,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        // Pas de marge verticale : les puces prennent les 44 px de la rangée
        // comme zone tactile, la pastille visible reste de 32 px.
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _chip('Tous', null),
          for (final entry in filter.roles.entries)
            _chip(entry.key, entry.value),
        ],
      ),
    );
  }

  Widget _chip(String label, String? lane) {
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: AppFilterChip(
        label: label,
        selected: selectedLane == lane,
        onTap: () => onSelect(lane),
      ),
    );
  }
}
