import 'package:flutter/material.dart';

import '../../../champions/models/champion_skin.dart';
import '../../../shared/widgets/remote_image/remote_image.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../skin_viewer_page.dart';

/// Défilement horizontal des apparences d'un champion. Un appui ouvre
/// l'illustration en grand.
class SkinGallery extends StatelessWidget {
  static const _tileWidth = 120.0;
  static const _tileHeight = 190.0;

  final List<ChampionSkin> skins;

  const SkinGallery({super.key, required this.skins});

  void _open(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SkinViewerPage(skins: skins, initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _tileHeight + 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: skins.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final skin = skins[index];

          return Semantics(
            button: true,
            label: 'Voir ${skin.name} en grand',
            excludeSemantics: true,
            onTap: () => _open(context, index),
            child: GestureDetector(
              onTap: () => _open(context, index),
              child: SizedBox(
                width: _tileWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: RemoteImage(
                        url: skin.loadingUrl,
                        width: _tileWidth,
                        height: _tileHeight,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      skin.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.serif(
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
