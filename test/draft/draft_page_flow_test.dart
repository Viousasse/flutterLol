import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/champions/models/champion.dart';
import 'package:monapp/draft/draft_page.dart';
import 'package:monapp/draft/models/draft_mode.dart';
import 'package:monapp/draft/services/draft_history_store.dart';
import 'package:monapp/draft/widgets/ban_row/ban_row.dart';
import 'package:monapp/draft/widgets/draft_slot/draft_slot.dart';
import 'package:monapp/shared/widgets/champion_picker_sheet/champion_picker_sheet.dart';
import 'package:monapp/team/constants/team_roles.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'draft_support.dart';

/// Soixante champions, douze par voie, pour qu'un rôle ne manque jamais de
/// choix même après dix bannissements.
final _champions = [
  for (var index = 0; index < 60; index++)
    Champion(
      id: 'C${index.toString().padLeft(2, '0')}',
      name: 'C${index.toString().padLeft(2, '0')}',
      title: 'titre',
      blurb: '',
      imageUrl: 'https://example.invalid/$index.png',
      tags: const ['Fighter'],
      attackRating: 5,
      defenseRating: 3,
      magicRating: 5,
    ),
];

final _data = dataset([
  for (var index = 0; index < _champions.length; index++)
    duel(
      _champions[index].id,
      'Dummy',
      lane: teamRoleLanes[index % teamRoles.length],
      games: 200,
      wins: 100 + index % 20,
    ),
]);

/// Laisse passer les animations et les futures en attente. Pas de
/// `pumpAndSettle` : les vignettes affichent un effet de chargement qui boucle
/// tant que l'image n'est pas arrivée, et le réseau ne répond jamais en test.
Future<void> _settle(WidgetTester tester) async {
  for (var frame = 0; frame < 10; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Widget _page(DraftMode mode) {
  return MaterialApp(
    home: DraftPage(
      mode: mode,
      loadChampions: () async => _champions,
      loadDataset: () async => _data,
      loadDetail: (id) async => member(id).detail,
      botThinkingDelay: Duration.zero,
    ),
  );
}

Future<void> _open(WidgetTester tester, DraftMode mode) async {
  tester.view.physicalSize = const Size(900, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(_page(mode));
  await _settle(tester);
}

/// Choisit le premier champion proposé par la feuille ouverte.
Future<void> _pickFirstInSheet(WidgetTester tester) async {
  // Les lignes de la feuille uniquement : l'interrupteur des bannissements est
  // lui aussi un ListTile, placé avant elles dans la page.
  final entries = find.descendant(
    of: find.byType(ChampionPickerSheet),
    matching: find.byType(ListTile),
  );
  await tester.tap(entries.first);
  await _settle(tester);
}

/// La première case de rôle sur laquelle on peut appuyer.
Finder _pickableSlot() {
  return find.byWidgetPredicate(
    (widget) =>
        widget is DraftSlot && widget.onTap != null && widget.champion == null,
  );
}

/// Joue les choix de chaque camp jusqu'à la fin, en prenant à chaque fois le
/// premier champion proposé pour le premier rôle libre.
Future<void> _playAllPicks(WidgetTester tester) async {
  for (
    var turn = 0;
    turn < 20 && _pickableSlot().evaluate().isNotEmpty;
    turn++
  ) {
    await tester.tap(_pickableSlot().first);
    await _settle(tester);
    await _pickFirstInSheet(tester);
  }
  // Un dernier temps pour l'analyse et l'enregistrement dans l'historique.
  await _settle(tester);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    DraftHistoryStore.reset();
  });

  testWidgets('une draft contre le site, des bannissements au bilan', (
    tester,
  ) async {
    await _open(tester, DraftMode.vsSite);

    // Phase de bannissements : le joueur ouvre, le site répond.
    expect(find.textContaining('ban 1 sur 10'), findsOneWidget);
    for (var ban = 0; ban < 5; ban++) {
      await tester.tap(find.byType(BanRow).first);
      await _settle(tester);
      await _pickFirstInSheet(tester);
    }

    // Les dix bannis sont posés, rien n'a encore été choisi.
    expect(find.textContaining('choix 1 sur 10'), findsOneWidget);
    expect(find.byIcon(Icons.block), findsNWidgets(10));

    await _playAllPicks(tester);

    // Le bilan est affiché, avec les remarques sur les bannissements.
    expect(find.text('VERDICT'), findsOneWidget);
    expect(find.text('BANNISSEMENTS'), findsOneWidget);
    expect(find.text('Copier le résumé à partager'), findsOneWidget);

    // La draft est gardée dans l'historique.
    final records = DraftHistoryStore.records.value;
    expect(records, hasLength(1));
    expect(records.single.versusFriend, isFalse);
    expect(records.single.blueBans.where((id) => id.isNotEmpty), hasLength(5));
    expect(records.single.redBans.where((id) => id.isNotEmpty), hasLength(5));
    expect(records.single.blue.where((id) => id.isNotEmpty), hasLength(5));
    expect(records.single.red.where((id) => id.isNotEmpty), hasLength(5));

    // Aucun champion n'apparaît deux fois, bannis compris.
    final all = [
      ...records.single.blue,
      ...records.single.red,
      ...records.single.blueBans,
      ...records.single.redBans,
    ].where((id) => id.isNotEmpty);
    expect(all.toSet(), hasLength(all.length));
  });

  testWidgets('sans bannissements, la draft commence par un choix', (
    tester,
  ) async {
    await _open(tester, DraftMode.vsSite);

    await tester.tap(find.byType(Switch));
    await _settle(tester);

    expect(find.textContaining('choix 1 sur 10'), findsOneWidget);
    expect(find.byType(BanRow), findsNWidgets(2));
    expect(find.byIcon(Icons.block), findsNothing);

    await _playAllPicks(tester);

    expect(find.text('VERDICT'), findsOneWidget);
    expect(find.text('BANNISSEMENTS'), findsNothing);
    expect(DraftHistoryStore.records.value, hasLength(1));
  });

  testWidgets('« Refaire une draft » repart d\'une grille vide', (
    tester,
  ) async {
    await _open(tester, DraftMode.vsSite);
    await tester.tap(find.byType(Switch));
    await _settle(tester);
    await _playAllPicks(tester);

    final again = find.text('Refaire une draft');
    await tester.ensureVisible(again);
    await tester.tap(again);
    await _settle(tester);

    expect(find.text('VERDICT'), findsNothing);
    expect(find.textContaining('choix 1 sur 10'), findsOneWidget);
    // Une draft déjà jugée reste dans l'historique.
    expect(DraftHistoryStore.records.value, hasLength(1));
  });

  testWidgets(
    'une draft à deux se joue sans le site, nom des joueurs compris',
    (tester) async {
      await _open(tester, DraftMode.vsFriend);
      await tester.tap(find.byType(Switch));
      await _settle(tester);

      expect(find.textContaining('Au tour de Joueur 1'), findsOneWidget);

      await _playAllPicks(tester);

      expect(find.text('VERDICT'), findsOneWidget);
      expect(find.text('À AMÉLIORER · JOUEUR 1'), findsOneWidget);
      expect(find.text('À AMÉLIORER · JOUEUR 2'), findsOneWidget);

      final record = DraftHistoryStore.records.value.single;
      expect(record.versusFriend, isTrue);
      expect(record.blueName, 'Joueur 1');
      expect(record.redName, 'Joueur 2');
      expect(record.blue.where((id) => id.isNotEmpty), hasLength(5));
      expect(record.red.where((id) => id.isNotEmpty), hasLength(5));
    },
  );
}
