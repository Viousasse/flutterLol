# Contrat : codes et résumés de partage

## `ShareCode` (`lib/shared/services/share_code/share_code.dart`)

Mécanisme commun, aussi utilisé par l'historique des drafts (préfixe `LOLD1.`).

```dart
class ShareCode {
  /// '<prefix><base64url(utf8(json)) sans « = »>'
  static String encode(String prefix, Map<String, dynamic> payload);
  /// Premier code lisible de [text] commençant par [prefix], sinon null.
  static Map<String, dynamic>? decode(String prefix, String text);
}
```

- Le motif cherché est `prefix` suivi de `[A-Za-z0-9_-]+` ; un code illisible (base64, UTF-8 ou JSON invalide, ou JSON qui n'est pas un objet) est ignoré et le suivant est essayé.
- Changer le préfixe (`LOLB2.`) signale un format incompatible ; ajouter une clé ne le change pas.

## `BuildShareCode` (`lib/builds/services/build_share_code.dart`)

```dart
class BuildShareCode {
  static const prefix = 'LOLB1.';
  static const maxNameLength = 60;
  static String encode(Build build);       // {n, c (si non nul), i}
  static Build? decode(String text);       // nouvel id à chaque lecture
}
```

`decode` renvoie `null` si : aucun code lisible ; `n` n'est pas un texte, est vide ou dépasse 60 ; `c` est présent et n'est pas un texte ; `i` n'est pas une liste, dépasse 6 éléments ou contient autre chose que des textes. Note : seul le premier code lisible est validé ; s'il est lisible mais invalide, les codes suivants ne sont pas essayés.

## `BuildShareText` (`lib/builds/services/build_share_text.dart`)

```dart
class BuildShareText {
  static String of(Build build, List<Item> items, String? championName);
}
```

Dernière ligne : `Code : <BuildShareCode.encode(build)>`.

## `importBuildFromText` (`lib/builds/services/build_import.dart`)

```dart
Future<Build?> importBuildFromText(String text);
```

Décode puis enregistre (`BuildStore.save`) ; `null` sans écriture si le texte est invalide. N'est appelée que par les tests : la page utilise `PasteCodeDialog` puis `BuildStore.save`.

## `copyToClipboard` (`lib/shared/services/clipboard_copy/clipboard_copy.dart`)

```dart
Future<void> copyToClipboard(BuildContext context, String text,
    {String message = 'Copié dans le presse-papiers'});
```

Affiche `message` dans une `SnackBar`, ou « Copie impossible sur cet appareil » si la copie échoue.

## Tests

`test/builds/build_share_code_test.dart`, `build_share_text_test.dart`, `build_import_test.dart`.
