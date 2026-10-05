import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:monapp/data_dragon/data_dragon_exception.dart';
import 'package:monapp/data_dragon/data_dragon_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _url = 'https://ddragon.example/champion.json';

Future<T> _withServer<T>(
  Future<http.Response> Function(http.Request request) handler,
  Future<T> Function() body,
) {
  return http.runWithClient(body, () => MockClient(handler));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('resert la derniere copie quand Riot est injoignable', () async {
    await _withServer(
      (_) async => http.Response('{"data":{"Ahri":1}}', 200),
      () => DataDragonService.fetchJson(_url, offlineKey: 'champions'),
    );

    final replay = await _withServer(
      (_) async => throw http.ClientException('hors ligne'),
      () => DataDragonService.fetchJson(_url, offlineKey: 'champions'),
    );

    expect(replay, {
      'data': {'Ahri': 1},
    });
  });

  test('sans copie enregistree, la panne remonte avec un message', () async {
    final failure = _withServer(
      (_) async => throw http.ClientException('hors ligne'),
      () => DataDragonService.fetchJson(_url, offlineKey: 'champions'),
    );

    await expectLater(failure, throwsA(isA<DataDragonException>()));
  });

  test('sans offlineKey, rien n est conserve ni resservi', () async {
    await _withServer(
      (_) async => http.Response('{"ok":true}', 200),
      () => DataDragonService.fetchJson(_url),
    );

    final failure = _withServer(
      (_) async => throw http.ClientException('hors ligne'),
      () => DataDragonService.fetchJson(_url),
    );

    await expectLater(failure, throwsA(isA<DataDragonException>()));
  });

  test('un corps illisible n ecrase pas la derniere bonne copie', () async {
    await _withServer(
      (_) async => http.Response('{"data":1}', 200),
      () => DataDragonService.fetchJson(_url, offlineKey: 'champions'),
    );

    await _withServer(
      (_) async => http.Response('<html>pas du json</html>', 200),
      () => DataDragonService.fetchJson(_url, offlineKey: 'champions'),
    );

    final replay = await _withServer(
      (_) async => http.Response('', 503),
      () => DataDragonService.fetchJson(_url, offlineKey: 'champions'),
    );

    expect(replay, {'data': 1});
  });
}
