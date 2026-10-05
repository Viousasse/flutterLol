# T9b — Page de draft : conseils et session à deux

Lis d'abord `docs/agents/COORDINATION.md` (surtout §5 verrous, §8 contrats).
Tu es **le seul propriétaire de `lib/draft/draft_page.dart`** (T9a a fini : il a
ajouté `replayOf`).

## Ce qui est déjà prêt (à utiliser, ne pas réécrire)
- `lib/draft/services/draft_advisor.dart` (T4) : `DraftAdvisor(dataset:)`,
  `suggest({state, side, pool, count})` → `List<DraftSuggestion>`
  (`roleIndex`, `champion`, `reasons`, `score`) ; `DraftAdvisor.fallbackReason`.
- `lib/draft/services/friend_session_store.dart` (T5) : `FriendSessionStore`
  (`session`, `ensureLoaded`, `rename`, `recordResult`, `resetScore`), et
  `lib/draft/widgets/friend_score_bar/friend_score_bar.dart` (`FriendScoreBar`).
- `DraftRecord.assisted` et `DraftRecord.from(..., assisted:)` (T10).
- `lib/draft/widgets/draft_slot/draft_slot.dart`, `ban_row`, etc.

## À faire
### 1. Aide au choix (conseils)
- Un second interrupteur « Aide au choix » dans le bloc de réglages affiché
  **avant le premier coup** (comme « Bannissements » : même composant visuel,
  mêmes règles — réglable seulement tant que rien n'a été joué). Désactivé par
  défaut. Sous-titre : « Propose 3 champions à votre tour, avec la raison. La
  draft sera marquée « avec aide » dans l'historique. »
- Quand l'aide est active, que la phase de choix est en cours et que c'est à un
  **humain** de jouer (le bleu contre le site ; le camp au trait en draft à
  deux), affiche un panneau **« SUGGESTIONS »** sous le statut : jusqu'à 3
  cartes — icône du champion (`RemoteImage`), nom, rôle visé (`teamRoles`),
  1 à 3 raisons. Toucher une carte **joue** ce champion à ce rôle
  (même chemin que le choix manuel : mêmes vérifications, `advance()` ensuite).
  Libellé sémantique complet par carte.
- Les suggestions viennent de `DraftAdvisor(dataset: dataset).suggest(...)` ;
  construis l'objet une seule fois, comme `bot`. Aucune suggestion pendant les
  bannissements, pendant le tour du site, ni après la fin.
- La draft terminée est enregistrée avec `assisted: withAdvice`.
- Le widget de carte va dans
  `lib/draft/widgets/suggestion_card/suggestion_card.dart` (un seul widget
  public par fichier, couleurs `AppColors`).

### 2. Session à deux
- En draft à deux **non rejouée** (`replayOf == null`) : les noms viennent de
  `FriendSessionStore.session` (`ensureLoaded()` dans `loadData`) ; le
  renommage passe par `FriendSessionStore.rename` (refus silencieux d'un nom
  invalide : la boîte de dialogue valide déjà, ne change pas son comportement) ;
  à la fin, `FriendSessionStore.recordResult(report.winner)`.
- Affiche la `FriendScoreBar` en haut de la page en draft à deux (écoute
  `FriendSessionStore.session` avec un `ValueListenableBuilder`). Son `onReset`
  demande confirmation (`AlertDialog` « Remettre le score à zéro ? ») puis
  appelle `resetScore()`.
- Un duel **rejoué** garde les noms de la draft rejouée et **n'écrit pas** dans
  la session (pas de score).
- Le champ local `players` de la page reste la source de vérité pour le bilan ;
  il se met à jour quand la session change (renommage) avant le premier coup.

### 3. Note sur les données
Si `lib/shared/widgets/data_source_note/data_source_note.dart` existe (T3 le crée
en ce moment : regarde le journal), affiche `DataSourceNote(dataset: dataset)`
sous le bilan. Sinon, n'ajoute rien et écris-le au journal : l'architecte le
fera.

## Tests
Nouveaux fichiers (n'édite pas `draft_page_flow_test.dart` ni
`draft_page_replay_test.dart`, copie leur outillage : chargeurs injectés, `_settle`
par `pump` répétés, `DraftHistoryStore.reset()`, `FriendSessionStore.reset()`,
`SharedPreferences.setMockInitialValues`) :
- `test/draft/draft_page_advice_test.dart` : interrupteur visible avant le premier
  coup et masqué ensuite ; pas de panneau quand l'aide est éteinte ; panneau avec
  3 cartes à son tour ; absent pendant les bans et pendant le tour du site ;
  toucher une carte place le champion au bon rôle ; draft entière avec aide →
  `record.assisted == true` ; sans aide → `false`.
- `test/draft/draft_page_friend_session_test.dart` : noms repris du store ;
  renommage persisté ; score incrémenté à la fin ; barre de score visible ;
  remise à zéro avec confirmation ; un duel rejoué n'écrit pas dans la session.
- `test/draft/suggestion_card_test.dart`.

## Fichiers qui t'appartiennent
`lib/draft/draft_page.dart`, `lib/draft/widgets/suggestion_card/**`, les trois
fichiers de test ci-dessus. **Ne modifie pas** les fichiers d'autres tâches ;
signale au journal s'il manque quelque chose.

## Définition de « fini »
Analyse propre sur `lib/draft/draft_page.dart lib/draft/widgets/suggestion_card`,
tes tests **et** `draft_page_flow_test.dart`/`draft_page_replay_test.dart` passent
(non-régression), message au journal.
