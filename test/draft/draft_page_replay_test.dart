import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/champions/models/champion.dart';
import 'package:monapp/draft/draft_page.dart';
import 'package:monapp/draft/models/draft_record.dart';
import 'package:monapp/draft/models/draft_report.dart';
import 'package:monapp/draft/services/draft_history_store.dart';
import 'package:monapp/draft/widgets/ban_row/ban_row.dart';
import 'package:monapp/draft/widgets/draft_slot/draft_slot.dart';
import 'package:monapp/shared/widgets/champion_picker_sheet/champion_picker_sheet.dart';
import 'package:monapp/team/constants/team_roles.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'draft_support.dart';

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

const _blueBans = ['C50', 'C51', 'C52', 'C53', 'C54'];
const _redBans = ['C55', 'C56', 'C57', 'C58', 'C59'];

final _playedAt = DateTime(2026, 10, 5, 15, 42);

DraftRecord _record({
  bool bans = true,
  bool versusFriend = false,
  List<String>? blueBans,
  List<String>? redBans,
}) {
  return DraftRecord(
    id: 'ancienne',
    playedAt: _playedAt,
    versusFriend: versusFriend,
    blueName: versusFriend ? 'Alice' : 'Vous',
    redName: versusFriend ? 'Bob' : 'Le site',
    blue: const ['C00', 'C01', 'C02', 'C03', 'C04'],
    red: const ['C05', 'C06', 'C07', 'C08', 'C09'],
    blueBans: bans ? (blueBans ?? _blueBans) : const [],
    redBans: bans ? (redBans ?? _redBans) : const [],
    championNames: const {},
    winner: DraftWinner.blue,
    blueScore: 60,
    redScore: 40,
    verdict: 'Bleu l’emporte.',
  );
}

Future<void> _settle(WidgetTester tester) async {
  for (var frame = 0; frame < 10; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _open(WidgetTester tester, DraftRecord replayOf) async {
  tester.view.physicalSize = const Size(900, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: DraftPage(
        replayOf: replayOf,
        loadChampions: () async => _champions,
        loadDataset: () async => _data,
        loadDetail: (id) async => member(id).detail,
        botThinkingDelay: Duration.zero,
      ),
    ),
  );
  await _settle(tester);
}

Future<void> _pickFirstInSheet(WidgetTester tester) async {
  final entries = find.descendant(
    of: find.byType(ChampionPickerSheet),
    matching: find.byType(ListTile),
  );
  await tester.tap(entries.first);
  await _settle(tester);
}

Finder _pickableSlot() {
  return find.byWidgetPredicate(
    (widget) =>
        widget is DraftSlot && widget.onTap != null && widget.champion == null,
  );
}

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
  await _settle(tester);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    DraftHistoryStore.reset();
  });

  testWidgets(
    'rejouer avec bannissements : ils sont posés, pas de phase de ban',
    (tester) async {
      await _open(tester, _record());

      expect(find.byIcon(Icons.block), findsNWidgets(10));
      expect(find.byType(BanRow), findsNWidgets(2));
      expect(find.textContaining('choix 1 sur 10'), findsOneWidget);
      expect(find.textContaining('ban 1 sur'), findsNothing);
      // Les dix champions bannis sont affichés, l'interrupteur est masqué.
      expect(find.byType(Switch), findsNothing);
      expect(
        find.textContaining('Vous rejouez la draft du 5 oct. 2026, 15 h 42'),
        findsOneWidget,
      );
      expect(find.textContaining('mêmes bannissements'), findsOneWidget);
    },
  );

  testWidgets('rejouer sans bannissements : on commence par un choix', (
    tester,
  ) async {
    await _open(tester, _record(bans: false));

    expect(find.textContaining('choix 1 sur 10'), findsOneWidget);
    expect(find.byType(Switch), findsNothing);
    expect(find.textContaining('Vous rejouez la draft'), findsOneWidget);

    await _playAllPicks(tester);

    expect(find.text('VERDICT'), findsOneWidget);
    expect(find.text('BANNISSEMENTS'), findsNothing);
  });

  testWidgets('une draft à deux rejouée reprend le mode et les noms', (
    tester,
  ) async {
    await _open(tester, _record(versusFriend: true));

    expect(find.text('Draft à deux'), findsOneWidget);
    expect(find.textContaining('Alice · BLEU'), findsOneWidget);
    expect(find.textContaining('Bob · ROUGE'), findsOneWidget);
    expect(find.textContaining('Au tour de Alice'), findsOneWidget);
  });

  testWidgets(
    'un champion banni introuvable est ignoré, la phase de ban reprend',
    (tester) async {
      // Le troisième ban du bleu n'existe plus : les deux premiers de chaque camp
      // sont posés, les autres cases restent à jouer.
      await _open(
        tester,
        _record(blueBans: const ['C50', 'C51', 'RETIRE', 'C53', 'C54']),
      );

      expect(find.textContaining('ban 5 sur 10'), findsOneWidget);
      expect(find.textContaining('choix 1 sur'), findsNothing);
    },
  );

  testWidgets('« Refaire une draft » garde les mêmes bannissements', (
    tester,
  ) async {
    await _open(tester, _record());
    await _playAllPicks(tester);

    final again = find.text('Refaire une draft');
    await tester.ensureVisible(again);
    await tester.tap(again);
    await _settle(tester);

    expect(find.text('VERDICT'), findsNothing);
    expect(find.textContaining('choix 1 sur 10'), findsOneWidget);
    expect(find.byType(Switch), findsNothing);
    expect(find.textContaining('ban 1 sur'), findsNothing);
  });

  testWidgets('la draft rejouée est enregistrée comme une nouvelle entrée', (
    tester,
  ) async {
    await _open(tester, _record());
    await _playAllPicks(tester);

    final records = DraftHistoryStore.records.value;
    expect(records, hasLength(1));
    expect(records.single.id, isNot('ancienne'));
    expect(records.single.blueBans, _blueBans);
    expect(records.single.redBans, _redBans);
    expect(records.single.blue.where((id) => id.isNotEmpty), hasLength(5));
    expect(records.single.red.where((id) => id.isNotEmpty), hasLength(5));
  });
}
