import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/builds/services/build_stats.dart';
import 'package:monapp/items/models/item.dart';
import 'package:monapp/items/models/item_profile.dart';

Item _item(String id, int gold, Map<String, double> stats) {
  return Item(
    id: id,
    name: 'Objet $id',
    description: '',
    plaintext: '',
    gold: gold,
    imageUrl: 'https://example.invalid/$id.png',
    tier: ItemTier.legendary,
    profile: ItemProfile.other,
    componentIds: const [],
    upgradeIds: const [],
    stats: stats,
  );
}

void main() {
  final blade = _item('1', 3000, {
    'FlatPhysicalDamageMod': 55,
    'PercentAttackSpeedMod': 0.25,
    'FlatCritChanceMod': 0.2,
  });
  final armor = _item('2', 2800, {
    'FlatArmorMod': 60,
    'FlatHPPoolMod': 400,
    'FlatPhysicalDamageMod': 5,
  });

  Map<String, String> asMap(List<StatLine> lines) {
    return {for (final line in lines) line.label: line.value};
  }

  test('additionne le prix de tous les objets', () {
    expect(BuildStats.totalGold([blade, armor]), 5800);
    expect(BuildStats.totalGold(const []), 0);
  });

  test('cumule les bonus identiques de plusieurs objets', () {
    final lines = asMap(BuildStats.total([blade, armor]));

    expect(lines["Dégâts d'attaque"], '+60');
    expect(lines['Armure'], '+60');
    expect(lines['Points de vie'], '+400');
  });

  test('affiche les fractions de Riot en pourcentage', () {
    final lines = asMap(BuildStats.total([blade]));

    expect(lines["Vitesse d'attaque"], '+25 %');
    expect(lines['Chances de coup critique'], '+20 %');
  });

  test('ne garde que les statistiques non nulles, dans l ordre de lecture', () {
    final lines = BuildStats.total([blade]);

    expect(lines.map((line) => line.label), [
      "Dégâts d'attaque",
      "Vitesse d'attaque",
      'Chances de coup critique',
    ]);
  });

  test('une build vide n a aucun bonus', () {
    expect(BuildStats.total(const []), isEmpty);
  });

  test('un objet sans bonus chiffré ne change rien', () {
    expect(BuildStats.total([_item('3', 1000, const {})]), isEmpty);
  });

  test('lit les statistiques depuis le JSON de Data Dragon', () {
    final item = Item.fromJson('3031', {
      'name': "Lame d'infini",
      'gold': {'total': 3450},
      'image': {'full': '3031.png'},
      'stats': {'FlatPhysicalDamageMod': 80, 'FlatCritChanceMod': 0.25},
    }, '16.19.1');

    expect(item.stats['FlatPhysicalDamageMod'], 80);
    expect(item.stats['FlatCritChanceMod'], 0.25);
  });
}
