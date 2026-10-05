# Research: Matchups, contre-picks et points forts

## Décision 1 : seuil de fiabilité à 8 parties (`MatchupService.minGames`)

- **Decision**: une paire champion/adversaire n'est lue telle quelle qu'à partir de 8 parties.
- **Rationale**: commentaire du code : « En dessous, un pourcentage ne veut rien dire : trois parties gagnées sur quatre n'est pas un "counter" ». Le même seuil sert à `CounterPick.isReliable`, à `LaneProfile.fits` et à `MatchupService.headToHead`.
- **Alternatives considered**: aucune trace d'autre valeur dans le code ou l'historique ; la valeur 8 n'est pas justifiée chiffrée au-delà de ce commentaire.

## Décision 2 : repli sur les bilans peu fiables, au lieu d'une liste vide

- **Decision**: si un adversaire a moins de 5 bilans fiables (`minReliablePicks`) et que `includeLowConfidence` est vrai, `CounterService` complète avec les bilans de moins de 8 parties, jusqu'à 15 propositions (`maxPicks`).
- **Rationale**: demande de l'utilisateur (« fais en sorte que quand je demande un conteurs il y a une data »). Message du commit `0b3b86d` : « Le repli sur les bilans peu fiables donne toujours des propositions ». Le message du commit `55b4700` précise l'effet des données : après passage à 7 600 parties, « contre-picks fiables à 168 champions sur 173 », donc 5 champions dépendent encore du repli. Un test sur les vraies données (`chaque champion des vraies données reçoit des contre-picks`) garantit qu'aucun adversaire n'a une liste vide.
- **Alternatives considered**: le premier jet (`20e90af`) n'avait pas de repli et affichait une liste vide pour un champion rare ; ce comportement est ce que la demande de l'utilisateur corrige. Pas d'autre option tracée.

## Décision 3 : taux tempéré (`smoothedWinRate`) pour classer les petits échantillons

- **Decision**: `(victoires + 10 × 0,5) / (parties + 10)`, soit 10 parties fictives à 50 % (`CounterPick.priorGames`).
- **Rationale**: commentaire du code : 3 victoires sur 3 « valent alors environ 62 %, et non 100 % » ; il sert à ne pas laisser « un 2 sur 2 passer devant un 14 sur 20 ». Il ne sert qu'à classer les bilans peu fiables ; le pourcentage affiché reste le taux réel.
- **Alternatives considered**: non documentées dans le code ; tests `classe les petits échantillons avec un taux tempéré` et `le taux tempéré rapproche les petits échantillons de 50 %`.

## Décision 4 : ordre total déterministe

- **Decision**: tri par taux (ou taux tempéré), puis nombre de parties décroissant, puis identifiant du champion alphabétique.
- **Rationale**: commentaire dans `_rank` : à pourcentage égal, celui qui a le plus de parties est plus fiable, « puis l'ordre alphabétique garde une liste stable ». Test `à pourcentage égal, le plus de parties passe devant`.
- **Alternatives considered**: sans objet.

## Décision 5 : les faiblesses n'utilisent que des bilans fiables et défavorables

- **Decision**: `weakAgainst` ne garde que les paires fiables dont le taux est inférieur à 50 %, limitées à 5.
- **Rationale**: commentaire : « une faiblesse annoncée sur trois parties ne servirait à rien ». Contrairement aux forces, il n'y a pas de repli : un champion sans faiblesse fiable a simplement une liste vide (test `un champion sans aucune faiblesse reçoit une liste vide`) et la section n'est pas affichée.
- **Alternatives considered**: non documentées.

## Décision 6 : `strongAgainst` réutilise la forme de `counters`

- **Decision**: `strongAgainst` renvoie des `CounterPick` où `championId` désigne l'adversaire, et les taux sont ceux du champion demandé.
- **Rationale**: commentaire : « Le résultat a la même forme que [counters] », ce qui permet de réutiliser `CounterTile` et `_rank`.
- **Alternatives considered**: un type dédié n'a pas été créé ; le risque de confusion est documenté dans le commentaire du service et par la ligne « Le pourcentage est celui de … » sous la liste.

## Décision 7 : chargement unique du fichier, mise en cache du futur

- **Decision**: `MatchupService.load` met en cache le futur en cours (`_pending`) et le résultat (`_cache`) ; `_pending` est vidé dans `finally`.
- **Rationale**: commentaire : « Le futur en cours est mis en cache, pas seulement son résultat, comme pour les autres services » ; deux écrans qui ouvrent en même temps ne lisent pas le fichier (2,1 Mo) deux fois. En cas d'échec, rien n'est mis en cache : « Réessayer » relit l'asset (principe II).
- **Alternatives considered**: non documentées.

## Décision 8 : voie remise à zéro au changement de champion

- **Decision**: `pickOpponent` / `pickChampion` remettent `lane = null`.
- **Rationale**: commentaire : la voie choisie pour le champion précédent n'a peut-être pas de données pour le nouveau.
- **Alternatives considered**: non documentées.

## Décision 9 : la liste des voies vient des données

- **Decision**: `lanesFor` et `lanesPlayedBy` ne proposent que les voies présentes dans les données, triées par volume ; la barre n'apparaît qu'avec plus d'une voie.
- **Rationale**: commentaire : « proposer une voie sans donnée mènerait à une liste vide ».
- **Alternatives considered**: afficher les cinq voies en permanence, écarté implicitement par ce commentaire.

## Décision 10 : note de provenance unique

- **Decision**: `DataSourceNote` est le seul endroit qui formule d'où viennent les chiffres (« Données : 7 600 parties classées Master+ (EUW), patchs 16.16–16.19. »), avec espace insécable comme séparateur de milliers.
- **Rationale**: commentaires : « un seul texte pour tous les écrans évite qu'ils se contredisent » ; l'espace insécable évite qu'un nombre soit coupé en fin de ligne. Le texte est exposé en `static textFor` pour être testé. La note a été introduite plus tard que le premier commit des écrans (elle apparaît dans l'historique avec `0afb3b1`).
- **Alternatives considered**: non documentées.

## Décision 11 : montée de 2 500 à 7 600 parties

- **Decision**: régénérer le fichier avec plus de parties et fusionner avec l'ancien (patchs 16.16 à 16.19).
- **Rationale**: demande de l'utilisateur (« telecharge plus de donner ») ; message du commit `55b4700` : 168 champions sur 173 ont désormais des contre-picks fiables. Le fichier précédent (commit `d26e563`) comptait 2 500 parties au patch 16.18. L'outil sait reprendre une exécution interrompue, fusionner avec un fichier existant et ignorer les parties introuvables (message du commit `0b3b86d`) ; c'est la matière de la spécification 019.
- **Alternatives considered**: non documentées.
