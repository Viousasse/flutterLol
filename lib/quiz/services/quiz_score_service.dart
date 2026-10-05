import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Meilleure série de bonnes réponses, conservée entre deux lancements.
///
/// Même forme que les favoris : un [ValueNotifier] que l'écran écoute, pour
/// qu'un record battu s'affiche sans que personne ait à recharger.
class QuizScoreService {
  static const _key = 'quiz_best_streak';

  static const _recentKey = 'quiz_recent_streaks';

  /// Au-delà, la liste ne tient plus sur une ligne de l'écran du quiz.
  static const maxRecentStreaks = 8;

  static final ValueNotifier<int> bestStreak = ValueNotifier(0);

  /// Séries terminées, de la plus récente à la plus ancienne.
  static final ValueNotifier<List<int>> recentStreaks = ValueNotifier(
    const <int>[],
  );

  static Future<void>? _loading;
  static Future<void> _writeQueue = Future.value();

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
      bestStreak.value = prefs.getInt(_key) ?? 0;
      recentStreaks.value = (prefs.getStringList(_recentKey) ?? const [])
          .map(int.tryParse)
          .whereType<int>()
          .toList();
    } catch (_) {
      // Stockage indisponible : on démarre à zéro plutôt que de planter, et
      // le prochain appel pourra retenter.
      _loading = null;
    }
  }

  /// Retient [streak] si elle dépasse le record. Rend vrai dans ce cas.
  static Future<bool> submit(int streak) async {
    await ensureLoaded();
    if (streak <= bestStreak.value) return false;

    bestStreak.value = streak;
    await _persist(streak);

    return true;
  }

  /// Garde une série qui vient de se terminer sur une mauvaise réponse ou un
  /// temps écoulé. Une série de zéro n'est pas une série : elle n'est pas
  /// retenue.
  static Future<void> recordFinished(int streak) async {
    if (streak <= 0) return;
    await ensureLoaded();

    final updated = [
      streak,
      ...recentStreaks.value,
    ].take(maxRecentStreaks).toList();
    recentStreaks.value = updated;

    await _enqueue((prefs) async {
      await prefs.setStringList(
        _recentKey,
        updated.map((value) => '$value').toList(),
      );
    });
  }

  static Future<void> _persist(int streak) {
    return _enqueue((prefs) => prefs.setInt(_key, streak));
  }

  /// Une écriture en échec ne doit pas rompre la file, sinon les suivantes
  /// échoueraient toutes à leur tour.
  static Future<void> _enqueue(
    Future<void> Function(SharedPreferences prefs) write,
  ) {
    final pending = _writeQueue.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      await write(prefs);
    });

    _writeQueue = pending.catchError((_) {});

    return _writeQueue;
  }
}
