import 'package:flutter/material.dart';
import 'champions/services/favorites_service.dart';
import 'theme/app_theme.dart';
import 'main_navigation/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Les favoris sont relus du disque avant le premier rendu : sans ça, les
  // étoiles des cartes s'allumeraient après coup.
  await FavoritesService.ensureLoaded();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoL App',
      theme: AppTheme.theme,
      home: const MainNavigation(),
    );
  }
}
