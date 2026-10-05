import 'package:flutter/material.dart';

import '../../../builds/models/build.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

/// Liste des builds enregistrées, pour en équiper une à un champion comparé.
class SavedBuildPickerSheet extends StatelessWidget {
  final List<Build> builds;

  const SavedBuildPickerSheet({super.key, required this.builds});

  static Future<Build?> show(
    BuildContext context, {
    required List<Build> builds,
  }) {
    return showModalBottomSheet<Build>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SavedBuildPickerSheet(builds: builds),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.6;

    return SizedBox(
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Mes builds', style: AppTheme.serif(size: 20)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: builds.length,
              itemBuilder: (context, index) {
                final build = builds[index];

                return ListTile(
                  onTap: () => Navigator.pop(context, build),
                  title: Text(build.name, style: AppTheme.serif(size: 16)),
                  subtitle: Text(
                    '${build.itemIds.length} objet'
                    '${build.itemIds.length > 1 ? 's' : ''}',
                    style: AppTheme.mono(size: 10, color: AppColors.textMuted),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
