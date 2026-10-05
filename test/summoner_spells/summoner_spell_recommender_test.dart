import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/summoner_spells/models/summoner_spell.dart';
import 'package:monapp/summoner_spells/services/summoner_spell_recommender.dart';

List<String> _ids({required List<String> tags, String? lane}) {
  return SummonerSpellRecommender.recommend(tags: tags, lane: lane).spellIds;
}

void main() {
  test('un jungler prend Châtiment', () {
    expect(_ids(tags: ['Fighter'], lane: 'JUNGLE'), contains('SummonerSmite'));
  });

  test('un tireur en bas prend Soins', () {
    expect(_ids(tags: ['Marksman'], lane: 'BOTTOM'), [
      'SummonerFlash',
      'SummonerHeal',
    ]);
  });

  test('un combattant en haut prend Téléportation, un mage Embrasement', () {
    expect(_ids(tags: ['Tank'], lane: 'TOP'), contains('SummonerTeleport'));
    expect(_ids(tags: ['Mage'], lane: 'TOP'), contains('SummonerDot'));
  });

  test('un soutien enchanteur prend Épuisement, un mage soutien Embrasement', () {
    expect(_ids(tags: ['Support'], lane: 'UTILITY'), contains('SummonerExhaust'));
    expect(_ids(tags: ['Mage'], lane: 'UTILITY'), contains('SummonerDot'));
  });

  test('sans voie connue, le profil décide', () {
    expect(_ids(tags: ['Marksman']), contains('SummonerHeal'));
    expect(_ids(tags: ['Support']), contains('SummonerExhaust'));
    expect(_ids(tags: ['Assassin']), contains('SummonerDot'));
    expect(_ids(tags: ['Fighter']), contains('SummonerTeleport'));
  });

  test('un champion sans tag retombe sur un profil par défaut', () {
    expect(_ids(tags: const []), isNotEmpty);
  });

  test('chaque plan donne deux sorts et une raison', () {
    for (final lane in [null, 'TOP', 'JUNGLE', 'MIDDLE', 'BOTTOM', 'UTILITY']) {
      for (final tag in ['Fighter', 'Tank', 'Mage', 'Assassin', 'Support', 'Marksman']) {
        final plan = SummonerSpellRecommender.recommend(tags: [tag], lane: lane);

        expect(plan.spellIds, hasLength(2), reason: '$tag / $lane');
        expect(plan.reason, isNotEmpty);
      }
    }
  });

  test('lit un sort depuis le JSON de Data Dragon', () {
    final spell = SummonerSpell.fromJson({
      'id': 'SummonerFlash',
      'name': 'Saut éclair',
      'description': 'Vous téléporte sur une courte distance.',
      'cooldown': [300],
      'image': {'full': 'SummonerFlash.png'},
    }, '16.19.1');

    expect(spell.cooldown, 300);
    expect(spell.imageUrl, endsWith('/16.19.1/img/spell/SummonerFlash.png'));
  });

  test('ne retient que les sorts de la partie classique', () {
    expect(SummonerSpell.isClassic({'modes': ['ARAM', 'CLASSIC']}), isTrue);
    expect(SummonerSpell.isClassic({'modes': ['JADE']}), isFalse);
    expect(SummonerSpell.isClassic({}), isFalse);
  });
}
