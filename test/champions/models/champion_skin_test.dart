import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/champions/models/champion_skin.dart';

void main() {
  final raw = [
    {'id': '103000', 'num': 0, 'name': 'default', 'chromas': false},
    {'id': '103001', 'num': 1, 'name': 'Ahri dynastique', 'chromas': true},
    {
      'id': '103008',
      'num': 8,
      'name': 'Ahri popstar (améthyste)',
      'chromas': false,
      'parentSkin': 4,
    },
    {'id': '103004', 'num': 4, 'name': 'Ahri popstar', 'chromas': true},
  ];

  test('écarte les variantes de couleur, qui n ont pas d illustration', () {
    final skins = ChampionSkin.listFromJson('Ahri', raw);

    expect(skins.map((skin) => skin.number), [0, 1, 4]);
  });

  test('nomme l apparence d origine en français', () {
    final skins = ChampionSkin.listFromJson('Ahri', raw);

    expect(skins.first.name, ChampionSkin.defaultName);
    expect(skins[1].name, 'Ahri dynastique');
  });

  test('construit les adresses des illustrations', () {
    final skin = ChampionSkin.listFromJson('Ahri', raw)[1];

    expect(
      skin.splashUrl,
      'https://ddragon.leagueoflegends.com/cdn/img/champion/splash/Ahri_1.jpg',
    );
    expect(
      skin.loadingUrl,
      'https://ddragon.leagueoflegends.com/cdn/img/champion/loading/Ahri_1.jpg',
    );
  });

  test('tolère l absence de liste', () {
    expect(ChampionSkin.listFromJson('Ahri', null), isEmpty);
  });
}
