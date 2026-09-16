import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/champion_detail/widgets/matchup_section/matchup_section.dart';
import 'package:monapp/champions/models/champion.dart';
import 'package:monapp/matchups/models/matchup.dart';
import 'package:monapp/matchups/services/matchup_service.dart';

/// Monte la section avec le fichier reellement genere : prouve la chaine
/// complete, du JSON au widget, sur un champion tres joue.
void main() {
  final dataset = MatchupDataset.fromJson(
    jsonDecode(File('assets/data/champion_matchups.json').readAsStringSync())
        as Map<String, dynamic>,
  );
  final ids = dataset.matchups.map((m) => m.championId).toSet();
  final champions = ids
      .map(
        (id) => Champion(
          id: id,
          name: id,
          title: '',
          blurb: '',
          imageUrl: 'https://example.invalid/$id.png',
          tags: const [],
        ),
      )
      .toList();

  testWidgets('affiche des matchups reels pour Tristana', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: MatchupSection(
              championId: 'Tristana',
              dataset: dataset,
              champions: champions,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final hardest = MatchupService.hardestFor('Tristana', dataset);
    expect(hardest, isNotEmpty, reason: 'Tristana est tres jouee en bot');

    expect(find.text('DIFFICILE CONTRE'), findsOneWidget);
    expect(find.textContaining('parties'), findsWidgets);
    expect(find.textContaining('%'), findsWidgets);
    expect(find.textContaining('Pas encore de donn'), findsNothing);
  });

  test('aucune paire ne cite un champion inconnu de Data Dragon', () {
    expect(ids, isNot(contains('FiddleSticks')));
    expect(ids, contains('Fiddlesticks'));
  });
}
