import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'main_navigation/main_navigation.dart';

void main() {
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
