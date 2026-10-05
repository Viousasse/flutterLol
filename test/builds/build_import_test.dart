import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/builds/models/build.dart';
import 'package:monapp/builds/services/build_import.dart';
import 'package:monapp/builds/services/build_share_code.dart';
import 'package:monapp/builds/services/build_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await BuildStore.ensureLoaded();
  });

  test('enregistre la build contenue dans un message collé', () async {
    const original = Build(id: 'x', name: 'Burst', itemIds: ['1', '2']);
    final text = 'Voici ma build\nCode : ${BuildShareCode.encode(original)}';

    final imported = await importBuildFromText(text);

    expect(imported?.name, 'Burst');
    expect(imported?.id, isNot('x'));
    expect(BuildStore.builds.value.map((b) => b.id), contains(imported!.id));
  });

  test('ne garde rien quand le texte n a pas de code valide', () async {
    final before = BuildStore.builds.value.length;

    expect(await importBuildFromText('pas un code'), isNull);
    expect(BuildStore.builds.value.length, before);
  });
}
