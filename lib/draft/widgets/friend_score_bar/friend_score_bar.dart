import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../services/friend_session_store.dart';

/// Le score cumulé de la soirée, avec de quoi le remettre à zéro.
class FriendScoreBar extends StatelessWidget {
  final FriendSession session;
  final VoidCallback onReset;

  const FriendScoreBar({
    super.key,
    required this.session,
    required this.onReset,
  });

  String get _tiesLabel =>
      '${session.ties} égalité${session.ties > 1 ? 's' : ''}';

  String get _semanticLabel {
    final players = session.players;
    final ties = session.ties > 0 ? ', $_tiesLabel' : '';

    return 'Score de la soirée : ${players.blue} ${session.blueWins}, '
        '${players.red} ${session.redWins}$ties';
  }

  @override
  Widget build(BuildContext context) {
    final players = session.players;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, right: 4),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              label: _semanticLabel,
              excludeSemantics: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SCORE DE LA SOIRÉE',
                      style: AppTheme.mono(size: 9, color: AppColors.accent),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${players.blue} ${session.blueWins} – '
                      '${session.redWins} ${players.red}',
                      style: AppTheme.serif(size: 18),
                    ),
                    if (session.ties > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        _tiesLabel,
                        style: AppTheme.serif(
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Remettre le score à zéro',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            onPressed: session.isScoreEmpty ? null : onReset,
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
    );
  }
}
