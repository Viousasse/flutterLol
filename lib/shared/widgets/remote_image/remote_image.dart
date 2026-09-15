import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// Image servie par Riot, gardée sur le disque après le premier chargement.
///
/// Toutes les illustrations passent par ici pour trois raisons : le cache évite
/// de retélécharger la même icône à chaque défilement, le fond de remplacement
/// évite le clignotement blanc pendant le chargement, et un lien mort tombe sur
/// un visuel discret au lieu du bloc d'erreur de Flutter.
class RemoteImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  /// Affiché à la place de l'image si Riot ne la sert pas.
  final Widget? errorWidget;

  const RemoteImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (context, url) => _Backdrop(width: width, height: height),
      errorWidget: (context, url, error) =>
          errorWidget ?? _Backdrop(width: width, height: height),
    );
  }
}

class _Backdrop extends StatelessWidget {
  final double? width;
  final double? height;

  const _Backdrop({this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(width: width, height: height, color: AppColors.surface);
  }
}
