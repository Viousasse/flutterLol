import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/draft_mode.dart';
import '../models/draft_report.dart';
import '../models/draft_state.dart';
import '../widgets/player_name_dialog/player_name_dialog.dart';

/// La soirée en cours entre deux joueurs : leurs noms et le score cumulé.
class FriendSession {
  final DraftPlayers players;
  final int blueWins;
  final int redWins;
  final int ties;

  const FriendSession({
    this.players = friendPlayers,
    this.blueWins = 0,
    this.redWins = 0,
    this.ties = 0,
  });

  bool get isScoreEmpty => blueWins == 0 && redWins == 0 && ties == 0;

  FriendSession copyWith({
    DraftPlayers? players,
    int? blueWins,
    int? redWins,
    int? ties,
  }) {
    return FriendSession(
      players: players ?? this.players,
      blueWins: blueWins ?? this.blueWins,
      redWins: redWins ?? this.redWins,
      ties: ties ?? this.ties,
    );
  }

  Map<String, dynamic> toJson() => {
    'blue': players.blue,
    'red': players.red,
    'blueWins': blueWins,
    'redWins': redWins,
    'ties': ties,
  };

  /// Relit une session sauvegardée ; renvoie `null` si le contenu n'a pas la
  /// forme attendue, pour que l'appelant reparte des valeurs par défaut.
  static FriendSession? tryFromJson(Object? json) {
    if (json is! Map) return null;

    final blue = json['blue'];
    final red = json['red'];
    final blueWins = json['blueWins'];
    final redWins = json['redWins'];
    final ties = json['ties'];
    if (blue is! String || red is! String) return null;
    if (blueWins is! int || redWins is! int || ties is! int) return null;
    if (blueWins < 0 || redWins < 0 || ties < 0) return null;

    // Les noms doivent rester valables : un fichier abîmé ne doit pas
    // réintroduire un nom vide ou deux noms identiques.
    final blueName = blue.trim();
    final redName = red.trim();
    if (validatePlayerName(blueName, otherName: redName) != null) return null;
    if (validatePlayerName(redName, otherName: blueName) != null) return null;

    return FriendSession(
      players: DraftPlayers(blue: blueName, red: redName),
      blueWins: blueWins,
      redWins: redWins,
      ties: ties,
    );
  }
}

/// Les noms et le score de la soirée, conservés entre deux lancements.
///
/// Même forme que [DraftHistoryStore] : un [ValueNotifier] que l'écran écoute.
class FriendSessionStore {
  static const _key = 'friend_session';

  static final ValueNotifier<FriendSession> session = ValueNotifier(
    const FriendSession(),
  );

  static Future<void>? _loading;
  static Future<void> _writeQueue = Future.value();

  /// Remet le stockage dans l'état d'un premier lancement. Sert aux tests.
  @visibleForTesting
  static void reset() {
    _loading = null;
    _writeQueue = Future.value();
    session.value = const FriendSession();
  }

  static Future<void> ensureLoaded() {
    final loading = _loading;
    if (loading != null) return loading;

    final request = _load();
    _loading = request;

    return request;
  }

  static Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;

      session.value = _decode(raw) ?? const FriendSession();
    } catch (_) {
      // Stockage indisponible : on démarre sur les valeurs par défaut, et le
      // prochain appel pourra retenter.
      _loading = null;
    }
  }

  static FriendSession? _decode(String raw) {
    try {
      return FriendSession.tryFromJson(jsonDecode(raw));
    } on FormatException {
      return null;
    }
  }

  /// Renomme un joueur. Un nom vide ou déjà pris par l'autre est ignoré sans
  /// erreur : l'écran a déjà validé la saisie. Le score est conservé, c'est la
  /// même soirée.
  static Future<void> rename(DraftSide side, String name) async {
    await ensureLoaded();

    final current = session.value;
    final trimmed = name.trim();
    final other = current.players.of(
      side == DraftSide.blue ? DraftSide.red : DraftSide.blue,
    );
    if (validatePlayerName(trimmed, otherName: other) != null) return;

    final players = side == DraftSide.blue
        ? DraftPlayers(blue: trimmed, red: current.players.red)
        : DraftPlayers(blue: current.players.blue, red: trimmed);

    await _update(current.copyWith(players: players));
  }

  static Future<void> recordResult(DraftWinner winner) async {
    await ensureLoaded();

    final current = session.value;
    await _update(switch (winner) {
      DraftWinner.blue => current.copyWith(blueWins: current.blueWins + 1),
      DraftWinner.red => current.copyWith(redWins: current.redWins + 1),
      DraftWinner.tie => current.copyWith(ties: current.ties + 1),
    });
  }

  static Future<void> resetScore() async {
    await ensureLoaded();

    await _update(session.value.copyWith(blueWins: 0, redWins: 0, ties: 0));
  }

  static Future<void> _update(FriendSession updated) {
    session.value = updated;

    return _persist(updated);
  }

  /// Les écritures s'enchaînent pour ne pas se doubler, et une écriture en
  /// échec ne rompt pas la file.
  static Future<void> _persist(FriendSession updated) {
    final encoded = jsonEncode(updated.toJson());

    _writeQueue = _writeQueue.then((_) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_key, encoded);
      } catch (_) {
        // L'état en mémoire reste juste ; seule la sauvegarde est perdue.
      }
    });

    return _writeQueue;
  }
}
