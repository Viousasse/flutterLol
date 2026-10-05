import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/builds/models/build.dart';
import 'package:monapp/builds/services/build_share_text.dart';
import 'package:monapp/items/models/item.dart';
import 'package:monapp/items/models/item_profile.dart';

Item _item(String id, String name, int gold) {
  return Item(
    id: id,
    name: name,
    description: '',
    plaintext: '',
    gold: gold,
    imageUrl: '',
    tier: ItemTier.legendary,
    profile: ItemProfile.other,
    componentIds: const [],
    upgradeIds: const [],
  );
}

void main() {
  const build = Build(id: 'a', name: 'Burst', itemIds: ['1', '2']);

  test('liste les objets dans l ordre, avec le total', () {
    final text = BuildShareText.of(build, [
      _item('1', 'Lame', 1000),
      _item('2', 'Bâton', 2500),
    ], 'Ahri');

    expect(text.split('\n'), [
      'Build « Burst » pour Ahri',
      '1. Lame',
      '2. Bâton',
      'Total : 3500 or',
    ]);
  });

  test('sans champion, le titre ne le mentionne pas', () {
    final text = BuildShareText.of(build, [_item('1', 'Lame', 1000)], null);

    expect(text.split('\n').first, 'Build « Burst »');
  });

  test('une build sans objet le dit', () {
    final text = BuildShareText.of(build, const [], 'Ahri');

    expect(text, contains('Aucun objet.'));
    expect(text, isNot(contains('Total')));
  });
}
