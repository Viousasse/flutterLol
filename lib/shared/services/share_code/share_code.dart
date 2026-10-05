import 'dart:convert';

/// Le mécanisme commun aux codes de partage : un préfixe qui porte le type et
/// la version du format, suivi d'un JSON compact en base64 « URL-safe ».
///
/// Le préfixe change quand le format casse (`LOLB1.` deviendrait `LOLB2.`) ;
/// ajouter un champ ne le change pas, car les lecteurs ignorent les champs
/// qu'ils ne connaissent pas.
class ShareCode {
  /// Écrit [payload] sous la forme `<prefix><base64url sans remplissage>`.
  static String encode(String prefix, Map<String, dynamic> payload) {
    final bytes = utf8.encode(jsonEncode(payload));

    return '$prefix${base64Url.encode(bytes).replaceAll('=', '')}';
  }

  /// Cherche dans [text] un code commençant par [prefix] et renvoie son
  /// contenu, ou `null` s'il n'y en a aucun de lisible.
  ///
  /// Le code est le plus souvent collé au milieu d'un message entier, d'où la
  /// recherche plutôt qu'une lecture du texte tel quel. Un code tronqué ou
  /// abîmé est ignoré : on essaie alors le suivant.
  static Map<String, dynamic>? decode(String prefix, String text) {
    final pattern = RegExp('${RegExp.escape(prefix)}([A-Za-z0-9_-]+)');

    for (final match in pattern.allMatches(text)) {
      final payload = _read(match.group(1)!);
      if (payload != null) return payload;
    }

    return null;
  }

  static Map<String, dynamic>? _read(String body) {
    try {
      final json = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(body))),
      );

      return json is Map<String, dynamic> ? json : null;
    } on FormatException {
      return null;
    }
  }
}
