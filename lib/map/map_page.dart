import 'package:flutter/material.dart';
import '../data_dragon/data_dragon_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'constants/map_landmarks.dart';
import 'widgets/map_landmark_details/map_landmark_details.dart';
import 'widgets/map_type_bar/map_type_bar.dart';
import 'widgets/summoners_rift_map/summoners_rift_map.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const _summonersRiftMapId = '11';

  late final Future<String> _version = DataDragonService.latestVersion();

  LandmarkType? selectedType;
  MapLandmark? selectedLandmark;
  bool calibrating = false;
  Offset? tappedPoint;

  List<MapLandmark> get _visibleLandmarks {
    final type = selectedType;
    if (type == null) return summonersRiftLandmarks;

    return summonersRiftLandmarks.where((l) => l.type == type).toList();
  }

  void _selectLandmark(MapLandmark landmark) {
    setState(() {
      selectedLandmark = identical(landmark, selectedLandmark) ? null : landmark;
    });
  }

  void _clearSelection() {
    if (calibrating || selectedLandmark == null) return;

    setState(() {
      selectedLandmark = null;
    });
  }

  void _toggleCalibration() {
    setState(() {
      calibrating = !calibrating;
      tappedPoint = null;
      selectedLandmark = null;
    });
  }

  void _reportTap(Offset point) {
    if (!calibrating) return;

    setState(() {
      tappedPoint = point;
    });
  }

  /// Changer de famille masque des points : celui qui était sélectionné peut
  /// disparaître de la carte, on le désélectionne plutôt que d'afficher une
  /// fiche sans marqueur correspondant.
  void _selectType(LandmarkType? type) {
    setState(() {
      selectedType = type;
      selectedLandmark = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Carte', style: AppTheme.serif(size: 32)),
                GestureDetector(
                  onTap: _toggleCalibration,
                  child: Text(
                    calibrating
                        ? 'calibrage'
                        : '${_visibleLandmarks.length} lieux',
                    style: AppTheme.mono(
                      color:
                          calibrating ? AppColors.accent : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Faille de l'invocateur",
              style: AppTheme.mono(color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            MapTypeBar(selectedType: selectedType, onSelect: _selectType),
            const SizedBox(height: 12),
            FutureBuilder<String>(future: _version, builder: _buildMap),
            const SizedBox(height: 8),
            Text(
              'Pincez pour zoomer.',
              style: AppTheme.mono(size: 9, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            if (calibrating)
              _CalibrationPanel(point: tappedPoint)
            else
              MapLandmarkDetails(landmark: selectedLandmark),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(BuildContext context, AsyncSnapshot<String> snapshot) {
    if (snapshot.hasError) {
      return const _MapPlaceholder(message: 'Chargement impossible');
    }

    final version = snapshot.data;
    if (version == null) {
      return const _MapPlaceholder(message: 'Chargement…');
    }

    return SummonersRiftMap(
      imageUrl: DataDragonService.mapImageUrl(version, _summonersRiftMapId),
      landmarks: _visibleLandmarks,
      selectedLandmark: selectedLandmark,
      onSelect: _selectLandmark,
      onClearSelection: _clearSelection,
      onTapPosition: _reportTap,
    );
  }
}

/// Affiche les coordonnées relatives d'un appui, pour replacer un lieu sans
/// tâtonner : on touche l'endroit voulu sur la carte et on recopie les deux
/// nombres dans map_landmarks.dart.
class _CalibrationPanel extends StatelessWidget {
  final Offset? point;

  const _CalibrationPanel({required this.point});

  @override
  Widget build(BuildContext context) {
    final tapped = point;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Calibrage', style: AppTheme.serif(size: 16)),
          const SizedBox(height: 6),
          Text(
            tapped == null
                ? 'Touchez un endroit de la carte pour lire ses coordonnées.'
                : 'x: ${tapped.dx.toStringAsFixed(3)}   '
                    'y: ${tapped.dy.toStringAsFixed(3)}',
            style: AppTheme.mono(size: 12, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  final String message;

  const _MapPlaceholder({required this.message});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          message,
          style: AppTheme.mono(size: 11, color: AppColors.textMuted),
        ),
      ),
    );
  }
}
