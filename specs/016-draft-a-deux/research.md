# Research : Draft à deux

## 1. Même page, deux modes

- **Decision**: la draft à deux est un mode (`DraftMode.vsFriend`) de `DraftPage`, pas une seconde page. Le site ne joue que si `_mode == vsSite` ; en duel, les cases des deux colonnes s'activent selon `nextSide`.
- **Rationale**: commentaire de `DraftMode` : « Deux joueurs se passent l'appareil : l'un joue le bleu, l'autre le rouge ». Commentaire de `_board` : « Contre le site, le rouge se joue tout seul ; à deux, il se joue au doigt ». Le commit `00bcf4c` ne change que 64 lignes de `draft_page.dart`.
- **Alternatives considered**: une page séparée : aucune trace.

## 2. Un bilan neutre quand il y a deux joueurs

- **Decision**: `DraftEvaluator.evaluate(players: …)` remplace « vous » et « le site » par les noms, donne forces et conseils aux deux camps (`redStrengths`, `redImprovements`, `redBanNotes`) et `CriterionTile` colore les deux avantages pareillement.
- **Rationale**: commentaires : « Dans une draft à deux, le bilan est neutre et les forces et conseils sont donnés pour chacun des deux camps » (`draft_report.dart`) ; « En duel, aucun camp n'est "le mauvais" : les deux avantages ont la même couleur » (`criterion_tile.dart`) ; « Les conseils du camp rouge n'ont de sens que face à un vrai joueur : contre le site, personne ne les lirait » (`draft_evaluator.dart`).
- **Alternatives considered**: non documentées. Les duels de voie sont écrits du point de vue du bleu ; pour le rouge on les retourne (`_LaneResult.flipped`) afin que « perdre » veuille dire « perdre pour ce camp » (commentaire dans `_improvements`, testé : « donne des conseils au perdant, pas seulement au camp bleu », « un duel inversé donne les mêmes avantages au rouge »).

## 3. Règles d'un nom de joueur

- **Decision**: `validatePlayerName` refuse un nom vide ou fait d'espaces et un nom égal (casse et espaces ignorés) à celui de l'autre joueur ; la saisie est limitée à 12 caractères (`playerNameMaxLength`) et les espaces autour sont retirés.
- **Rationale**: commentaires : deux joueurs ne peuvent pas porter le même nom car « le bilan ne saurait plus lequel a gagné » ; 12 caractères car « au-delà, il ne tient plus au-dessus d'une colonne de la draft ni dans les étiquettes du bilan ». Testé (`player_name_dialog_test.dart`).
- **Alternatives considered**: non documentées.

## 4. Pas de renommage après le bilan

- **Decision**: les titres de colonne ne se touchent plus une fois la draft complète (`canRename = friend && !state.isComplete`), et `_syncPlayersWithSession` ignore les changements de session quand `state.isComplete`.
- **Rationale**: commentaires : « Changer un nom après le bilan le rendrait faux : on le fige » ; « sauf une fois le bilan établi, qu'un nom différent rendrait faux ».
- **Alternatives considered**: régénérer le bilan avec le nouveau nom : aucune trace.

## 5. Une soirée mémorisée, sur le patron de l'historique

- **Decision**: `FriendSessionStore` : `ValueNotifier<FriendSession>` statique, chargé à la demande (`ensureLoaded`, une seule lecture mémorisée dans `_loading`), persisté sous la clé `friend_session`, écritures chaînées dans `_writeQueue`.
- **Rationale**: commentaire : « Même forme que [DraftHistoryStore] : un [ValueNotifier] que l'écran écoute » ; « Les écritures s'enchaînent pour ne pas se doubler, et une écriture en échec ne rompt pas la file » ; constitution, principe V.
- **Alternatives considered**: un paquet de gestion d'état : interdit sans justification par le principe V, aucune trace de discussion.

## 6. Relecture défensive

- **Decision**: `FriendSession.tryFromJson` renvoie `null` si la forme est mauvaise (types, compteurs négatifs, noms invalides) ; le magasin repart alors des valeurs par défaut. Un échec de lecture ne mémorise pas le chargement pour permettre un nouvel essai.
- **Rationale**: commentaires : « Les noms doivent rester valables : un fichier abîmé ne doit pas réintroduire un nom vide ou deux noms identiques » ; « Stockage indisponible : on démarre sur les valeurs par défaut, et le prochain appel pourra retenter ». Tests : « une entrée illisible redonne les valeurs par défaut », « une entrée de mauvaise forme redonne les valeurs par défaut ».
- **Alternatives considered**: non documentées. Les noms relus ne sont pas contrôlés en longueur (12) : sans trace de décision.

## 7. Seul un duel neuf compte dans la soirée

- **Decision**: `_usesSession = replayOf == null && mode == vsFriend`. En rejeu : pas de barre de score, pas de `recordResult`, pas d'abonnement à la session, noms de la draft d'origine.
- **Rationale**: commentaire : « Seul un duel neuf partage la soirée : un duel rejoué garde les noms de la draft d'origine et ne compte pas dans le score » ; la mission T16 a ajouté `draft_page_replay_score_test.dart` pour couvrir ce cas (journal de coordination).
- **Alternatives considered**: compter le rejeu : écarté par la règle ci-dessus.

## 8. Renommer en cours de soirée écrit dans la session, et la page suit

- **Decision**: `rename` appelle `FriendSessionStore.rename` quand la session est utilisée (l'écouteur remet `players` à jour) ; sinon (rejeu) il change `players` localement.
- **Rationale**: commentaire : « L'écouteur de la session remet `players` à jour » ; le score est conservé « c'est la même soirée » (commentaire de `rename`).
- **Alternatives considered**: non documentées.

## 9. Remise à zéro avec confirmation, bouton désactivé à vide

- **Decision**: `confirmResetScore` ouvre une boîte « Remettre le score à zéro ? » ; le bouton de `FriendScoreBar` est `null` (désactivé) quand `isScoreEmpty`.
- **Rationale**: aucun commentaire ; comportement testé (`draft_page_friend_session_test.dart` : « la remise à zéro demande confirmation » ; `friend_score_bar_test.dart`). L'intention (éviter de perdre un score par mégarde) est une déduction, non écrite.
- **Alternatives considered**: non documentées.
