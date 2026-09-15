import 'package:flutter/material.dart';
import '../../../shared/widgets/remote_image/remote_image.dart';
import '../../constants/map_landmarks.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../map_landmark_marker/map_landmark_marker.dart';

class SummonersRiftMap extends StatelessWidget {
  final String imageUrl;
  final List<MapLandmark> landmarks;
  final MapLandmark? selectedLandmark;
  final ValueChanged<MapLandmark> onSelect;
  final VoidCallback onClearSelection;
  final ValueChanged<Offset>? onTapPosition;

  const SummonersRiftMap({
    super.key,
    required this.imageUrl,
    required this.landmarks,
    required this.selectedLandmark,
    required this.onSelect,
    required this.onClearSelection,
    this.onTapPosition,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: LayoutBuilder(builder: _buildLayers),
        ),
      ),
    );
  }

  Widget _buildLayers(BuildContext context, BoxConstraints constraints) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTapDown: (details) => _reportTap(details, constraints),
            onTap: onClearSelection,
            child: RemoteImage(
              url: imageUrl,
              errorWidget: const _MapUnavailable(),
            ),
          ),
        ),
        ...landmarks.map((landmark) {
          return _position(landmark, constraints);
        }),
      ],
    );
  }

  /// La position locale d'un appui est déjà exprimée dans le repère de
  /// l'image, sans la transformation du zoom : la fraction reste donc juste
  /// quelle que soit l'échelle courante.
  void _reportTap(TapDownDetails details, BoxConstraints constraints) {
    final report = onTapPosition;
    if (report == null) return;

    report(
      Offset(
        details.localPosition.dx / constraints.maxWidth,
        details.localPosition.dy / constraints.maxHeight,
      ),
    );
  }

  /// Le point du marqueur est centré horizontalement et posé tout en haut, on
  /// le recale donc sur la coordonnée exacte au lieu de centrer le bloc entier,
  /// sinon l'étiquette décale la pastille vers le haut.
  Widget _position(MapLandmark landmark, BoxConstraints constraints) {
    return Positioned(
      left: landmark.x * constraints.maxWidth - MapLandmarkMarker.width / 2,
      top: landmark.y * constraints.maxHeight - MapLandmarkMarker.dotRadius,
      child: MapLandmarkMarker(
        landmark: landmark,
        selected: identical(landmark, selectedLandmark),
        onTap: () => onSelect(landmark),
      ),
    );
  }
}

class _MapUnavailable extends StatelessWidget {
  const _MapUnavailable();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      alignment: Alignment.center,
      child: Text(
        'Carte indisponible',
        style: AppTheme.mono(size: 11, color: AppColors.textMuted),
      ),
    );
  }
}
