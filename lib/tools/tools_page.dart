import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'widgets/tools_section/tools_section.dart';

/// L'onglet des outils : contre-picks, composition d'équipe, comparaison de
/// champions et builds.
class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text('Outils', style: AppTheme.serif(size: 32)),
            const SizedBox(height: 4),
            Text(
              'Préparez votre partie',
              style: AppTheme.mono(color: AppColors.textMuted),
            ),
            const SizedBox(height: 18),
            const ToolsSection(),
          ],
        ),
      ),
    );
  }
}
