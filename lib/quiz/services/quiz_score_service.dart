import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Meilleure série de bonnes réponses, conservée entre deux lancements.
///
/// Même forme que les favoris : un [ValueNotifier] que l'écran écoute, pour
/// qu'un record battu s'affiche sans que personne ait à recharger.
class QuizScoreService {
  static const _key = 'quiz_best_streak';

  static final ValueNotifier<int> bestStreak = ValueNotifier(0);

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

  /// Une écriture en échec ne doit pas rompre la file, sinon les suivantes
  /// échoueraient toutes à leur tour.
  static Future<void> _persist(int streak) {
    final write = _writeQueue.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key, streak);
    });

    _writeQueue = write.catchError((_) {});

    return _writeQueue;
  }
}
