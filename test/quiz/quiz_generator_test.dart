import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/champions/models/champion.dart';
import 'package:monapp/items/models/item.dart';
import 'package:monapp/items/models/item_profile.dart';
import 'package:monapp/matchups/models/matchup.dart';
import 'package:monapp/quiz/models/quiz_question.dart';
import 'package:monapp/quiz/services/quiz_generator.dart';
import 'package:monapp/regions/constants/champion_regions.dart';

const _places = [
  'aube',
  'brume',
  'cendre',
  'dune',
  'écume',
  'faille',
  'givre',
  'houle',
  'jungle',
  'lame',
  'marée',
  'nuit',
];

/// Champions bâtis sur la vraie table des régions, pour que les questions de
/// région aient de quoi travailler.
List<Champion> _champions() {
  var index = 0;

  return championRegions.keys.map((id) {
    // Un titre qui ne contient pas le nom, comme les vrais (« la Renarde à
    // neuf queues ») : sinon l'énoncé donnerait la réponse.
    final title = 'gardien de la ${_places[index++ % _places.length]}';

    return Champion(
      id: id,
      name: id,
      title: title,
      blurb:
          "$id est né dans une contrée lointaine où les siens ont longtemps "
          "vécu à l'abri du monde. On raconte qu'il n'a jamais renoncé, même "
          "quand tout l'y poussait.",
      imageUrl: 'https://example.invalid/$id.png',
      tags: const ['Fighter'],
    );
  }).toList();
}

List<Item> _items() {
  return List.generate(30, (index) {
    return Item(
      id: '${1000 + index}',
      name: 'Objet $index',
      description: '',
      plaintext: '',
      gold: 300 + index * 220,
      imageUrl: 'https://example.invalid/item$index.png',
      tier: ItemTier.legendary,
      profile: ItemProfile.other,
      componentIds: index > 2
          ? ['${1000 + index - 1}', '${1000 + index - 2}']
          : const [],
      upgradeIds: const [],
    );
  });
}

MatchupDataset _matchups() {
  return MatchupDataset.fromJson(
    jsonDecode(File('assets/data/champion_matchups.json').readAsStringSync())
        as Map<String, dynamic>,
  );
}

void main() {
  final data = QuizData(
    champions: _champions(),
    items: _items(),
    matchups: _matchups(),
  );

  test('chaque famille produit des questions bien formées', () {
    for (final category in QuizCategory.values) {
      final generator = QuizGenerator(data, seed: 1);

      for (var i = 0; i < 25; i++) {
        final question = generator.next(category: category);

        expect(question, isNotNull, reason: 'famille $category, tirage $i');
        expect(question!.category, category);
        expect(question.options, hasLength(QuizGenerator.optionCount));
        expect(question.answerIndex, inInclusiveRange(0, 3));
        expect(question.prompt.trim(), isNotEmpty);

        // Une proposition en double rendrait la question insoluble.
        final labels = question.options.map((o) => o.label).toSet();
        expect(
          labels,
          hasLength(QuizGenerator.optionCount),
          reason: question.prompt,
        );
      }
    }
  });

  test("l'énoncé ne contient jamais la réponse", () {
    final generator = QuizGenerator(data, seed: 7);

    for (var i = 0; i < 120; i++) {
      final question = generator.next();
      expect(question, isNotNull);

      final answer = question!.answer.label.toLowerCase();
      // Le prix est du chiffre : « 800 po » peut légitimement figurer ailleurs.
      if (answer.endsWith(' po')) continue;

      expect(
        question.prompt.toLowerCase(),
        isNot(contains(answer)),
        reason: question.prompt,
      );
    }
  });

  test('le tirage sans filtre couvre les quatre familles', () {
    final generator = QuizGenerator(data, seed: 3);
    final seen = <QuizCategory>{};

    for (var i = 0; i < 200; i++) {
      final question = generator.next();
      if (question != null) seen.add(question.category);
    }

    expect(seen, containsAll(QuizCategory.values));
  });

  test('deux questions de suite ne répètent pas le même énoncé', () {
    final generator = QuizGenerator(data, seed: 11);
    var previous = generator.next();

    for (var i = 0; i < 60; i++) {
      final next = generator.next(avoid: previous);
      expect(next!.prompt, isNot(previous!.prompt));
      previous = next;
    }
  });

  test('un jeu de données vide ne produit aucune question', () {
    final generator = QuizGenerator(
      const QuizData(
        champions: [],
        items: [],
        matchups: MatchupDataset.empty(),
      ),
    );

    expect(generator.next(), isNull);
  });

  test('les questions de matchup citent le nombre de parties', () {
    final generator = QuizGenerator(data, seed: 5);
    final question = generator.next(category: QuizCategory.matchups);

    expect(question!.explanation, contains('parties'));
  });
}
