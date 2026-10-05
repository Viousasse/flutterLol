# Contrat : soirée à deux, nom et score

## `FriendSessionStore` (`lib/draft/services/friend_session_store.dart`)

```dart
class FriendSessionStore {
  static final ValueNotifier<FriendSession> session;     // état partagé, à écouter

  static Future<void> ensureLoaded();                    // lit la sauvegarde une seule fois
  static Future<void> rename(DraftSide side, String name);
  static Future<void> recordResult(DraftWinner winner);
  static Future<void> resetScore();

  @visibleForTesting
  static void reset();                                   // état de premier lancement
}
```

Garanties :

- `session.value` est mis à jour **avant** l'écriture ; l'écriture ne peut pas échouer visiblement.
- Les écritures sont séquentielles.
- `rename` ignore silencieusement un nom vide ou égal à l'autre nom ; il garde le score.
- `ensureLoaded` renvoie le même `Future` aux appels suivants ; après un échec de lecture il peut être rappelé.

## `FriendSession`

```dart
const FriendSession({DraftPlayers players = friendPlayers, int blueWins = 0, int redWins = 0, int ties = 0});
bool get isScoreEmpty;
FriendSession copyWith({DraftPlayers? players, int? blueWins, int? redWins, int? ties});
Map<String, dynamic> toJson();
static FriendSession? tryFromJson(Object? json);        // null si forme ou valeurs invalides
```

## `FriendScoreBar` (`lib/draft/widgets/friend_score_bar/friend_score_bar.dart`)

```dart
const FriendScoreBar({Key? key, required FriendSession session, required VoidCallback onReset});
```

- Affiche « SCORE DE LA SOIRÉE », « <bleu> N – M <rouge> » et, si `ties > 0`, « N égalité(s) ».
- Bouton « Remettre le score à zéro » (info-bulle), désactivé quand `session.isScoreEmpty`, zone tactile 48 × 48 px minimum.
- Libellé sémantique unique : « Score de la soirée : Léa 3, Tom 2, 1 égalité ».

## `PlayerNameDialog` et `validatePlayerName` (`lib/draft/widgets/player_name_dialog/player_name_dialog.dart`)

```dart
const playerNameMaxLength = 12;
String? validatePlayerName(String raw, {required String otherName});   // message ou null

static Future<String?> PlayerNameDialog.show(
  BuildContext context, {required String currentName, required String otherName});
```

Renvoie le nom saisi nettoyé, ou `null` si on annule ; la boîte reste ouverte et affiche l'erreur tant que le nom est invalide.

## `DraftPage` (côté draft à deux)

- `DraftPage(mode: DraftMode.vsFriend)` ouvre une draft à deux neuve (soirée partagée).
- `DraftPage(replayOf: record)` avec un enregistrement `versusFriend` rejoue un duel : noms de l'original, aucune barre de score, aucune écriture dans la soirée.
- Le titre d'une colonne est un bouton sémantique « Modifier le nom : <titre> » tant que la draft n'est pas terminée.
