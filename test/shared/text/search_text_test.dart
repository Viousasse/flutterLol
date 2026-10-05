import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/shared/text/search_text.dart';

void main() {
  test('retire accents, apostrophes et espaces', () {
    expect(normalizeSearchText('Zoé'), 'zoe');
    expect(normalizeSearchText("Cho'Gath"), 'chogath');
    expect(normalizeSearchText("Vel'Koz"), 'velkoz');
    expect(normalizeSearchText('Lee Sin'), 'leesin');
    expect(normalizeSearchText('Nunu & Willump'), 'nunu&willump');
  });

  test('une recherche tapée sans accent retrouve le nom accentué', () {
    expect(
      normalizeSearchText('Épée de Doran').contains(normalizeSearchText('epee')),
      isTrue,
    );
  });

  test('un texte vide reste vide', () {
    expect(normalizeSearchText('  '), '');
  });
}
