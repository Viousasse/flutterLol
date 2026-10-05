import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

class HomeGreeting extends StatelessWidget {
  final VoidCallback onSearch;

  const HomeGreeting({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final weekdays = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];
    final dateLabel = weekdays[DateTime.now().weekday - 1];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateLabel,
                  style: AppTheme.mono(color: AppColors.textMuted),
                ),
                const SizedBox(height: 9),
                Text('Bonjour,\ninvocateur', style: AppTheme.serif(size: 30)),
              ],
            ),
          ),
          IconButton(
            onPressed: onSearch,
            tooltip: 'Rechercher un champion ou un objet',
            icon: const Icon(Icons.search, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
