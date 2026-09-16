import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/champions/models/champion.dart';
import 'package:monapp/regions/constants/champion_regions.dart';
import 'package:monapp/regions/constants/lore_regions.dart';
import 'package:monapp/regions/widgets/region_marker/region_marker.dart';
import 'package:monapp/regions/widgets/runeterra_map/runeterra_map.dart';

Champion _champion(String id) => Champion(
  id: id,
  name: id,
  title: '',
  blurb: '',
  imageUrl: '',
  tags: const [],
);

void main() {
  testWidgets('affiche le fond de carte embarqué et une pastille par région', (
    tester,
  ) async {
    final champions = championRegions.keys.map(_champion).toList();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RuneterraMap(
            champions: champions,
            selectedRegion: null,
            onSelect: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    final background = tester.widget<Image>(find.byType(Image));
    expect((background.image as AssetImage).assetName, runeterraMapAsset);

    final placed = loreRegions.where((r) => r.x != null && r.y != null);
    expect(find.byType(RegionMarker), findsNWidgets(placed.length));
    expect(placed.length, 12);
  });

  test('chaque champion de la table pointe vers une région déclarée', () {
    final declared = loreRegions.map((r) => r.id).toSet();
    for (final entry in championRegions.entries) {
      expect(declared, contains(entry.value), reason: entry.key);
    }
    expect(championRegions.length, 173);
  });

  test('deux pastilles ne se recouvrent jamais à 335 px de large', () {
    // Empreinte d'une pastille (72 × 30 px) en fraction d'une carte de 335 px.
    const width = 72 / 335;
    const height = 30 / 335;
    final placed = loreRegions
        .where((r) => r.x != null && r.y != null)
        .toList();

    for (var i = 0; i < placed.length; i++) {
      for (var j = i + 1; j < placed.length; j++) {
        final a = placed[i];
        final b = placed[j];
        final overlaps =
            (a.x! - b.x!).abs() < width && (a.y! - b.y!).abs() < height;
        expect(overlaps, isFalse, reason: '${a.name} recouvre ${b.name}');
      }
    }
  });
}
