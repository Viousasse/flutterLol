import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/draft/models/draft_record.dart';
import 'package:monapp/draft/models/draft_report.dart';
import 'package:monapp/draft/services/draft_share_code.dart';
import 'package:monapp/draft/services/draft_share_text.dart';
import 'package:monapp/shared/services/share_code/share_code.dart';
import 'package:monapp/team/constants/team_roles.dart';

DraftRecord _record() {
  final blue = [for (var i = 0; i < teamRoles.length; i++) 'B$i'];
  final red = ['R0', '', 'R2', 'R3', 'R4'];

  return DraftRecord(
    id: 'a',
    playedAt: DateTime(2026, 10, 5, 15, 42),
    versusFriend: true,
    blueName: 'Léa',
    redName: 'Tom',
    blue: blue,
    red: red,
    blueBans: ['X1', 'X2'],
    redBans: ['Y1'],
    championNames: {
      for (final id in [...blue, ...red, 'X1', 'X2', 'Y1'])
        if (id.isNotEmpty) id: 'Nom $id',
    },
    winner: DraftWinner.red,
    blueScore: 3.5,
    redScore: 4,
    verdict: 'La draft de Tom est meilleure.',
  );
}

/// Le contenu d'un code valide, pour en fabriquer des variantes abîmées.
Map<String, dynamic> _payload() {
  final code = DraftShareCode.encode(_record());
  final body = code.substring(DraftShareCode.prefix.length);
  final json = utf8.decode(base64Url.decode(base64Url.normalize(body)));

  return jsonDecode(json) as Map<String, dynamic>;
}

String _forge(Map<String, dynamic> payload) =>
    ShareCode.encode(DraftShareCode.prefix, payload);

void main() {
  test('un aller-retour redonne la même draft, avec un nouvel id', () {
    final original = _record();
    final decoded = DraftShareCode.decode(DraftShareCode.encode(original))!;

    expect(decoded.id, isNot(original.id));
    expect(decoded.playedAt, original.playedAt);
    expect(decoded.versusFriend, isTrue);
    expect(decoded.blueName, 'Léa');
    expect(decoded.redName, 'Tom');
    expect(decoded.blue, original.blue);
    expect(decoded.red, original.red);
    expect(decoded.blueBans, original.blueBans);
    expect(decoded.redBans, original.redBans);
    expect(decoded.championNames, original.championNames);
    expect(decoded.winner, DraftWinner.red);
    expect(decoded.blueScore, 3.5);
    expect(decoded.redScore, 4);
    expect(decoded.verdict, original.verdict);
  });

  test('le code commence par le préfixe', () {
    expect(DraftShareCode.encode(_record()), startsWith('LOLD1.'));
  });

  test('retrouve le code noyé dans un message', () {
    final code = DraftShareCode.encode(_record());

    expect(DraftShareCode.decode('Ma draft\nCode : $code\nGG'), isNotNull);
  });

  test('chaque lecture donne un nouvel identifiant', () {
    final code = DraftShareCode.encode(_record());

    expect(
      DraftShareCode.decode(code)!.id,
      isNot(DraftShareCode.decode(code)!.id),
    );
  });

  test('un texte sans code, tronqué ou corrompu donne null', () {
    final code = DraftShareCode.encode(_record());

    expect(DraftShareCode.decode('Draft sans code'), isNull);
    expect(DraftShareCode.decode(code.substring(0, code.length - 8)), isNull);
    expect(DraftShareCode.decode('LOLD1.!!!'), isNull);
    expect(DraftShareCode.decode('LOLD1.'), isNull);
  });

  test('un base64 valide qui n est pas du JSON donne null', () {
    final body = base64Url.encode(utf8.encode('{pas json')).replaceAll('=', '');

    expect(DraftShareCode.decode('LOLD1.$body'), isNull);
  });

  test('refuse des équipes qui n ont pas cinq rôles', () {
    expect(
      DraftShareCode.decode(
        _forge({
          ..._payload(),
          'b': ['A'],
        }),
      ),
      isNull,
    );
    expect(
      DraftShareCode.decode(_forge({..._payload(), 'r': <String>[]})),
      isNull,
    );
  });

  test('refuse les champs invalides ou hors bornes', () {
    expect(DraftShareCode.decode(_forge({..._payload(), 'w': 'x'})), isNull);
    expect(DraftShareCode.decode(_forge({..._payload(), 't': 'x'})), isNull);
    expect(DraftShareCode.decode(_forge({..._payload(), 'bs': 'x'})), isNull);
    expect(DraftShareCode.decode(_forge({..._payload(), 'nm': 3})), isNull);

    final longName = 'x' * (DraftShareCode.maxNameLength + 1);
    final longVerdict = 'x' * (DraftShareCode.maxVerdictLength + 1);
    final manyBans = [
      for (var i = 0; i <= DraftShareCode.maxBansPerSide; i++) '$i',
    ];

    expect(
      DraftShareCode.decode(_forge({..._payload(), 'bn': longName})),
      isNull,
    );
    expect(
      DraftShareCode.decode(_forge({..._payload(), 'v': longVerdict})),
      isNull,
    );
    expect(
      DraftShareCode.decode(_forge({..._payload(), 'bb': manyBans})),
      isNull,
    );
  });

  test('ignore les champs inconnus', () {
    final decoded = DraftShareCode.decode(_forge({..._payload(), 'z': 1}));

    expect(decoded?.blueName, 'Léa');
  });

  test('le texte de partage contient un code qui se relit', () {
    final record = _record();
    final text = DraftShareText.of(record);

    expect(text.split('\n').last, startsWith('Code : LOLD1.'));
    expect(DraftShareCode.decode(text)?.blue, record.blue);
  });

  group('assisted et imported', () {
    test('assisted fait l aller-retour', () {
      final record = DraftRecord(
        id: 'a',
        playedAt: DateTime(2026, 10, 5),
        versusFriend: false,
        blueName: 'Vous',
        redName: 'Le site',
        blue: _record().blue,
        red: _record().red,
        blueBans: const [],
        redBans: const [],
        championNames: _record().championNames,
        winner: DraftWinner.blue,
        blueScore: 1,
        redScore: 0,
        verdict: '',
        assisted: true,
      );

      expect(
        DraftShareCode.decode(DraftShareCode.encode(record))?.assisted,
        true,
      );
    });

    test('un ancien code sans la clé a se relit non assisté', () {
      final decoded = DraftShareCode.decode(_forge(_payload()..remove('a')));

      expect(decoded, isNotNull);
      expect(decoded!.assisted, isFalse);
    });

    test('une draft décodée est marquée importée, pas l originale', () {
      expect(_record().imported, isFalse);
      expect(
        DraftShareCode.decode(DraftShareCode.encode(_record()))?.imported,
        isTrue,
      );
    });
  });
}
