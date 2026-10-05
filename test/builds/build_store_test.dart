import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/builds/models/build.dart';
import 'package:monapp/builds/services/build_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('enregistre, modifie et supprime des builds', () async {
    SharedPreferences.setMockInitialValues({});
    await BuildStore.ensureLoaded();

    const first = Build(id: 'a', name: 'Burst', itemIds: ['1', '2']);
    const second = Build(id: 'b', name: 'Tank', itemIds: ['3']);

    await BuildStore.save(first);
    await BuildStore.save(second);
    expect(BuildStore.builds.value.map((b) => b.id), ['b', 'a']);

    // Modifier une build la remonte en tête sans la dupliquer.
    await BuildStore.save(first.copyWith(name: 'Burst v2'));
    expect(BuildStore.builds.value.map((b) => b.id), ['a', 'b']);
    expect(BuildStore.builds.value.first.name, 'Burst v2');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('saved_builds'), hasLength(2));

    await BuildStore.delete('a');
    expect(BuildStore.builds.value.map((b) => b.id), ['b']);
    expect(prefs.getStringList('saved_builds'), hasLength(1));
  });

  test('une entrée illisible ne fait pas perdre les autres', () {
    final good = jsonEncode(
      const Build(id: 'a', name: 'Ok', itemIds: ['1']).toJson(),
    );

    expect(Build.tryFromJson(jsonDecode(good)), isNotNull);
    expect(Build.tryFromJson({'id': 1}), isNull);
    expect(Build.tryFromJson('pas une build'), isNull);
    expect(Build.tryFromJson({'id': 'a', 'name': 'x'}), isNull);
  });

  test('une build ne dépasse jamais six objets', () {
    final build = Build.tryFromJson({
      'id': 'a',
      'name': 'Trop',
      'itemIds': ['1', '2', '3', '4', '5', '6', '7', '8'],
    })!;

    expect(build.itemIds, hasLength(Build.maxItems));
  });

  test('conserve le champion et l ordre des objets', () {
    const build = Build(
      id: 'a',
      name: 'Ahri mid',
      championId: 'Ahri',
      itemIds: ['3', '1', '2'],
    );

    final restored = Build.tryFromJson(jsonDecode(jsonEncode(build.toJson())))!;

    expect(restored.championId, 'Ahri');
    expect(restored.itemIds, ['3', '1', '2']);
  });
}
