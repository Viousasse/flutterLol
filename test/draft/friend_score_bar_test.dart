import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/draft/models/draft_report.dart';
import 'package:monapp/draft/services/friend_session_store.dart';
import 'package:monapp/draft/widgets/friend_score_bar/friend_score_bar.dart';

const _players = DraftPlayers(blue: 'Léa', red: 'Tom');

Widget _host(FriendSession session, VoidCallback onReset) {
  return MaterialApp(
    home: Scaffold(
      body: FriendScoreBar(session: session, onReset: onReset),
    ),
  );
}

void main() {
  testWidgets('affiche le score sous la forme « Léa 3 – 2 Tom »', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const FriendSession(players: _players, blueWins: 3, redWins: 2),
        () {},
      ),
    );

    expect(find.text('Léa 3 – 2 Tom'), findsOneWidget);
  });

  testWidgets('masque les égalités à zéro et les accorde au pluriel', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const FriendSession(players: _players, blueWins: 1), () {}),
    );
    expect(find.textContaining('égalité'), findsNothing);

    await tester.pumpWidget(
      _host(const FriendSession(players: _players, ties: 1), () {}),
    );
    expect(find.text('1 égalité'), findsOneWidget);

    await tester.pumpWidget(
      _host(const FriendSession(players: _players, ties: 2), () {}),
    );
    expect(find.text('2 égalités'), findsOneWidget);
  });

  testWidgets('le bouton remet le score à zéro quand il y a un score', (
    tester,
  ) async {
    var resets = 0;
    await tester.pumpWidget(
      _host(
        const FriendSession(players: _players, blueWins: 1),
        () => resets++,
      ),
    );

    await tester.tap(find.byTooltip('Remettre le score à zéro'));

    expect(resets, 1);
    final size = tester.getSize(find.byType(IconButton));
    expect(size.width, greaterThanOrEqualTo(44));
    expect(size.height, greaterThanOrEqualTo(44));
  });

  testWidgets('le bouton est désactivé quand le score est à zéro', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const FriendSession(players: _players), () {}),
    );

    final button = tester.widget<IconButton>(find.byType(IconButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('annonce le score complet aux lecteurs d écran', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        const FriendSession(
          players: _players,
          blueWins: 3,
          redWins: 2,
          ties: 1,
        ),
        () {},
      ),
    );

    expect(
      find.bySemanticsLabel('Score de la soirée : Léa 3, Tom 2, 1 égalité'),
      findsOneWidget,
    );
    handle.dispose();
  });
}
