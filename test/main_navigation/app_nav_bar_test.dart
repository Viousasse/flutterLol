import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/main_navigation/widgets/app_nav_bar/app_nav_bar.dart';

const _destinations = [
  AppNavDestination(
    label: 'Accueil',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  AppNavDestination(
    label: 'Quiz',
    icon: Icons.quiz_outlined,
    selectedIcon: Icons.quiz,
  ),
];

Widget _bar({required int current, required ValueChanged<int> onSelect}) {
  return MaterialApp(
    home: Scaffold(
      bottomNavigationBar: AppNavBar(
        destinations: _destinations,
        currentIndex: current,
        onSelect: onSelect,
      ),
    ),
  );
}

void main() {
  testWidgets('affiche une icône et un libellé par destination', (
    tester,
  ) async {
    await tester.pumpWidget(_bar(current: 0, onSelect: (_) {}));

    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Quiz'), findsOneWidget);
    // L'onglet actif prend l'icône pleine, les autres l'icône au trait.
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.quiz_outlined), findsOneWidget);
  });

  testWidgets('signale l onglet touché', (tester) async {
    int? selected;
    await tester.pumpWidget(_bar(current: 0, onSelect: (i) => selected = i));

    await tester.tap(find.text('Quiz'));

    expect(selected, 1);
  });

  testWidgets('marque l onglet actif pour les lecteurs d écran', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_bar(current: 1, onSelect: (_) {}));

    expect(
      tester.getSemantics(find.bySemanticsLabel('Quiz')),
      isSemantics(isButton: true, isSelected: true),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Accueil')),
      isSemantics(isButton: true, isSelected: false),
    );
    handle.dispose();
  });
}
