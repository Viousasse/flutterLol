import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/builds/builds_page.dart';
import 'package:monapp/builds/services/build_store.dart';
import 'package:monapp/champions/models/champion.dart';
import 'package:monapp/items/models/item.dart';
import 'package:monapp/items/models/item_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../counters/counter_pages_support.dart';

final _items = [
  const Item(
    id: '1',
    name: 'Lame',
    description: '',
    plaintext: '',
    gold: 1000,
    imageUrl: 'https://example.invalid/item1.png',
    tier: ItemTier.legendary,
    profile: ItemProfile.other,
    componentIds: [],
    upgradeIds: [],
  ),
];

void main() {
  testWidgets('le second chargeur échoue avant le premier : Réessayer, puis '
      'la liste', (tester) async {
    useTallScreen(tester);
    SharedPreferences.setMockInitialValues({});
    BuildStore.reset();
    final firstItems = Completer<List<Item>>();
    var itemAttempts = 0;
    var championAttempts = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: BuildsPage(
          loadItems: () {
            itemAttempts++;
            if (itemAttempts == 1) return firstItems.future;

            return Future.value(_items);
          },
          loadChampions: () async {
            championAttempts++;
            if (championAttempts == 1) throw Exception('champions hors ligne');

            return <Champion>[fakeChampion('Ahri')];
          },
        ),
      ),
    );
    await settle(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    firstItems.complete(_items);
    await settle(tester);

    expect(find.text('Chargement impossible pour le moment.'), findsOneWidget);

    await tester.tap(find.text('Réessayer'));
    await settle(tester);

    expect(find.text('Chargement impossible pour le moment.'), findsNothing);
    expect(find.text('Nouvelle build'), findsOneWidget);
  });
}
