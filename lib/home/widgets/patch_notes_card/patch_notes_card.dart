import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../patch_notes/models/patch_notes.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

/// Carte du dernier patch : son numéro et un lien vers les notes officielles.
class PatchNotesCard extends StatelessWidget {
  final PatchNotes notes;

  const PatchNotesCard({super.key, required this.notes});

  Future<void> _open(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final opened = await launchUrl(
      Uri.parse(notes.url),
      mode: LaunchMode.externalApplication,
    );

    if (opened) return;
    messenger.showSnackBar(
      const SnackBar(content: Text("Impossible d'ouvrir les notes de patch.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Lire les notes du patch ${notes.label}',
      excludeSemantics: true,
      onTap: () => _open(context),
      child: GestureDetector(
        onTap: () => _open(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DERNIER PATCH',
                      style: AppTheme.mono(size: 9, color: AppColors.accent),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Notes de patch ${notes.label}',
                      style: AppTheme.serif(size: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Champions, objets et équilibrage, sur le site officiel.',
                      style: AppTheme.serif(
                        size: 12,
                        italic: true,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.open_in_new, size: 18, color: AppColors.accent),
            ],
          ),
        ),
      ),
    );
  }
}
