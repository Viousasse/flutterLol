import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mode d'affichage choisi par l'utilisateur, conservé entre deux lancements.
///
/// Par défaut l'application suit le réglage de l'appareil.
class ThemeService {
  static const _key = 'theme_mode';

  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.system);

  static Future<void>? _loading;

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
      mode.value = _decode(prefs.getString(_key));
    } catch (_) {
      // Stockage indisponible : on suit l'appareil plutôt que de planter, et
      // le prochain appel pourra retenter.
      _loading = null;
    }
  }

  static Future<void> setMode(ThemeMode next) async {
    mode.value = next;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, next.name);
    } catch (_) {
      // Le choix reste appliqué pour cette session même s'il n'est pas gardé.
    }
  }

  static ThemeMode _decode(String? stored) {
    for (final candidate in ThemeMode.values) {
      if (candidate.name == stored) return candidate;
    }

    return ThemeMode.system;
  }

  /// Mode effectif : celui de l'appareil quand l'utilisateur n'a rien choisi.
  static Brightness resolve(ThemeMode chosen, Brightness device) {
    switch (chosen) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return device;
    }
  }
}
