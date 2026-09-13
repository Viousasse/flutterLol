import 'package:flutter/material.dart';
import '../data_dragon/data_dragon_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'constants/map_landmarks.dart';
import 'widgets/map_calibration_panel/map_calibration_panel.dart';
import 'widgets/map_landmark_details/map_landmark_details.dart';
import 'widgets/map_placeholder/map_placeholder.dart';
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
              MapCalibrationPanel(point: tappedPoint)
            else
              MapLandmarkDetails(landmark: selectedLandmark),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(BuildContext context, AsyncSnapshot<String> snapshot) {
    if (snapshot.hasError) {
      return const MapPlaceholder(message: 'Chargement impossible');
    }

    final version = snapshot.data;
    if (version == null) {
      return const MapPlaceholder(message: 'Chargement…');
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
