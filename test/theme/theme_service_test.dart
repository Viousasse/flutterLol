import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/theme/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('relit le mode enregistré et l enregistre à chaque changement', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'light'});

    await ThemeService.ensureLoaded();
    expect(ThemeService.mode.value, ThemeMode.light);

    await ThemeService.setMode(ThemeMode.dark);
    expect(ThemeService.mode.value, ThemeMode.dark);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme_mode'), 'dark');
  });

  test('prévient ceux qui écoutent quand le mode change', () async {
    var notifications = 0;
    ThemeService.mode.addListener(() => notifications++);

    await ThemeService.setMode(ThemeMode.light);
    await ThemeService.setMode(ThemeMode.system);

    expect(notifications, 2);
  });

  test('le mode automatique suit l appareil, les autres l ignorent', () {
    expect(
      ThemeService.resolve(ThemeMode.system, Brightness.dark),
      Brightness.dark,
    );
    expect(
      ThemeService.resolve(ThemeMode.system, Brightness.light),
      Brightness.light,
    );
    expect(
      ThemeService.resolve(ThemeMode.light, Brightness.dark),
      Brightness.light,
    );
    expect(
      ThemeService.resolve(ThemeMode.dark, Brightness.light),
      Brightness.dark,
    );
  });
}
