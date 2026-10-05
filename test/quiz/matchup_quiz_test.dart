import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/champions/models/champion.dart';
import 'package:monapp/items/models/item.dart';
import 'package:monapp/matchups/models/matchup.dart';
import 'package:monapp/matchups/services/matchup_service.dart';
import 'package:monapp/quiz/models/quiz_question.dart';
import 'package:monapp/quiz/services/duel_question_builder.dart';
import 'package:monapp/quiz/services/quiz_generator.dart';

const _ids = ['Ahri', 'Zed', 'Yasuo', 'Lux', 'Annie', 'Syndra', 'Veigar'];

List<Champion> _champions() {
  return _ids
      .map(
        (id) => Champion(
          id: id,
          name: id,
          title: '',
          blurb: '',
          imageUrl: 'https://example.invalid/$id.png',
          tags: const ['Mage'],
        ),
      )
      .toList();
}

Matchup _duel(
  String champion,
  String opponent,
  int wins, {
  int games = 100,
  String lane = 'MIDDLE',
}) {
  return Matchup(
    championId: champion,
    opponentId: opponent,
    lane: lane,
    games: games,
    wins: wins,
  );
}

QuizData _data(List<Matchup> matchups) {
  return QuizData(
    champions: _champions(),
    items: const <Item>[],
    matchups: MatchupDataset(patch: '16.1', matches: 1000, matchups: matchups),
  );
}

/// Tous les champions affrontent Ahri avec des taux bien étagés : de quoi
/// poser les deux familles de questions.
List<Matchup> _ladder() {
  return [
    _duel('Zed', 'Ahri', 62),
    _duel('Yasuo', 'Ahri', 55),
    _duel('Lux', 'Ahri', 49),
    _duel('Annie', 'Ahri', 40),
    _duel('Syndra', 'Ahri', 35),
  ];
}

Matchup? _find(QuizData data, String champion, String opponent) {
  return data.matchups.matchups
      .where((m) => m.championId == champion && m.opponentId == opponent)
      .firstOrNull;
}

List<QuizQuestion> _draw(QuizData data, int seed, {int count = 40}) {
  final generator = QuizGenerator(data, seed: seed);

  return [
    for (var i = 0; i < count; i++)
      ?generator.next(category: QuizCategory.matchups),
  ];
}

void main() {
  group('questions de duel', () {
    test('la bonne réponse est la meilleure des propositions', () {
      final data = _data(_ladder());

      for (final question in _draw(data, 1)) {
        // Le taux de chaque proposition contre la cible de la question.
        final target = _ids.firstWhere((id) => question.prompt.contains(id));
        double rateOf(String champion) {
          return (_find(data, champion, target) ??
                  _find(data, target, champion))!
              .winRate;
        }

        if (question.options.length > 2) {
          final best = question.answer.label;
          for (final option in question.options) {
            if (option.label == best) continue;
            expect(
              rateOf(best) - rateOf(option.label),
              greaterThanOrEqualTo(DuelQuestionBuilder.minGap - 1e-9),
              reason: question.prompt,
            );
          }
        }
      }
    });

    test('un face-à-face a deux choix et le vainqueur net pour réponse', () {
      final data = _data([_duel('Zed', 'Ahri', 62), _duel('Ahri', 'Zed', 38)]);
      final questions = _draw(data, 2, count: 10);

      expect(questions, isNotEmpty);
      for (final question in questions) {
        expect(question.options, hasLength(2));
        expect(question.answer.label, 'Zed');
        expect(question.prompt, startsWith('En Mid, qui gagne'));
      }
    });

    test('les chiffres sont dans l explication, pas dans l énoncé', () {
      final data = _data([_duel('Zed', 'Ahri', 29, games: 46)]);
      final question = _draw(data, 3, count: 1).single;

      expect(
        question.explanation,
        'Zed gagne 63 % de ses duels contre Ahri (46 parties).',
      );
      expect(question.prompt, isNot(contains('%')));
    });

    test('un duel trop peu joué est écarté', () {
      final data = _data([
        _duel('Zed', 'Ahri', 10, games: MatchupService.minGames - 1),
      ]);

      expect(_draw(data, 4), isEmpty);
    });

    test('un écart trop faible ne donne aucune question', () {
      final data = _data([
        _duel('Zed', 'Ahri', 52),
        _duel('Yasuo', 'Ahri', 51),
        _duel('Lux', 'Ahri', 50),
      ]);

      expect(_draw(data, 5), isEmpty);
    });

    test('les données insuffisantes ne produisent aucune question', () {
      expect(_draw(_data(const []), 6), isEmpty);
      // Deux champions seulement : pas de quoi faire un choix à trois.
      expect(_draw(_data([_duel('Zed', 'Ahri', 40)]), 6), isEmpty);
    });

    test('un champion inconnu de la liste ne sort jamais', () {
      final data = _data([_duel('Inconnu', 'Ahri', 70)]);

      expect(_draw(data, 7), isEmpty);
    });

    test('aucun champion ne figure deux fois dans une question', () {
      final data = _data(_ladder());

      for (final question in _draw(data, 8)) {
        final labels = question.options.map((o) => o.label).toList();
        expect(labels.toSet(), hasLength(labels.length));
        expect(labels.length, inInclusiveRange(2, 4));

        // La cible d'un « contre X » n'est pas une proposition.
        if (labels.length > 2) {
          expect(labels, isNot(contains('Ahri')));
        }
      }
    });

    test('reproductible avec la même graine', () {
      final data = _data(_ladder());

      List<String> run(int seed) => _draw(
        data,
        seed,
      ).map((q) => '${q.prompt}|${q.answerIndex}|${q.options.length}').toList();

      expect(run(42), run(42));
    });

    test('pas de doublon dans une même série', () {
      final data = _data([
        ..._ladder(),
        _duel('Zed', 'Lux', 60),
        _duel('Yasuo', 'Lux', 58),
        _duel('Veigar', 'Lux', 40),
        _duel('Annie', 'Lux', 35),
        _duel('Syndra', 'Lux', 33),
      ]);
      final generator = QuizGenerator(data, seed: 9);

      // Trois énoncés distincts possibles au moins : on ne boucle pas dessus
      // tant qu'il en reste d'autres.
      final seen = <String>{};
      for (var i = 0; i < 4; i++) {
        final question = generator.next(category: QuizCategory.matchups)!;
        expect(seen.add(question.prompt), isTrue, reason: question.prompt);
      }
    });

    test('la famille disparaît sans données de duels', () {
      final without = _data(const []).matchups.isEmpty;
      expect(without, isTrue);

      expect(
        QuizGenerator(_data(const [])).availableCategories(),
        isNot(contains(QuizCategory.matchups)),
      );
      expect(
        QuizGenerator(_data(_ladder())).availableCategories(),
        contains(QuizCategory.matchups),
      );
    });
  });
}
