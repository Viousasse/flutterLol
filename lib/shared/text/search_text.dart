const _foldedCharacters = {
  'à': 'a',
  'â': 'a',
  'ä': 'a',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'î': 'i',
  'ï': 'i',
  'ô': 'o',
  'ö': 'o',
  'ù': 'u',
  'û': 'u',
  'ü': 'u',
  'ç': 'c',
  'œ': 'oe',
};

final _ignoredCharacters = RegExp(r"[\s'’.\-]");

/// Met un texte sous la forme où l'on compare : minuscules, sans accents ni
/// apostrophes ni espaces, pour que « zoe » trouve Zoé et « chogath » trouve
/// Cho'Gath.
String normalizeSearchText(String text) {
  final buffer = StringBuffer();

  for (final character in text.toLowerCase().split('')) {
    buffer.write(_foldedCharacters[character] ?? character);
  }

  return buffer.toString().replaceAll(_ignoredCharacters, '');
}
