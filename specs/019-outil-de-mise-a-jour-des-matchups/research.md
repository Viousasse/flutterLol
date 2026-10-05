# Research: Outil de mise à jour des matchups

## 1. Calculer les matchups soi-même

- **Decision**: l'outil lit des parties via match-v5 et compte, voie par voie, qui a gagné contre qui.
- **Rationale**: commit `6436bbb` : « L'API Riot n'a pas d'endpoint de counters » ; le script les calcule « comme le font les sites de statistiques ». Le fichier est embarqué : « aucune clé API dans l'app, aucun appel réseau à l'exécution ».
- **Alternatives considered**: pas de trace d'un service tiers évalué.

## 2. Joueurs Master, solo/duo, plateforme `euw1`

- **Decision**: échantillon de joueurs du classement Master (mélangés avec une graine fixe `Random(7)`), file classée solo/duo (420).
- **Rationale**: données de haut niveau, comparables ; la graine rend l'échantillon reproductible. Le choix de Master et d'EUW n'est pas justifié plus loin dans le code ; il est repris dans l'étiquette `MASTER+` et `euw1`.

## 3. Vis-à-vis par voie

- **Decision**: pour chaque voie, exactement deux joueurs d'équipes différentes face à face ; sinon la voie est ignorée.
- **Rationale**: une voie sans vis-à-vis net (duo mal identifié) fausserait le bilan. Aucun commentaire plus précis.

## 4. Seuil de 8 parties côté application

- **Decision**: l'application tait les paires de moins de 8 parties (`MatchupService.minGames`).
- **Rationale**: « trois parties gagnées sur quatre n'est pas un counter » ; le guide dit : relancer avec davantage de parties plutôt que de baisser le seuil. D'où la demande « télécharge plus de données ».

## 5. Alignement des noms

- **Decision**: table d'alias `FiddleSticks -> Fiddlesticks`.
- **Rationale**: match-v5 n'écrit pas toujours les noms comme Data Dragon ; l'application cherche par identifiant Data Dragon. 102 occurrences corrigées dans le fichier (commit `d26e563`).

## 6. Respect de la limite de la clé

- **Decision**: fenêtre glissante de 122 s, pause à 95 requêtes ; sur 429, attente de `retry-after` + 1 s puis nouvel essai.
- **Rationale**: limite de 100 requêtes par 2 minutes d'une clé de développement. La marge (95 sur 100, 122 s sur 120) n'est pas expliquée ; elle laisse de la place aux requêtes en vol.

## 7. Reprise et sauvegarde atomique

- **Decision**: sauvegarde toutes les 100 parties dans `<sortie>.progress.json`, écrite dans un `.tmp` puis renommée.
- **Rationale**: « une coupure en pleine écriture ne doit jamais laisser une sauvegarde à moitié écrite ». La reprise suppose la même commande et le même `--output`.

## 8. Une partie 404 est ignorée, les autres erreurs arrêtent

- **Decision**: 404 : marquée traitée ; autre statut : sauvegarde puis arrêt.
- **Rationale**: « Une partie supprimée ou devenue inaccessible ne doit pas arrêter un calcul de plusieurs heures. Toute autre réponse (clé refusée ou expirée) l'arrête ».

## 9. Fusion avec vieillissement

- **Decision**: `--merge-with` additionne un fichier existant après lui avoir appliqué `--decay` ; `matches` et le décompte par patch vieillissent aussi.
- **Rationale**: « Les vieilles parties pèsent moins que les récentes ». Les victoires sont bornées aux parties après arrondi, et les paires à 0 partie disparaissent. Le facteur par défaut (1) est sans effet pour rester rétro-compatible.

## 10. Comparaison numérique des patchs

- **Decision**: `parsePatch` lit `majeur.mineur` ; `16.9` précède `16.10`.
- **Rationale**: « ce qu'un tri alphabétique ne dirait pas ». Un patch illisible n'est jamais écarté par `--min-patch` : « mieux vaut garder une partie que la perdre à tort ».

## 11. Parties écartées par `--min-patch` quand même marquées traitées

- **Decision**: l'identifiant est ajouté à `doneIds` avant le filtre.
- **Rationale**: « une reprise ne la relira pas ».

## 12. Étiquette de patch : plage plutôt que masque

- **Decision**: `patch` devient « 16.16–16.19 » quand le fichier mélange plusieurs patchs, et l'application l'affiche telle quelle (note « d'où viennent les données », pluriel « patchs »).
- **Rationale**: guide : le fichier mélange plusieurs versions du jeu, « l'application l'affiche telle quelle plutôt que de le cacher ».

## 13. Champ `patches` informatif

- **Decision**: `patches` donne les parties par patch ; l'application l'ignore (test « MatchupDataset ignore le champ informatif patches »).
- **Rationale**: voir ce qui pèse dans la plage. Le fichier embarqué actuel ne le contient pas (régénéré avant l'ajout).

## 14. 30 parties par joueur

- **Decision**: `count=30` identifiants par joueur.
- **Rationale**: commit `d26e563` : « ce qui économise des requêtes d'identifiants » (contre 10 au départ).

## 15. Générer dans `build/` puis copier

- **Decision**: le guide recommande `--output build/matchups.json` puis copie manuelle vers `assets/`.
- **Rationale**: « évite de remplacer les données de l'application avant la fin du calcul ». Le guide demande ensuite `flutter test`.
