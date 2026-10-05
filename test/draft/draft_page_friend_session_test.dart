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

Future<void> _skipBans(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(SwitchListTile, 'Bannissements'));
  await _settle(tester);
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

void _storeSession(FriendSession session) {
  SharedPreferences.setMockInitialValues({
    'friend_session': jsonEncode(session.toJson()),
  });
}

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    DraftHistoryStore.reset();
    FriendSessionStore.reset();
  });

  testWidgets('les noms viennent de la session enregistrée', (tester) async {
    _storeSession(
      const FriendSession(
        players: DraftPlayers(blue: 'Léa', red: 'Tom'),
        blueWins: 2,
      ),
    );
    await _open(tester);

    expect(find.textContaining('Léa · BLEU'), findsOneWidget);
    expect(find.textContaining('Tom · ROUGE'), findsOneWidget);
    expect(find.byType(FriendScoreBar), findsOneWidget);
    expect(find.text('Léa 2 – 0 Tom'), findsOneWidget);
  });

  testWidgets('renommer un joueur met à jour la session', (tester) async {
    await _open(tester);

    await tester.tap(find.textContaining('Joueur 1 · BLEU'));
    await _settle(tester);
    await tester.enterText(find.byType(TextField), 'Léa');
    await tester.tap(find.text('Valider'));
    await _settle(tester);

    expect(find.textContaining('Léa · BLEU'), findsOneWidget);
    expect(FriendSessionStore.session.value.players.blue, 'Léa');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('friend_session'), contains('Léa'));
  });

  testWidgets('la fin de la draft incrémente le score', (tester) async {
    await _open(tester);
    await _skipBans(tester);
    await _playAllPicks(tester);

    final session = FriendSessionStore.session.value;
    expect(session.blueWins + session.redWins + session.ties, 1);
  });

  testWidgets('la remise à zéro demande confirmation', (tester) async {
    _storeSession(
      const FriendSession(
        players: DraftPlayers(blue: 'Léa', red: 'Tom'),
        blueWins: 3,
        ties: 1,
      ),
    );
    await _open(tester);

    final reset = find.descendant(
      of: find.byType(FriendScoreBar),
      matching: find.byType(IconButton),
    );
    await tester.tap(reset);
    await _settle(tester);
    expect(find.text('Remettre le score à zéro ?'), findsOneWidget);

    await tester.tap(find.text('Annuler'));
    await _settle(tester);
    expect(FriendSessionStore.session.value.blueWins, 3);

    await tester.tap(reset);
    await _settle(tester);
    await tester.tap(find.text('Remettre à zéro'));
    await _settle(tester);

    expect(FriendSessionStore.session.value.isScoreEmpty, isTrue);
    expect(FriendSessionStore.session.value.players.blue, 'Léa');
  });

  testWidgets('un duel rejoué garde ses noms et n’écrit pas dans la session', (
    tester,
  ) async {
    await _open(tester, replayOf: _replayed());
    await _playAllPicks(tester);

    expect(find.textContaining('Alice · BLEU'), findsWidgets);
    expect(FriendSessionStore.session.value.isScoreEmpty, isTrue);
    expect(FriendSessionStore.session.value.players.blue, 'Joueur 1');
  });
}
