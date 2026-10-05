import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/draft/models/draft_report.dart';
import 'package:monapp/draft/models/draft_state.dart';
import 'package:monapp/draft/services/friend_session_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FriendSessionStore.reset();
  });

  FriendSession current() => FriendSessionStore.session.value;

  test('démarre sur les noms par défaut et un score vide', () async {
    await FriendSessionStore.ensureLoaded();

    expect(current().players.blue, 'Joueur 1');
    expect(current().players.red, 'Joueur 2');
    expect(current().isScoreEmpty, isTrue);
  });

  test('renomme un joueur en retirant les espaces', () async {
    await FriendSessionStore.rename(DraftSide.blue, '  Léa ');

    expect(current().players.blue, 'Léa');
    expect(current().players.red, 'Joueur 2');
  });

  test(
    'refuse un nom vide ou celui de l autre joueur sans rien changer',
    () async {
      await FriendSessionStore.rename(DraftSide.blue, 'Léa');
      await FriendSessionStore.rename(DraftSide.blue, '   ');
      await FriendSessionStore.rename(DraftSide.red, ' léa ');

      expect(current().players.blue, 'Léa');
      expect(current().players.red, 'Joueur 2');
    },
  );

  test('compte les victoires et les égalités', () async {
    await FriendSessionStore.recordResult(DraftWinner.blue);
    await FriendSessionStore.recordResult(DraftWinner.blue);
    await FriendSessionStore.recordResult(DraftWinner.red);
    await FriendSessionStore.recordResult(DraftWinner.tie);

    expect(current().blueWins, 2);
    expect(current().redWins, 1);
    expect(current().ties, 1);
  });

  test('renommer un joueur garde le score', () async {
    await FriendSessionStore.recordResult(DraftWinner.red);
    await FriendSessionStore.rename(DraftSide.red, 'Tom');

    expect(current().redWins, 1);
    expect(current().players.red, 'Tom');
  });

  test('resetScore remet les compteurs à zéro et garde les noms', () async {
    await FriendSessionStore.rename(DraftSide.blue, 'Léa');
    await FriendSessionStore.recordResult(DraftWinner.blue);
    await FriendSessionStore.recordResult(DraftWinner.tie);
    await FriendSessionStore.resetScore();

    expect(current().isScoreEmpty, isTrue);
    expect(current().players.blue, 'Léa');
  });

  test('relit les noms et le score après un redémarrage', () async {
    await FriendSessionStore.rename(DraftSide.blue, 'Léa');
    await FriendSessionStore.rename(DraftSide.red, 'Tom');
    await FriendSessionStore.recordResult(DraftWinner.blue);
    await FriendSessionStore.recordResult(DraftWinner.tie);

    FriendSessionStore.reset();
    await FriendSessionStore.ensureLoaded();

    expect(current().players.blue, 'Léa');
    expect(current().players.red, 'Tom');
    expect(current().blueWins, 1);
    expect(current().ties, 1);
  });

  test('une entrée illisible redonne les valeurs par défaut', () async {
    SharedPreferences.setMockInitialValues({'friend_session': '{pas du json'});
    await FriendSessionStore.ensureLoaded();

    expect(current().players.blue, 'Joueur 1');
    expect(current().isScoreEmpty, isTrue);
  });

  test('une entrée de mauvaise forme redonne les valeurs par défaut', () async {
    SharedPreferences.setMockInitialValues({
      'friend_session':
          '{"blue":"Léa","red":"léa","blueWins":2,"redWins":1,"ties":0}',
    });
    await FriendSessionStore.ensureLoaded();

    expect(current().players.red, 'Joueur 2');
    expect(current().blueWins, 0);
  });
}
