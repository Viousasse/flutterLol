import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/champions/models/champion.dart';
import 'package:monapp/champions/models/champion_sort.dart';
import 'package:monapp/champions/services/champion_filter.dart';
import 'package:monapp/regions/models/lore_region.dart';

Champion _champion(
  String id, {
  String? name,
  List<String> tags = const ['Fighter'],
  int difficulty = 5,
}) {
  return Champion(
    id: id,
    name: name ?? id,
    title: 'titre',
    blurb: '',
    imageUrl: 'https://example.invalid/$id.png',
    tags: tags,
    difficulty: difficulty,
  );
}

void main() {
  final champions = [
    _champion('Garen', tags: ['Fighter', 'Tank'], difficulty: 5),
    _champion('Ahri', tags: ['Mage'], difficulty: 5),
    _champion('Zed', tags: ['Assassin'], difficulty: 7),
    _champion('Zoe', name: 'Zoé', tags: ['Mage'], difficulty: 8),
    _champion('Fiora', tags: ['Fighter'], difficulty: 3),
  ];

  List<String> ids(List<Champion> list) => list.map((c) => c.id).toList();

  test('trie par ordre alphabétique par défaut', () {
    expect(ids(ChampionFilter.apply(champions)), [
      'Ahri',
      'Fiora',
      'Garen',
      'Zed',
      'Zoe',
    ]);
  });

  test('retrouve un nom accentué avec une recherche sans accent', () {
    expect(ids(ChampionFilter.apply(champions, query: 'zoe')), ['Zoe']);
  });

  test('combine rôle et recherche', () {
    final result = ChampionFilter.apply(champions, role: 'Mage', query: 'a');

    expect(ids(result), ['Ahri']);
  });

  test('filtre par région officielle', () {
    final result = ChampionFilter.apply(
      champions,
      region: RegionId.demacia,
    );

    // Fiora et Garen sont tous deux demaciens ; Ahri, Zed et Zoé ne le sont pas.
    expect(ids(result), ['Fiora', 'Garen']);
  });

  test('trie par difficulté dans les deux sens, à égalité par nom', () {
    expect(
      ids(ChampionFilter.apply(champions, sort: ChampionSort.difficultyAsc)),
      ['Fiora', 'Ahri', 'Garen', 'Zed', 'Zoe'],
    );
    expect(
      ids(ChampionFilter.apply(champions, sort: ChampionSort.difficultyDesc)),
      ['Zoe', 'Zed', 'Ahri', 'Garen', 'Fiora'],
    );
  });

  test('trie par taux de victoire, les champions sans donnée à la fin', () {
    final result = ChampionFilter.apply(
      champions,
      sort: ChampionSort.winRate,
      winRates: const {'Garen': 0.48, 'Zed': 0.53, 'Ahri': 0.51},
    );

    expect(ids(result), ['Zed', 'Ahri', 'Garen', 'Fiora', 'Zoe']);
  });

  test('ne modifie pas la liste reçue', () {
    final before = ids(champions);

    ChampionFilter.apply(champions, sort: ChampionSort.difficultyDesc);

    expect(ids(champions), before);
  });
}
