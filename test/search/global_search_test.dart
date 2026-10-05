import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/champions/models/champion.dart';
import 'package:monapp/items/models/item.dart';
import 'package:monapp/items/models/item_profile.dart';
import 'package:monapp/search/services/global_search.dart';

Champion _champion(String id, String name) => Champion(
  id: id,
  name: name,
  title: 'titre',
  blurb: '',
  imageUrl: 'https://example.invalid/$id.png',
  tags: const ['Mage'],
);

Item _item(String id, String name) => Item(
  id: id,
  name: name,
  description: '',
  plaintext: '',
  gold: 1000,
  imageUrl: 'https://example.invalid/$id.png',
  tier: ItemTier.legendary,
  profile: ItemProfile.other,
  componentIds: const [],
  upgradeIds: const [],
);

void main() {
  final champions = [
    _champion('Shaco', 'Shaco'),
    _champion('Ahri', 'Ahri'),
    _champion('Zoe', 'Zoé'),
  ];
  final items = [
    _item('1', 'Épée de Doran'),
    _item('2', 'Lame du voleur'),
  ];

  test('place les noms qui commencent par la recherche avant les autres', () {
    // « a » commence Ahri et se trouve seulement au milieu de Shaco, bien que
    // Shaco passe avant Ahri dans la liste d'origine.
    final results = GlobalSearch.run('a', champions: champions, items: items);

    expect(results.champions.map((c) => c.id), ['Ahri', 'Shaco']);
  });

  test('cherche dans les champions et les objets à la fois', () {
    final results = GlobalSearch.run('e', champions: champions, items: items);

    expect(results.champions, isNotEmpty);
    expect(results.items, isNotEmpty);
  });

  test('ignore les accents', () {
    final results = GlobalSearch.run('epee', champions: champions, items: items);

    expect(results.items.map((i) => i.id), ['1']);
  });

  test('une recherche vide ne renvoie rien', () {
    final results = GlobalSearch.run('  ', champions: champions, items: items);

    expect(results.isEmpty, isTrue);
  });

  test('limite chaque section pour inviter à préciser', () {
    final many = List.generate(30, (i) => _champion('A$i', 'Aaa $i'));

    final results = GlobalSearch.run('aaa', champions: many, items: const []);

    expect(results.champions, hasLength(GlobalSearch.maxPerSection));
  });
}
