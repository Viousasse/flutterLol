import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../shimmer_box/shimmer_box.dart';

/// Image servie par Riot, gardée sur le disque après le premier chargement.
///
/// Toutes les illustrations passent par ici pour trois raisons : le cache évite
/// de retélécharger la même icône à chaque défilement, le fond de remplacement
/// évite le clignotement blanc pendant le chargement, et un lien mort tombe sur
/// un visuel discret au lieu du bloc d'erreur de Flutter.
///
/// Sur le web, le cache disque n'a pas de sens — le navigateur a le sien — et
/// le décodage de `cached_network_image` y lève une assertion qui laissait
/// toutes les images en erreur. On passe donc par `Image.network`, qui sait en
/// plus retomber sur un élément `<img>` quand un serveur n'envoie pas de CORS.
class RemoteImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  /// Partie de l'image conservée quand elle est rognée pour remplir son cadre.
  final Alignment alignment;

  /// Description lue par les lecteurs d'écran. Sans elle, l'image est ignorée
  /// : c'est le bon choix pour une illustration purement décorative.
  final String? semanticLabel;

  /// Affiché à la place de l'image si Riot ne la sert pas.
  final Widget? errorWidget;

  const RemoteImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Un fond qui pulse pendant l'attente : une case vide et immobile donne
    // l'impression d'une image cassée quand le réseau est lent.
    final loading = ShimmerBox(width: width, height: height);
    final failed = Container(width: width, height: height, color: AppColors.surface);

    final image = kIsWeb
        ? Image.network(
            url,
            width: width,
            height: height,
            fit: fit,
            alignment: alignment,
            webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : loading,
            errorBuilder: (context, error, stackTrace) =>
                errorWidget ?? failed,
          )
        : CachedNetworkImage(
            imageUrl: url,
            width: width,
            height: height,
            fit: fit,
            alignment: alignment,
            fadeInDuration: const Duration(milliseconds: 150),
            placeholder: (context, url) => loading,
            errorWidget: (context, url, error) => errorWidget ?? failed,
          );

    final label = semanticLabel;
    if (label == null) return ExcludeSemantics(child: image);

    return Semantics(image: true, label: label, child: ExcludeSemantics(child: image));
  }
}
