import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/builds/models/build.dart';
import 'package:monapp/builds/services/build_share_code.dart';
import 'package:monapp/shared/services/share_code/share_code.dart';

String _forge(Map<String, dynamic> payload) =>
    ShareCode.encode(BuildShareCode.prefix, payload);

void main() {
  const build = Build(
    id: 'a',
    name: 'Burst « mid »',
    championId: 'Ahri',
    itemIds: ['3089', '3157'],
  );

  test('un aller-retour redonne la même build', () {
    final decoded = BuildShareCode.decode(BuildShareCode.encode(build))!;

    expect(decoded.name, build.name);
    expect(decoded.championId, 'Ahri');
    expect(decoded.itemIds, ['3089', '3157']);
  });

  test('le champion est facultatif', () {
    const generic = Build(id: 'a', name: 'Tank', itemIds: []);
    final decoded = BuildShareCode.decode(BuildShareCode.encode(generic))!;

    expect(decoded.championId, isNull);
    expect(decoded.itemIds, isEmpty);
  });

  test('le code commence par le préfixe et n est pas rempli de « = »', () {
    final code = BuildShareCode.encode(build);

    expect(code, startsWith('LOLB1.'));
    expect(code, isNot(contains('=')));
  });

  test('retrouve le code noyé dans un message', () {
    final code = BuildShareCode.encode(build);
    final decoded = BuildShareCode.decode(
      'Regarde ma build !\n1. Lame\nCode : $code\nÀ toi de jouer.',
    );

    expect(decoded?.name, build.name);
  });

  test('chaque lecture donne un nouvel identifiant', () {
    final code = BuildShareCode.encode(build);
    final first = BuildShareCode.decode(code)!;
    final second = BuildShareCode.decode(code)!;

    expect(first.id, isNot('a'));
    expect(first.id, isNot(second.id));
  });

  test('un texte sans code donne null', () {
    expect(BuildShareCode.decode('Build « Burst »'), isNull);
    expect(BuildShareCode.decode(''), isNull);
  });

  test('un code tronqué ou corrompu donne null', () {
    final code = BuildShareCode.encode(build);

    expect(BuildShareCode.decode(code.substring(0, code.length - 6)), isNull);
    expect(BuildShareCode.decode('LOLB1.'), isNull);
    expect(BuildShareCode.decode('LOLB1.!!!'), isNull);
  });

  test('un base64 valide qui n est pas du JSON donne null', () {
    final body = base64Url
        .encode(utf8.encode('pas du json'))
        .replaceAll('=', '');

    expect(BuildShareCode.decode('LOLB1.$body'), isNull);
  });

  test('un JSON qui n est pas un objet donne null', () {
    final body = base64Url.encode(utf8.encode('[1,2]')).replaceAll('=', '');

    expect(BuildShareCode.decode('LOLB1.$body'), isNull);
  });

  test('refuse les champs invalides', () {
    expect(BuildShareCode.decode(_forge({'i': <String>[]})), isNull);
    expect(BuildShareCode.decode(_forge({'n': '', 'i': <String>[]})), isNull);
    expect(BuildShareCode.decode(_forge({'n': 'A', 'i': 'x'})), isNull);
    expect(
      BuildShareCode.decode(
        _forge({
          'n': 'A',
          'i': [1, 2],
        }),
      ),
      isNull,
    );
    expect(
      BuildShareCode.decode(_forge({'n': 'A', 'c': 3, 'i': <String>[]})),
      isNull,
    );
  });

  test('borne le nom et le nombre d objets', () {
    final longName = 'x' * (BuildShareCode.maxNameLength + 1);
    final maxName = 'x' * BuildShareCode.maxNameLength;
    final tooMany = [for (var i = 0; i <= Build.maxItems; i++) '$i'];
    final maxItems = tooMany.take(Build.maxItems).toList();

    expect(BuildShareCode.decode(_forge({'n': longName, 'i': []})), isNull);
    expect(BuildShareCode.decode(_forge({'n': 'A', 'i': tooMany})), isNull);
    expect(
      BuildShareCode.decode(_forge({'n': maxName, 'i': maxItems})),
      isNotNull,
    );
  });

  test('ignore les champs inconnus', () {
    final decoded = BuildShareCode.decode(
      _forge({'n': 'A', 'i': <String>[], 'futur': 42}),
    );

    expect(decoded?.name, 'A');
  });
}
