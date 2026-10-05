import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/patch_notes/models/patch_notes.dart';

void main() {
  test('déduit le patch du site de la version Data Dragon', () {
    final notes = PatchNotes.fromVersion('16.19.1')!;

    expect(notes.label, '26.19');
    expect(
      notes.url,
      'https://www.leagueoflegends.com/fr-fr/news/game-updates/'
      'league-of-legends-patch-26-19-notes',
    );
  });

  test('accepte une version sans numéro de correctif', () {
    expect(PatchNotes.fromVersion('16.3')!.label, '26.3');
  });

  test('refuse une version illisible', () {
    expect(PatchNotes.fromVersion('abc'), isNull);
    expect(PatchNotes.fromVersion('16.x.1'), isNull);
    expect(PatchNotes.fromVersion(''), isNull);
  });
}
