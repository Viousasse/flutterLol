import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/champions/models/champion.dart';
import 'package:monapp/draft/draft_page.dart';
import 'package:monapp/draft/models/draft_mode.dart';
import 'package:monapp/draft/services/draft_history_store.dart';
import 'package:monapp/draft/services/friend_session_store.dart';
import 'package:monapp/draft/widgets/draft_slot/draft_slot.dart';
import 'package:monapp/draft/widgets/suggestion_card/suggestion_card.dart';
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

Future<void> _open(
  WidgetTester tester, {
  DraftMode mode = DraftMode.vsSite,
}) async {
  tester.view.physicalSize = const Size(900, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: DraftPage(
        mode: mode,
        loadChampions: () async => _champions,
        loadDataset: () async => _data,
        loadDetail: (id) async => member(id).detail,
        botThinkingDelay: Duration.zero,
      ),
    ),
  );
  await _settle(tester);
}

Finder _switchTile(String title) => find.widgetWithText(SwitchListTile, title);

Future<void> _toggle(WidgetTester tester, String title) async {
  await tester.tap(_switchTile(title));
  await _settle(tester);
}

/// Ouvre la page avec l'aide active et sans bannissements, prête à choisir.
Future<void> _openReadyToPick(WidgetTester tester) async {
  await _open(tester);
  await _toggle(tester, 'Bannissements');
  await _toggle(tester, 'Aide au choix');
}

Finder _pickableSlot() {
  return find.byWidgetPredicate(
    (widget) =>
        widget is DraftSlot && widget.onTap != null && widget.champion == null,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    DraftHistoryStore.reset();
    FriendSessionStore.reset();
  });

  testWidgets('l’interrupteur est visible avant le premier coup, éteint', (
    tester,
  ) async {
    await _open(tester);

    expect(_switchTile('Aide au choix'), findsOneWidget);
    expect(
      tester.widget<SwitchListTile>(_switchTile('Aide au choix')).value,
      isFalse,
    );
    expect(find.textContaining('Propose 3 champions'), findsOneWidget);
  });

  testWidgets('l’interrupteur disparaît une fois le premier coup joué', (
    tester,
  ) async {
    await _openReadyToPick(tester);
    await tester.tap(find.byType(SuggestionCard).first);
    await _settle(tester);

    expect(_switchTile('Aide au choix'), findsNothing);
  });

  testWidgets('sans aide, aucun panneau de suggestions', (tester) async {
    await _open(tester);
    await _toggle(tester, 'Bannissements');

    expect(find.text('SUGGESTIONS'), findsNothing);
    expect(find.byType(SuggestionCard), findsNothing);
  });

  testWidgets('à son tour, trois suggestions s’affichent', (tester) async {
    await _openReadyToPick(tester);

    expect(find.text('SUGGESTIONS'), findsOneWidget);
    expect(find.byType(SuggestionCard), findsNWidgets(3));
  });

  testWidgets('aucune suggestion pendant les bannissements', (tester) async {
    await _open(tester);
    await _toggle(tester, 'Aide au choix');

    expect(find.textContaining('ban 1 sur'), findsOneWidget);
    expect(find.byType(SuggestionCard), findsNothing);
  });

  testWidgets('aucune suggestion au tour du site', (tester) async {
    await _openReadyToPick(tester);

    await tester.tap(find.byType(SuggestionCard).first);
    // Le site réfléchit : on observe l'écran avant qu'il ne joue.
    await tester.pump();
    final seenAtBotTurn = find.byType(SuggestionCard).evaluate().isEmpty;
    await _settle(tester);

    expect(seenAtBotTurn, isTrue);
  });

  testWidgets('toucher une carte place le champion au bon rôle', (
    tester,
  ) async {
    await _openReadyToPick(tester);

    final card = tester.widget<SuggestionCard>(
      find.byType(SuggestionCard).first,
    );
    await tester.tap(find.byType(SuggestionCard).first);
    await _settle(tester);

    final placed = find.byWidgetPredicate(
      (widget) =>
          widget is DraftSlot &&
          widget.role == card.role &&
          widget.champion?.id == card.champion.id,
    );
    expect(placed, findsOneWidget);
  });

  testWidgets('une draft jouée avec aide est marquée « avec aide »', (
    tester,
  ) async {
    await _openReadyToPick(tester);

    for (var turn = 0; turn < 5; turn++) {
      await tester.tap(find.byType(SuggestionCard).first);
      await _settle(tester);
    }
    await _settle(tester);

    final records = DraftHistoryStore.records.value;
    expect(records, hasLength(1));
    expect(records.single.assisted, isTrue);
  });

  testWidgets('une draft jouée sans aide n’est pas marquée', (tester) async {
    await _open(tester);
    await _toggle(tester, 'Bannissements');

    for (var turn = 0; turn < 5; turn++) {
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

    final records = DraftHistoryStore.records.value;
    expect(records, hasLength(1));
    expect(records.single.assisted, isFalse);
  });
}
