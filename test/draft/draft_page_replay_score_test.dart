import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/champions/models/champion.dart';
import 'package:monapp/draft/draft_page.dart';
import 'package:monapp/draft/models/draft_mode.dart';
import 'package:monapp/draft/models/draft_record.dart';
import 'package:monapp/draft/models/draft_report.dart';
import 'package:monapp/draft/services/draft_history_store.dart';
import 'package:monapp/draft/services/friend_session_store.dart';
import 'package:monapp/draft/widgets/draft_slot/draft_slot.dart';
import 'package:monapp/draft/widgets/friend_score_bar/friend_score_bar.dart';
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

const _session = FriendSession(
  players: DraftPlayers(blue: 'Léa', red: 'Tom'),
  blueWins: 3,
  redWins: 2,
);

DraftRecord _replayed() {
  return DraftRecord(
    id: 'ancienne',
    playedAt: DateTime(2026, 10, 5, 15, 42),
    versusFriend: true,
    blueName: 'Alice',
    redName: 'Bob',
    blue: const ['C00', 'C01', 'C02', 'C03', 'C04'],
    red: const ['C05', 'C06', 'C07', 'C08', 'C09'],
    blueBans: const [],
    redBans: const [],
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

Future<void> _open(WidgetTester tester, {DraftRecord? replayOf}) async {
  tester.view.physicalSize = const Size(900, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: DraftPage(
        mode: DraftMode.vsFriend,
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
    await tester.tap(
      find
          .descendant(
            of: find.byType(ChampionPickerSheet),
            matching: find.byType(ListTile),
          )
          .first,
    );
    await _settle(tester);
  }
  await _settle(tester);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'friend_session': jsonEncode(_session.toJson()),
    });
    DraftHistoryStore.reset();
    FriendSessionStore.reset();
  });

  testWidgets('une draft à deux normale affiche le score de la soirée', (
    tester,
  ) async {
    await _open(tester);

    expect(find.byType(FriendScoreBar), findsOneWidget);
    expect(find.text('Léa 3 – 2 Tom'), findsOneWidget);
  });

  testWidgets('un duel rejoué n’affiche pas le score de la soirée', (
    tester,
  ) async {
    await _open(tester, replayOf: _replayed());

    expect(find.textContaining('Alice · BLEU'), findsOneWidget);
    expect(find.byType(FriendScoreBar), findsNothing);
    expect(find.textContaining('Léa'), findsNothing);
  });

  testWidgets('un duel rejoué ne modifie pas la session', (tester) async {
    await _open(tester, replayOf: _replayed());
    await _playAllPicks(tester);

    expect(find.text('VERDICT'), findsOneWidget);
    expect(FriendSessionStore.session.value.blueWins, 3);
    expect(FriendSessionStore.session.value.redWins, 2);
    expect(FriendSessionStore.session.value.ties, 0);
    expect(FriendSessionStore.session.value.players.blue, 'Léa');
    expect(find.byType(FriendScoreBar), findsNothing);
  });
}
