# T9a — Page de draft : rejouer une draft (`replayOf`)

Lis d'abord `docs/agents/COORDINATION.md` (surtout §8, contrat T9a → T10).
Tu es le **propriétaire de `lib/draft/draft_page.dart`** pour la phase 1 ; T9b
le reprendra ensuite. Garde le fichier propre pour lui.

## But
Depuis l'historique, on pourra « rejouer » une draft : mêmes **bannissements**,
choix repartant de zéro. Ta tâche : le paramètre de la page et son chargement.

## À lire
`lib/draft/draft_page.dart` en entier, `lib/draft/models/draft_record.dart`
(`blueBans`, `redBans`, `versusFriend`, `blueName`, `redName`),
`lib/draft/models/draft_state.dart` (`DraftState.empty({withBans})`, `ban`),
`test/draft/draft_page_flow_test.dart` (la page est jouée de bout en bout avec
des chargeurs injectés : `loadChampions`, `loadDataset`, `loadDetail`,
`botThinkingDelay`).

## À faire
1. Ajoute `final DraftRecord? replayOf;` au constructeur de `DraftPage`
   (`const DraftPage({..., this.replayOf})`).
2. Quand `replayOf != null` :
   - le **mode** vient de `replayOf.versusFriend` (`vsFriend` / `vsSite`),
     le paramètre `mode` est alors ignoré ;
   - en mode à deux, les **noms** des joueurs sont ceux de la draft rejouée ;
   - si la draft rejouée avait des bannissements, ils sont **déjà posés** : la
     phase de bannissement est terminée, la draft commence par le premier
     choix ; sinon pas de bannissements. Retrouve les `Champion` à partir de
     leurs identifiants dans la liste chargée ; un identifiant introuvable
     (champion retiré du jeu) est **ignoré** et sa case reste libre — mais comme
     `DraftState.ban` impose l'ordre et le camp, pose-les dans l'ordre
     `draftBanOrder` et, si une case manque, la phase de ban reprend normalement
     pour les cases libres ;
   - l'interrupteur « Bannissements » est **masqué** (les bans sont figés par la
     draft rejouée) ;
   - « Recommencer » (icône) et « Refaire une draft » **gardent les mêmes
     bannissements** (sinon ce ne serait plus « rejouer ») ;
   - un petit bandeau au-dessus du statut : « Vous rejouez la draft du
     {date} : mêmes bannissements. » (utilise `formatDraftDate` de
     `draft_history_tile.dart`, **sans modifier ce fichier** — il est à T10).
3. Tests (ajoute-les dans un **nouveau** fichier
   `test/draft/draft_page_replay_test.dart`, en reprenant l'outillage de
   `draft_page_flow_test.dart` sans le modifier) : rejouer avec bans → pas de
   phase de ban et cases bannies affichées ; rejouer sans bans ; mode à deux et
   noms repris ; champion introuvable ignoré ; « Refaire » garde les bans ;
   la draft jouée est enregistrée dans l'historique comme une nouvelle entrée.

## Fichiers qui t'appartiennent
`lib/draft/draft_page.dart`, `test/draft/draft_page_replay_test.dart`.
**Ne touche pas** aux autres fichiers du dossier `lib/draft` (T4, T5, T10 y
travaillent). Si tu as besoin d'une aide qui n'existe pas, mets-la dans
`draft_page.dart`.

## Définition de « fini »
Analyse propre, `flutter test test/draft/draft_page_flow_test.dart
test/draft/draft_page_replay_test.dart` passe, message au journal : « T9a fait :
`DraftPage(replayOf:)` disponible ».
