import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/matchups/models/matchup.dart';

import '../../tool/matchup_tally.dart';

void main() {
  group('comparePatches', () {
    test('compare numériquement, pas alphabétiquement', () {
      expect(comparePatches('16.9', '16.10'), isNegative);
      expect(comparePatches('16.19', '16.19'), 0);
      expect(comparePatches('17.1', '16.24'), isPositive);
    });

    test('isBeforePatch est strict et épargne les patchs illisibles', () {
      expect(isBeforePatch('16.18', '16.19'), isTrue);
      expect(isBeforePatch('16.19', '16.19'), isFalse);
      expect(isBeforePatch('16.20', '16.19'), isFalse);
      expect(isBeforePatch('?', '16.19'), isFalse);
    });
  });

  group('decayTally', () {
    test('arrondit, borne les victoires et retire les paires vides', () {
      final source = {
        'A|B|TOP': Tally.of(10, 7),
        'C|D|MIDDLE': Tally.of(1, 1),
        'E|F|JUNGLE': Tally.of(3, 3),
      };

      final aged = decayTally(source, 0.5);

      expect(aged['A|B|TOP']!.games, 5);
      expect(aged['A|B|TOP']!.wins, 4);
      expect(aged.containsKey('C|D|MIDDLE'), isTrue);
      expect(aged['E|F|JUNGLE']!.wins, lessThanOrEqualTo(2));
      expect(decayTally(source, 0.2).containsKey('C|D|MIDDLE'), isFalse);
    });

    test('un facteur de 1 ne change rien et la source est intacte', () {
      final source = {'A|B|TOP': Tally.of(10, 7)};

      final aged = decayTally(source, 1);

      expect(aged['A|B|TOP']!.games, 10);
      expect(aged['A|B|TOP']!.wins, 7);
      decayTally(source, 0.1);
      expect(source['A|B|TOP']!.games, 10);
    });

    test('wins ne dépasse jamais games', () {
      final aged = decayTally({'A|B|TOP': Tally.of(2, 2)}, 0.74);

      expect(aged['A|B|TOP']!.wins, lessThanOrEqualTo(aged['A|B|TOP']!.games));
    });
  });

  group('fusion', () {
    test('mergeTally additionne et crée les paires absentes', () {
      final target = {'A|B|TOP': Tally.of(2, 1)};

      mergeTally(target, {
        'A|B|TOP': Tally.of(3, 2),
        'C|D|TOP': Tally.of(1, 0),
      });

      expect(target['A|B|TOP']!.games, 5);
      expect(target['A|B|TOP']!.wins, 3);
      expect(target['C|D|TOP']!.games, 1);
    });

    test('mergePatches additionne patch par patch', () {
      final target = {'16.19': 10};

      mergePatches(target, {'16.19': 5, '16.18': 2});

      expect(target, {'16.19': 15, '16.18': 2});
    });

    test('decayPatches retire les patchs tombés à zéro', () {
      expect(decayPatches({'16.16': 1, '16.19': 100}, 0.3), {'16.19': 30});
    });
  });

  group('patchRange', () {
    test('deux patchs identiques restent un seul patch', () {
      expect(patchRange('16.19', '16.19'), '16.19');
    });

    test('ordonne numériquement', () {
      expect(patchRange('16.10', '16.9'), '16.9–16.10');
    });

    test('accepte une plage déjà étiquetée', () {
      expect(patchRange('16.16–16.19', '16.20'), '16.16–16.20');
      expect(patchRange('16.16–16.19', '16.18'), '16.16–16.19');
    });

    test('un patch illisible ne casse pas', () {
      expect(patchRange('?', '16.19'), '16.19');
    });
  });

  test('MatchupDataset ignore le champ informatif patches', () {
    final dataset = MatchupDataset.fromJson({
      'patch': '16.16–16.19',
      'matches': 7600,
      'patches': {'16.19': 4045, '16.18': 1000},
      'matchups': [
        {
          'champion': 'Darius',
          'opponent': 'Garen',
          'lane': 'TOP',
          'games': 10,
          'wins': 6,
        },
      ],
    });

    expect(dataset.patch, '16.16–16.19');
    expect(dataset.matches, 7600);
    expect(dataset.matchups, hasLength(1));
  });
}
