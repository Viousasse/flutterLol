import 'package:flutter/material.dart';
import 'champions/services/favorites_service.dart';
import 'items/services/item_favorites_service.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'theme/theme_service.dart';
import 'main_navigation/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Les favoris et le mode d'affichage sont relus du disque avant le premier
  // rendu : sans ça, les étoiles des cartes s'allumeraient après coup et
  // l'application s'ouvrirait un instant dans le mauvais mode.
  await Future.wait([
    FavoritesService.ensureLoaded(),
    ItemFavoritesService.ensureLoaded(),
    ThemeService.ensureLoaded(),
  ]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late Brightness brightness = _resolveBrightness();

  @override
  void initState() {
    super.initState();
    AppColors.use(brightness);
    WidgetsBinding.instance.addObserver(this);
    ThemeService.mode.addListener(_applyBrightness);
  }

  @override
  void dispose() {
    ThemeService.mode.removeListener(_applyBrightness);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Le réglage de l'appareil change (mode sombre automatique au coucher du
  /// soleil, par exemple) : on suit si l'utilisateur n'a pas choisi de mode.
  @override
  void didChangePlatformBrightness() => _applyBrightness();

  Brightness _resolveBrightness() {
    return ThemeService.resolve(
      ThemeService.mode.value,
      WidgetsBinding.instance.platformDispatcher.platformBrightness,
    );
  }

  void _applyBrightness() {
    final next = _resolveBrightness();
    if (next == brightness) return;

    setState(() {
      brightness = next;
      AppColors.use(next);
    });

    // Les couleurs sont lues à la construction de chaque widget, et un widget
    // `const` n'est pas reconstruit quand son parent l'est. On marque donc tout
    // l'arbre comme à reconstruire : l'écran, la navigation et les saisies en
    // cours restent en place, seules les couleurs changent.
    (context as Element).visitChildren(_markNeedsBuild);
  }

  void _markNeedsBuild(Element element) {
    element.markNeedsBuild();
    element.visitChildren(_markNeedsBuild);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoL App',
      theme: AppTheme.themeFor(brightness),
      home: const MainNavigation(),
    );
  }
}
