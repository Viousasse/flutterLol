import 'package:flutter/material.dart';

import '../../../champions/models/champion.dart';
import '../../../shared/widgets/remote_image/remote_image.dart';
import '../../../theme/app_colors.dart';

/// La rangée de bannissements d'un camp : un carré par ban, rempli par
/// l'icône du champion écarté, barrée pour qu'on ne la prenne pas pour un
/// choix. Quand [onTap] est fourni, la première case libre invite à bannir.
class BanRow extends StatelessWidget {
  final String owner;
  final List<Champion?> bans;
  final VoidCallback? onTap;

  const BanRow({
    super.key,
    required this.owner,
    required this.bans,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (bans.isEmpty) return const SizedBox.shrink();

    final firstFree = bans.indexOf(null);
    final names = [for (final ban in bans) ban?.name ?? 'libre'];

    return Semantics(
      button: onTap != null,
      label: 'Bannissements de $owner : ${names.join(', ')}',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              for (var index = 0; index < bans.length; index++) ...[
                if (index > 0) const SizedBox(width: 4),
                Expanded(
                  child: _BanCell(
                    champion: bans[index],
                    invite: onTap != null && index == firstFree,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BanCell extends StatelessWidget {
  final Champion? champion;
  final bool invite;

  const _BanCell({required this.champion, required this.invite});

  @override
  Widget build(BuildContext context) {
    final banned = champion;

    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: invite ? AppColors.accent : AppColors.border,
          ),
        ),
        child: banned == null
            ? Icon(
                invite ? Icons.block : Icons.remove,
                size: 14,
                color: invite ? AppColors.accent : AppColors.textMuted,
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        0.2126, 0.7152, 0.0722, 0, 0, //
                        0.2126, 0.7152, 0.0722, 0, 0, //
                        0.2126, 0.7152, 0.0722, 0, 0, //
                        0, 0, 0, 1, 0, //
                      ]),
                      child: RemoteImage(url: banned.imageUrl),
                    ),
                    Center(
                      child: Icon(
                        Icons.block,
                        size: 20,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
