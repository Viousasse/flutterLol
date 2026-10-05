import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/champions/models/champion.dart';
import 'package:monapp/shared/widgets/champion_picker_sheet/champion_picker_sheet.dart';

/// Champions fictifs dont l'image pointe vers un domaine qui ne répond jamais :
/// aucun test ne dépend du réseau.
Champion fakeChampion(String id) {
  return Champion(
    id: id,
    name: id,
    title: 'titre de $id',
    blurb: '',
    imageUrl: 'https://example.invalid/$id.png',
    tags: const ['Fighter'],
    attackRating: 5,
    defenseRating: 3,
    magicRating: 5,
  );
}

/// Laisse passer les animations et les futures en attente. Pas de
/// `pumpAndSettle` : les vignettes affichent un effet de chargement qui boucle
/// tant que l'image n'est pas arrivée, et le réseau ne répond jamais en test.
Future<void> settle(WidgetTester tester) async {
  for (var frame = 0; frame < 10; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Un écran haut, pour que toute la liste soit construite sans défilement.
void useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(900, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Une ligne de la feuille de choix de champion, ouverte à l'écran.
Finder sheetEntry(String name) {
  return find.descendant(
    of: find.byType(ChampionPickerSheet),
    matching: find.widgetWithText(ListTile, name),
  );
}

/// Un texte à l'intérieur de la feuille de choix de champion.
Finder sheetText(String text) {
  return find.descendant(
    of: find.byType(ChampionPickerSheet),
    matching: find.text(text),
  );
}
