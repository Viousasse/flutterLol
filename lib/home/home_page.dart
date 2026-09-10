import 'package:flutter/material.dart';
import 'widgets/hero_section/hero_section.dart';
import 'widgets/action_button/action_button.dart';
import '../champions/champions_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LoL App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HeroSection(),
            const SizedBox(height: 40),
            ActionButton(
              label: 'Voir les champions',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChampionsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
