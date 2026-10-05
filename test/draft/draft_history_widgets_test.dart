import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/draft/models/draft_record.dart';
import 'package:monapp/draft/models/draft_report.dart';
import 'package:monapp/draft/services/draft_history_stats.dart';
import 'package:monapp/draft/widgets/ban_row/ban_row.dart';
import 'package:monapp/draft/widgets/draft_history_tile/draft_history_tile.dart';
import 'package:monapp/draft/widgets/draft_stats_card/draft_stats_card.dart';

import 'draft_support.dart';

DraftRecord _record({
  DraftWinner winner = DraftWinner.blue,
  bool versusFriend = false,
  bool assisted = false,
  bool imported = false,
}) {
  final blue = ['Ahri', 'Garen', 'Lux', 'Jinx', 'Thresh'];
  final red = ['Zed', 'Fizz', 'Yone', 'Ashe', 'Nami'];

  return DraftRecord(
    id: 'a',
    playedAt: DateTime(2026, 10, 5, 9, 5),
    versusFriend: versusFriend,
    blueName: versusFriend ? 'Léa' : 'Vous',
    redName: versusFriend ? 'Tom' : 'Le site',
    blue: blue,
    red: red,
    blueBans: const [],
    redBans: const [],
    championNames: {
      for (final id in [...blue, ...red]) id: id,
    },
    winner: winner,
    blueScore: 3,
    redScore: 2,
    verdict: '',
    assisted: assisted,
    imported: imported,
  );
}

Widget _host(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('BanRow', () {
    testWidgets('ne montre rien quand il n y a pas de bannissements', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const BanRow(owner: 'vous', bans: [])));

      expect(find.byIcon(Icons.block), findsNothing);
    });

    testWidgets('invite à bannir sur la première case libre seulement', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          BanRow(
            owner: 'vous',
            bans: [champion('Zed'), null, null],
            onTap: () => taps++,
          ),
        ),
      );

      // Une case remplie (barrée) et une case libre qui invite : deux icônes
      // « interdit ». La dernière case, pas encore à jouer, reste un tiret.
      expect(find.byIcon(Icons.block), findsNWidgets(2));
      expect(find.byIcon(Icons.remove), findsOneWidget);

      await tester.tap(find.byType(BanRow));
      expect(taps, 1);
    });

    testWidgets('décrit les bans aux lecteurs d écran', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(BanRow(owner: 'Léa', bans: [champion('Zed'), null])),
      );

      expect(
        find.bySemanticsLabel('Bannissements de Léa : Zed, libre'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('DraftStatsCard', () {
    testWidgets('résume le bilan contre le site', (tester) async {
      final stats = DraftHistoryStats.of([
        _record(),
        _record(winner: DraftWinner.red),
      ]);
      await tester.pumpWidget(
        _host(DraftStatsCard(stats: stats, imageUrls: const {})),
      );

      expect(find.text('2 drafts jouées'), findsOneWidget);
      expect(
        find.textContaining('1 victoire, 0 égalité, 1 défaite'),
        findsOneWidget,
      );
      expect(find.textContaining('(50 %)'), findsOneWidget);
      expect(find.text('LES PLUS CHOISIS'), findsOneWidget);
    });

    testWidgets('signale les drafts avec aide, non comptées dans le taux', (
      tester,
    ) async {
      final stats = DraftHistoryStats.of([_record(), _record(assisted: true)]);
      await tester.pumpWidget(
        _host(DraftStatsCard(stats: stats, imageUrls: const {})),
      );

      expect(
        find.text('dont 1 avec aide (non comptées dans le taux)'),
        findsOneWidget,
      );
      expect(find.textContaining('(100 %)'), findsOneWidget);
    });

    testWidgets('sans draft avec aide, n en parle pas', (tester) async {
      final stats = DraftHistoryStats.of([_record()]);
      await tester.pumpWidget(
        _host(DraftStatsCard(stats: stats, imageUrls: const {})),
      );

      expect(find.textContaining('avec aide'), findsNothing);
    });

    testWidgets('sans draft contre le site, ne donne pas de taux', (
      tester,
    ) async {
      final stats = DraftHistoryStats.of([_record(versusFriend: true)]);
      await tester.pumpWidget(
        _host(DraftStatsCard(stats: stats, imageUrls: const {})),
      );

      expect(find.text('1 draft jouée'), findsOneWidget);
      expect(find.text('Aucune draft contre le site'), findsOneWidget);
    });
  });

  group('DraftHistoryTile', () {
    testWidgets('affiche les joueurs, le vainqueur et la date', (tester) async {
      await tester.pumpWidget(
        _host(
          DraftHistoryTile(
            record: _record(versusFriend: true, winner: DraftWinner.red),
            imageUrls: const {},
            onShare: () {},
            onDelete: () {},
          ),
        ),
      );

      expect(find.text('Léa contre Tom'), findsOneWidget);
      expect(find.textContaining('Victoire de Tom'), findsOneWidget);
      expect(find.textContaining('5 oct. 2026, 9 h 05'), findsOneWidget);
    });

    testWidgets('contre le site, parle au joueur plutôt que de le nommer', (
      tester,
    ) async {
      for (final (winner, text) in [
        (DraftWinner.blue, 'Vous l’emportez'),
        (DraftWinner.red, 'Le site l’emporte'),
        (DraftWinner.tie, 'Égalité'),
      ]) {
        await tester.pumpWidget(
          _host(
            DraftHistoryTile(
              record: _record(winner: winner),
              imageUrls: const {},
              onShare: () {},
              onDelete: () {},
            ),
          ),
        );

        expect(find.textContaining(text), findsOneWidget);
      }
    });

    testWidgets('renvoie les appuis sur partager et supprimer', (tester) async {
      var shared = 0;
      var deleted = 0;
      await tester.pumpWidget(
        _host(
          DraftHistoryTile(
            record: _record(),
            imageUrls: const {},
            onShare: () => shared++,
            onDelete: () => deleted++,
          ),
        ),
      );

      await tester.tap(find.byTooltip('Copier le résumé de cette draft'));
      await tester.tap(find.byTooltip('Supprimer cette draft'));

      expect(shared, 1);
      expect(deleted, 1);
    });

    testWidgets('étiquette « avec aide » et s ouvre au toucher', (
      tester,
    ) async {
      var opened = 0;
      await tester.pumpWidget(
        _host(
          DraftHistoryTile(
            record: _record(assisted: true),
            imageUrls: const {},
            onShare: () {},
            onDelete: () {},
            onTap: () => opened++,
          ),
        ),
      );

      expect(find.text('AVEC AIDE'), findsOneWidget);

      await tester.tap(find.text('Vous contre Le site'));
      expect(opened, 1);
    });

    testWidgets('sans aide, pas d étiquette', (tester) async {
      await tester.pumpWidget(
        _host(
          DraftHistoryTile(
            record: _record(),
            imageUrls: const {},
            onShare: () {},
            onDelete: () {},
          ),
        ),
      );

      expect(find.text('AVEC AIDE'), findsNothing);
    });

    testWidgets('a un seul libellé sémantique pour la tuile', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          DraftHistoryTile(
            record: _record(),
            imageUrls: const {},
            onShare: () {},
            onDelete: () {},
            onTap: () {},
          ),
        ),
      );

      expect(
        find.bySemanticsLabel(
          'Vous contre Le site, Vous l’emportez, 5 oct. 2026, 9 h 05',
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    test('formate une date avec des minutes sur deux chiffres', () {
      expect(
        formatDraftDate(DateTime(2026, 1, 3, 14, 7)),
        '3 janv. 2026, 14 h 07',
      );
    });
  });

  group('drafts importées', () {
    testWidgets('la tuile porte l étiquette IMPORTÉE', (tester) async {
      await tester.pumpWidget(
        _host(
          DraftHistoryTile(
            record: _record(imported: true, assisted: true),
            imageUrls: const {},
            onShare: () {},
            onDelete: () {},
          ),
        ),
      );

      expect(find.text('IMPORTÉE'), findsOneWidget);
      expect(find.text('AVEC AIDE'), findsOneWidget);
    });

    testWidgets('le bilan compte les importées à part', (tester) async {
      final stats = DraftHistoryStats.of([_record(), _record(imported: true)]);
      await tester.pumpWidget(
        _host(DraftStatsCard(stats: stats, imageUrls: const {})),
      );

      expect(
        find.text('dont 1 importée (non comptées dans le taux)'),
        findsOneWidget,
      );
    });
  });
}
