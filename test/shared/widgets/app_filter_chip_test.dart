import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/shared/widgets/app_filter_chip/app_filter_chip.dart';
import 'package:monapp/shared/widgets/lane_filter_bar/lane_filter_bar.dart';

void main() {
  testWidgets('la puce est annoncée comme un bouton, avec son état', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AppFilterChip(label: 'Mid', selected: true, onTap: () => taps++),
              AppFilterChip(label: 'Top', selected: false, onTap: () {}),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.text('Mid')),
      isSemantics(
        label: 'Mid',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasTapAction: true,
        hasEnabledState: false,
      ),
    );
    expect(
      tester.getSemantics(find.text('Top')),
      isSemantics(
        label: 'Top',
        isButton: true,
        isSelected: false,
        hasSelectedState: true,
        hasTapAction: true,
        hasEnabledState: false,
      ),
    );

    await tester.tap(find.text('Mid'));
    expect(taps, 1);
    handle.dispose();
  });

  testWidgets('dans une hauteur de 44 px la zone tactile fait 44 px, '
      'la pastille 32', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: AppFilterChip.minTapHeight,
              child: AppFilterChip(label: 'Mid', selected: false, onTap: () {}),
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(AppFilterChip)).height,
      greaterThanOrEqualTo(44),
    );
    final pill = find.descendant(
      of: find.byType(AppFilterChip),
      matching: find.byType(Container),
    );
    expect(tester.getSize(pill).height, AppFilterChip.visibleHeight);
  });

  testWidgets('la barre de voies offre des zones tactiles de 44 px', (
    tester,
  ) async {
    String? picked = 'unset';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LaneFilterBar(
            lanes: const ['TOP', 'MIDDLE'],
            selectedLane: null,
            onSelect: (lane) => picked = lane,
          ),
        ),
      ),
    );

    for (final chip in tester.widgetList<AppFilterChip>(
      find.byType(AppFilterChip),
    )) {
      final size = tester.getSize(find.byWidget(chip));
      expect(size.height, greaterThanOrEqualTo(44));
    }

    // Un toucher à 6 px au-dessus du texte (hors pastille) est pris en compte.
    final center = tester.getCenter(find.text('Toutes les voies'));
    await tester.tapAt(center.translate(0, -17));
    expect(picked, isNull);
  });
}
