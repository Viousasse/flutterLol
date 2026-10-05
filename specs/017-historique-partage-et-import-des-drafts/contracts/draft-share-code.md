# Contrat : code de partage d'une draft (`LOLD1.`)

Fichiers : `lib/draft/services/draft_share_code.dart` (format de la draft), `lib/shared/services/share_code/share_code.dart` (enveloppe commune), `lib/draft/services/draft_share_text.dart` (résumé).

## Enveloppe

```text
LOLD1.<base64url(UTF-8(JSON))>
```

- Préfixe `LOLD1.` : `D` = draft, `1` = version du format. Un changement incompatible passe à `LOLD2.`. Ajouter un champ ne change pas le préfixe : les lecteurs ignorent les clés inconnues.
- Base64 « URL-safe » (alphabet `A-Za-z0-9_-`), sans `=` de remplissage.
- Le corps est le JSON compact d'un objet.

## Charge utile (objet JSON)

| Clé | Type | Contenu | Validation au décodage |
|-----|------|---------|------------------------|
| `t` | chaîne | `playedAt`, ISO 8601 | date lisible, sinon refus |
| `f` | booléen | `versusFriend` | absent ou autre que `true` = faux |
| `bn`, `rn` | chaîne | noms bleu et rouge | non vide, 40 caractères au plus |
| `b`, `r` | liste de chaînes | choix, ordre des rôles | exactement 5 chaînes |
| `bb`, `rb` | liste de chaînes | bannis | au plus 10 chaînes ; absent = `[]` |
| `nm` | objet | identifiant vers nom | doit être un objet ; entrées dont la valeur n'est pas une chaîne ignorées |
| `w` | chaîne | `blue`, `red` ou `tie` | valeur connue, sinon refus |
| `bs`, `rs` | nombre | scores | obligatoires et numériques |
| `v` | chaîne | verdict | 300 caractères au plus ; absent = `''` |
| `a` | booléen | `assisted` | absent = faux |

## API Dart

```dart
class ShareCode {
  static String encode(String prefix, Map<String, dynamic> payload);
  /// Premier code lisible de [text] commençant par [prefix], sinon null.
  static Map<String, dynamic>? decode(String prefix, String text);
}

class DraftShareCode {
  static const prefix = 'LOLD1.';
  static const maxNameLength = 40;
  static const maxVerdictLength = 300;
  static const maxBansPerSide = 10;
  static String encode(DraftRecord record);
  /// Nouvel `id`, `playedAt` conservée, `imported: true` ; null si invalide.
  static DraftRecord? decode(String text);
}

class DraftShareText {
  /// Résumé lisible ; la dernière ligne est « Code : <code> ».
  static String of(DraftRecord record);
}
```

## Garanties

- `decode(encode(r))` restitue équipes, bannis, noms, scores, vainqueur, verdict, `assisted` et `playedAt` ; `id` est neuf, `imported` vaut `true`. `imported` n'est jamais encodé.
- Un texte sans code, un code tronqué, un base64 valide mais pas du JSON, ou un JSON non objet donnent `null`.
- Plusieurs codes dans un texte : le premier lisible l'emporte.
- Deux lectures successives ne donnent jamais le même `id`.

## Limites

Pas de signature ni de chiffrement ; pas de contrôle de cohérence entre les identifiants et `nm` (un identifiant sans nom s'affiche par son identifiant).
