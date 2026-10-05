import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/builds/builds_page.dart';
import 'package:monapp/builds/models/build.dart';
import 'package:monapp/builds/services/build_share_code.dart';
import 'package:monapp/builds/services/build_share_text.dart';
import 'package:monapp/builds/services/build_store.dart';
import 'package:monapp/champions/models/champion.dart';
import 'package:monapp/items/models/item.dart';
import 'package:monapp/items/models/item_profile.dart';
import 'package:monapp/shared/widgets/paste_code_dialog/paste_code_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../counters/counter_pages_support.dart';

Item _item(String id, String name, int gold) {
  return Item(
    id: id,
    name: name,
    description: '',
    plaintext: '',
    gold: gold,
    imageUrl: 'https://example.invalid/item$id.png',
    tier: ItemTier.legendary,
    profile: ItemProfile.other,
    componentIds: const [],
    upgradeIds: const [],
  );
}

final _items = [_item('1', 'Lame', 1000), _item('2', 'Bâton', 2500)];
final _champions = [fakeChampion('Ahri')];

const _burst = Build(
  id: 'a',
  name: 'Burst',
  championId: 'Ahri',
  itemIds: ['1', '2'],
);
const _tank = Build(id: 'b', name: 'Tank', itemIds: ['1']);

const _emptyMessage =
    "Aucune build pour l'instant. Composez-en une avec le bouton "
    'ci-dessous.';

Widget _page({
  Future<List<Item>> Function()? loadItems,
  Future<List<Champion>> Function()? loadChampions,
}) {
  return MaterialApp(
    home: BuildsPage(
      loadItems: loadItems ?? () async => _items,
      loadChampions: loadChampions ?? () async => _champions,
    ),
  );
}

/// Ouvre la page avec [saved] déjà enregistrées dans le stockage de test.
Future<void> _open(
  WidgetTester tester, {
  List<Build> saved = const [],
  Widget? page,
}) async {
  useTallScreen(tester);
  // Le stockage est lu par la page elle-même : le seed passe par les
  // préférences, dans l'ordre d'affichage.
  SharedPreferences.setMockInitialValues({
    'saved_builds': [for (final build in saved) jsonEncode(build.toJson())],
  });

  await tester.pumpWidget(page ?? _page());
  await settle(tester);
}

/// Écoute le canal du presse-papiers et retient le dernier texte copié.
class _Clipboard {
  String? copied;

  void install(WidgetTester tester) {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }

        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
  }
}

Future<void> _openImportDialog(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Importer une build'));
  await settle(tester);
}

Future<void> _submitImport(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump();
  await tester.tap(find.text('Importer'));
  await settle(tester);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    BuildStore.reset();
  });

  testWidgets('affiche un indicateur pendant le chargement', (tester) async {
    final items = Completer<List<Item>>();
    useTallScreen(tester);

    await tester.pumpWidget(_page(loadItems: () => items.future));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Rien à créer tant que les données ne sont pas là.
    expect(find.text('Nouvelle build'), findsNothing);

    items.complete(_items);
    await settle(tester);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Nouvelle build'), findsOneWidget);
  });

  testWidgets('un échec propose Réessayer, puis la liste s affiche', (
    tester,
  ) async {
    var attempts = 0;

    await _open(
      tester,
      saved: const [_burst],
      page: _page(
        loadItems: () async {
          attempts++;
          if (attempts == 1) throw Exception('hors ligne');

          return _items;
        },
      ),
    );

    expect(find.text('Chargement impossible pour le moment.'), findsOneWidget);

    await tester.tap(find.text('Réessayer'));
    await settle(tester);

    expect(attempts, 2);
    expect(find.text('Burst'), findsOneWidget);
  });

  testWidgets('dit quand aucune build n est enregistrée', (tester) async {
    await _open(tester);

    expect(find.text(_emptyMessage), findsOneWidget);
    expect(find.text('Nouvelle build'), findsOneWidget);
  });

  testWidgets('liste les builds avec leur champion et leur coût', (
    tester,
  ) async {
    await _open(tester, saved: const [_burst, _tank]);

    expect(find.text('Burst'), findsOneWidget);
    expect(find.text('Tank'), findsOneWidget);
    expect(find.text('Ahri · 3500 or'), findsOneWidget);
    expect(find.text('1000 or'), findsOneWidget);
    expect(find.text(_emptyMessage), findsNothing);
  });

  testWidgets('la suppression demande confirmation', (tester) async {
    await _open(tester, saved: const [_burst, _tank]);

    await tester.tap(find.byTooltip('Supprimer la build Burst'));
    await settle(tester);

    expect(find.text('Supprimer cette build ?'), findsOneWidget);

    // Annuler garde la build.
    await tester.tap(find.text('Annuler'));
    await settle(tester);

    expect(find.text('Burst'), findsOneWidget);
    expect(BuildStore.builds.value, hasLength(2));

    await tester.tap(find.byTooltip('Supprimer la build Burst'));
    await settle(tester);
    await tester.tap(find.text('Supprimer la build'));
    await settle(tester);

    expect(find.text('Burst'), findsNothing);
    expect(find.text('Tank'), findsOneWidget);
    expect(BuildStore.builds.value.map((build) => build.id), ['b']);
  });

  testWidgets('le bouton de partage copie le résumé de la build', (
    tester,
  ) async {
    final clipboard = _Clipboard()..install(tester);
    await _open(tester, saved: const [_burst]);

    await tester.tap(find.byTooltip('Copier le résumé de la build Burst'));
    await tester.pump();
    await tester.pump();

    expect(clipboard.copied, BuildShareText.of(_burst, _items, 'Ahri'));
    expect(
      clipboard.copied,
      contains('Code : ${BuildShareCode.encode(_burst)}'),
    );
    expect(find.text('Résumé de la build copié'), findsOneWidget);
  });

  testWidgets('importe une build depuis un message contenant un code', (
    tester,
  ) async {
    await _open(tester);
    final message =
        'Regarde ma build !\n${BuildShareText.of(_burst, _items, 'Ahri')}';

    await _openImportDialog(tester);
    expect(find.byType(PasteCodeDialog<Build>), findsOneWidget);

    await _submitImport(tester, message);

    expect(find.byType(PasteCodeDialog<Build>), findsNothing);
    expect(find.text('Build « Burst » importée'), findsOneWidget);
    expect(find.text('Burst'), findsOneWidget);
    expect(BuildStore.builds.value, hasLength(1));
    // L'ami garde sa propre copie : l'identifiant est neuf.
    expect(BuildStore.builds.value.single.id, isNot('a'));
    expect(BuildStore.builds.value.single.itemIds, ['1', '2']);
  });

  testWidgets('un texte invalide laisse la boîte ouverte avec l erreur', (
    tester,
  ) async {
    await _open(tester);

    await _openImportDialog(tester);
    await _submitImport(tester, 'rien à voir avec une build');

    expect(find.byType(PasteCodeDialog<Build>), findsOneWidget);
    expect(
      find.text('Ce texte ne contient pas de code de build valide.'),
      findsOneWidget,
    );
    expect(BuildStore.builds.value, isEmpty);

    // Annuler ferme la boîte sans rien enregistrer.
    await tester.tap(find.text('Annuler'));
    await settle(tester);

    expect(find.byType(PasteCodeDialog<Build>), findsNothing);
    expect(BuildStore.builds.value, isEmpty);
    expect(find.textContaining('importée'), findsNothing);
  });
}
