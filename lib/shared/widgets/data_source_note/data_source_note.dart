import 'package:flutter/material.dart';

import '../../../matchups/models/matchup.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

/// Dit d'où viennent les chiffres de matchups, toujours avec les mêmes mots :
/// un seul texte pour tous les écrans évite qu'ils se contredisent.
class DataSourceNote extends StatelessWidget {
  final MatchupDataset dataset;

  const DataSourceNote({super.key, required this.dataset});

  /// Le fichier de données ne contient que des parties Master+ d'EUW.
  static const _scope = 'classées Master+ (EUW)';

  static const emptyText = 'Aucune donnée de matchups disponible.';

  /// Texte affiché, public pour que les tests et les partages le réutilisent.
  static String textFor(MatchupDataset dataset) {
    final patch = dataset.patch;
    if (dataset.matches == 0 || patch == null || patch.isEmpty) {
      return emptyText;
    }

    // Une plage (« 16.16–16.19 ») demande le pluriel, un patch seul non.
    final isRange = patch.contains('–') || patch.contains('-');
    final label = isRange ? 'patchs' : 'patch';
    final games = dataset.matches == 1 ? 'partie' : 'parties';

    return 'Données : ${_groupThousands(dataset.matches)} $games $_scope, '
        '$label $patch.';
  }

  /// Espace insécable comme séparateur : « 7 600 » ne se coupe jamais en fin
  /// de ligne.
  static String _groupThousands(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[index]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final text = textFor(dataset);

    return Semantics(
      label: text,
      excludeSemantics: true,
      child: Text(
        text,
        style: AppTheme.serif(size: 12, color: AppColors.textMuted),
      ),
    );
  }
}
