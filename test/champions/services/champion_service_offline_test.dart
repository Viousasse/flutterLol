import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:monapp/champions/services/champion_service.dart';
import 'package:monapp/data_dragon/data_dragon_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _detail =
    '{"data":{"Ahri":{"id":"Ahri","name":"Ahri","title":"Renarde",'
    '"tags":["Mage"],"passive":{"name":"P","description":"d",'
    '"image":{"full":"p.png"}},"spells":[]}}}';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'ddragon_offline_versions': '["16.19.1"]',
    });
  });

  test('la fiche d un champion deja vu reste lisible hors ligne', () async {
    final online = await http.runWithClient(
      () => ChampionService.fetchDetail('Ahri'),
      () => MockClient((_) async => http.Response(_detail, 200)),
    );
    expect(online.name, 'Ahri');

    final offline = await http.runWithClient(
      () => ChampionService.fetchDetail('Ahri'),
      () => MockClient((_) async => throw http.ClientException('hors ligne')),
    );
    expect(offline.name, 'Ahri');
  });

  test('une fiche jamais vue echoue avec un message, sans planter', () async {
    final failure = http.runWithClient(
      () => ChampionService.fetchDetail('Zed'),
      () => MockClient((_) async => throw http.ClientException('hors ligne')),
    );

    await expectLater(failure, throwsA(isA<DataDragonException>()));
  });
}
