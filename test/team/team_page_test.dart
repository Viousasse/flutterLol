import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/champions/models/champion.dart';
import 'package:monapp/champions/models/champion_detail.dart';
import 'package:monapp/matchups/services/lane_profile.dart';
import 'package:monapp/team/team_page.dart';
import 'package:monapp/team/widgets/damage_split_bar/damage_split_bar.dart';
import 'package:monapp/team/widgets/insight_tile/insight_tile.dart';

import '../counters/counter_pages_support.dart';
import '../draft/draft_support.dart';

final _champions = [
  for (final id in ['Garen', 'Ahri', 'Lux']) fakeChampion(id),
];

/// Garen se joue en haut, Ahri au milieu ; Lux n'a aucune partie à son nom.
final _profile = LaneProfile.fromDataset(
  dataset([
    duel('Garen', 'Ahri', lane: 'TOP', games: 50, wins: 25),
    duel('Ahri', 'Garen', lane: 'MIDDLE', games: 50, wins: 25),
  ]),
);

const _emptySlotLabel = 'Choisir un champion';
const _emptyAnalysis =
    "Placez des champions dans l'équipe pour voir si elle est équilibrée.";

Widget _page({
  Future<List<Champion>> Function()? loadChampions,
  Future<ChampionDetail> Function(String championId)? loadDetail,
  Future<LaneProfile?> Function()? loadProfile,
}) {
  return MaterialApp(
    home: TeamPage(
      loadChampions: loadChampions ?? () async => _champions,
      loadDetail: loadDetail ?? (id) async => member(id).detail,
      loadProfile: loadProfile ?? () async => _profile,
    ),
  );
}

Future<void> _open(WidgetTester tester, Widget page) async {
  useTallScreen(tester);
  await tester.pumpWidget(page);
  await settle(tester);
}

/// Appuie sur la case du rôle [index] (0 = Top), la plus haute de la page.
Future<void> _tapSlot(WidgetTester tester, int index) async {
  await tester.tap(find.text(_emptySlotLabel).at(index));
  await settle(tester);
}

void main() {
  testWidgets('affiche un indicateur pendant le chargement', (tester) async {
    final champions = Completer<List<Champion>>();
    useTallScreen(tester);

    await tester.pumpWidget(_page(loadChampions: () => champions.future));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    champions.complete(_champions);
    await settle(tester);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text(_emptySlotLabel), findsNWidgets(5));
  });

  testWidgets('un échec propose Réessayer, puis la page se charge', (
    tester,
  ) async {
    var attempts = 0;

    await _open(
      tester,
      _page(
        loadChampions: () async {
          attempts++;
          if (attempts == 1) throw Exception('hors ligne');

          return _champions;
        },
      ),
    );

    expect(find.text('Chargement impossible pour le moment.'), findsOneWidget);

    await tester.tap(find.text('Réessayer'));
    await settle(tester);

    expect(attempts, 2);
    expect(find.text(_emptySlotLabel), findsNWidgets(5));
  });

  testWidgets('montre cinq cases vides et aucune analyse', (tester) async {
    await _open(tester, _page());

    for (final role in ['TOP', 'JUNGLE', 'MILIEU', 'BOT', 'SUPPORT']) {
      expect(find.text(role), findsOneWidget, reason: role);
    }
    expect(find.text(_emptySlotLabel), findsNWidgets(5));
    expect(find.text(_emptyAnalysis), findsOneWidget);
    expect(find.byTooltip("Vider l'équipe"), findsNothing);
  });

  testWidgets('la feuille présélectionne le rôle de la case', (tester) async {
    await _open(tester, _page());

    await _tapSlot(tester, 0);

    for (final label in ['Tous', 'Top', 'Jungle', 'Milieu', 'Bot', 'Support']) {
      expect(sheetText(label), findsOneWidget, reason: label);
    }
    // Case Top : seuls les champions qui se jouent en haut sont proposés.
    expect(sheetEntry('Garen'), findsOneWidget);
    expect(sheetEntry('Ahri'), findsNothing);
    expect(sheetEntry('Lux'), findsNothing);

    await tester.tap(sheetText('Tous'));
    await settle(tester);

    expect(sheetEntry('Ahri'), findsOneWidget);
    expect(sheetEntry('Lux'), findsOneWidget);
  });

  testWidgets('une autre case présélectionne son propre rôle', (tester) async {
    await _open(tester, _page());

    await _tapSlot(tester, 2);

    expect(sheetEntry('Ahri'), findsOneWidget);
    expect(sheetEntry('Garen'), findsNothing);
  });

  testWidgets('sans profil de voies, la feuille n a pas de puces', (
    tester,
  ) async {
    await _open(tester, _page(loadProfile: () async => null));

    await _tapSlot(tester, 0);

    expect(sheetText('Tous'), findsNothing);
    expect(sheetEntry('Garen'), findsOneWidget);
    expect(sheetEntry('Lux'), findsOneWidget);
  });

  testWidgets('place un champion et affiche l analyse de l équipe', (
    tester,
  ) async {
    await _open(tester, _page());

    await _tapSlot(tester, 0);
    await tester.tap(sheetEntry('Garen'));
    await settle(tester);

    expect(find.text('Garen'), findsOneWidget);
    expect(find.text(_emptySlotLabel), findsNWidgets(4));
    expect(find.text(_emptyAnalysis), findsNothing);
    expect(find.text('DÉGÂTS'), findsOneWidget);
    expect(find.text('BILAN'), findsOneWidget);
    expect(find.byType(DamageSplitBar), findsOneWidget);
    expect(find.byType(InsightTile), findsWidgets);
    expect(find.byTooltip("Vider l'équipe"), findsOneWidget);
  });

  testWidgets('un champion déjà placé n est plus proposé', (tester) async {
    await _open(tester, _page());

    await _tapSlot(tester, 0);
    await tester.tap(sheetEntry('Garen'));
    await settle(tester);

    await _tapSlot(tester, 0);
    await tester.tap(sheetText('Tous'));
    await settle(tester);

    expect(sheetEntry('Garen'), findsNothing);
    expect(sheetEntry('Ahri'), findsOneWidget);
  });

  testWidgets('une fiche introuvable garde le champion sans analyse', (
    tester,
  ) async {
    await _open(
      tester,
      _page(loadDetail: (id) async => throw Exception('hors ligne')),
    );

    await _tapSlot(tester, 0);
    await tester.tap(sheetEntry('Garen'));
    await settle(tester);

    expect(find.text('Garen'), findsOneWidget);
    expect(find.text('Chargement impossible pour le moment.'), findsOneWidget);
    expect(find.text(_emptyAnalysis), findsOneWidget);
    expect(find.text('DÉGÂTS'), findsNothing);
  });

  testWidgets('vider l équipe remet les cinq cases à vide', (tester) async {
    await _open(tester, _page());

    await _tapSlot(tester, 0);
    await tester.tap(sheetEntry('Garen'));
    await settle(tester);

    await tester.tap(find.byTooltip("Vider l'équipe"));
    await settle(tester);

    expect(find.text(_emptySlotLabel), findsNWidgets(5));
    expect(find.text(_emptyAnalysis), findsOneWidget);
    expect(find.byTooltip("Vider l'équipe"), findsNothing);
  });
}
