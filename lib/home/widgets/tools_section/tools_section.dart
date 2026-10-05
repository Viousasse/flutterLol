import 'package:flutter/material.dart';

import '../../../builds/builds_page.dart';
import '../../../compare/compare_page.dart';
import '../../../counters/counters_page.dart';
import '../../../team/team_page.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

class _Tool {
  final IconData icon;
  final String label;
  final String hint;
  final WidgetBuilder page;

  const _Tool({
    required this.icon,
    required this.label,
    required this.hint,
    required this.page,
  });
}

final _tools = <_Tool>[
  _Tool(
    icon: Icons.person_search,
    label: 'Contre-picks',
    hint: 'Qui jouer contre lui ?',
    page: (context) => const CountersPage(),
  ),
  _Tool(
    icon: Icons.groups_outlined,
    label: 'Composition',
    hint: 'Équilibrer son équipe',
    page: (context) => const TeamPage(),
  ),
  _Tool(
    icon: Icons.compare_arrows,
    label: 'Comparer',
    hint: 'Deux champions, un niveau',
    page: (context) => const ComparePage(),
  ),
  _Tool(
    icon: Icons.construction,
    label: 'Mes builds',
    hint: 'Objets et statistiques',
    page: (context) => const BuildsPage(),
  ),
];

/// Raccourcis vers les outils de l'application, en deux colonnes.
class ToolsSection extends StatelessWidget {
  const ToolsSection({super.key});

  static const _spacing = 10.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - _spacing) / 2;

        return Wrap(
          spacing: _spacing,
          runSpacing: _spacing,
          children: [
            for (final tool in _tools)
              SizedBox(
                width: tileWidth,
                child: _ToolTile(
                  tool: tool,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: tool.page),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ToolTile extends StatelessWidget {
  final _Tool tool;
  final VoidCallback onTap;

  const _ToolTile({required this.tool, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${tool.label}, ${tool.hint}',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(tool.icon, size: 22, color: AppColors.accent),
              const SizedBox(height: 10),
              Text(tool.label, style: AppTheme.serif(size: 16)),
              const SizedBox(height: 2),
              Text(
                tool.hint,
                style: AppTheme.serif(
                  size: 12,
                  italic: true,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
