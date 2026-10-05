# Research: Sorts d'invocateur conseillés et onglet Outils

## Décision 1 : plans de sorts rédigés à la main, par voie puis par profil

- **Decision**: `SummonerSpellRecommender.recommend` applique une table écrite à la main : d'abord la voie (jungle, bas, soutien, haut, milieu), puis le profil (premier tag) quand la voie est inconnue.
- **Rationale**: commentaire du code : « Data Dragon ne publie aucun sort conseillé : comme pour les runes, ces choix sont rédigés à la main, par voie et par profil, d'après les usages les plus répandus ». Les tests couvrent les cas (`un jungler prend Châtiment`, `un tireur en bas prend Soins`, `sans voie connue, le profil décide`, `chaque plan donne deux sorts et une raison`).
- **Alternatives considered**: calculer les sorts à partir de parties réelles : aucune trace ; les données de matchups ne contiennent pas les sorts choisis. Non étudié ailleurs.

## Décision 2 : la voie principale vient des matchups, avec un seuil de 30 parties

- **Decision**: `MatchupService.mainLaneOf` renvoie la voie où le champion a le plus de parties, ou `null` sous 30 parties (`minGamesForMainLane`).
- **Rationale**: commentaire : « En dessous, la voie la plus jouée repose sur trop peu de parties pour être fiable : on préfère dire qu'on ne la connaît pas ». Quand la voie est inconnue, le profil décide seul (`test/matchups/main_lane_test.dart` : `ne conclut pas quand les données sont trop rares`).
- **Alternatives considered**: utiliser le seul tag du champion ; c'est le repli retenu, pas la voie.

## Décision 3 : Saut éclair toujours, plus un sort selon le contexte

- **Decision**: chaque plan commence par Saut éclair (`SummonerFlash`) et ajoute un deuxième sort (Châtiment, Soins, Épuisement, Embrasement ou Téléportation). Pour la jungle, Châtiment passe en premier.
- **Rationale**: règle tirée de la table : le plan de chaque voie contient Saut éclair ; aucune justification écrite au-delà des raisons affichées. La jungle exige Châtiment : « sert à sécuriser les monstres et les objectifs ».
- **Alternatives considered**: non documentées.

## Décision 4 : Tank ou Combattant → Téléportation en haut et au milieu

- **Decision**: `_isFrontliner(profile)` est vrai pour `Tank` et `Fighter` ; ils prennent Téléportation en haut (« permet de rejoindre les combats et de revenir en voie ») et au milieu, les autres profils Embrasement.
- **Rationale**: choix éditorial codé tel quel ; commentaires absents, raisons affichées dans le code.
- **Alternatives considered**: non documentées.

## Décision 5 : seuls les sorts de la partie classique

- **Decision**: `SummonerSpell.isClassic` filtre sur `modes` contenant `CLASSIC`.
- **Rationale**: commentaire : « Riot liste aussi ceux des modes événementiels, qui n'ont rien à faire dans une recommandation ». Test `ne retient que les sorts de la partie classique`.
- **Alternatives considered**: lister une liste blanche d'identifiants ; non retenu (aucune trace de la raison).

## Décision 6 : cache du futur en cours, et du résultat seulement en cas de succès

- **Decision**: `SummonerSpellService.fetchAll` met en cache le futur en cours (`_pending`) puis le résultat (`_cache`), ce dernier seulement après parsing réussi.
- **Rationale**: commentaires : « plusieurs fiches champion ouvertes coup sur coup ne retéléchargent pas le fichier » et « un échec doit laisser le service dans l'état où un nouvel appel retélécharge tout » (principe II).
- **Alternatives considered**: non documentées.

## Décision 7 : échec silencieux

- **Decision**: `loadSummonerSpells` avale l'erreur : la section est absente et aucun message n'est affiché.
- **Rationale**: commentaire : « Les sorts conseillés sont un bonus : sans eux, la fiche reste complète » et « Pas de section de sorts, rien d'autre à signaler à l'utilisateur ». Même logique pour les runes et objets de la fiche.
- **Alternatives considered**: afficher « Réessayer » ; non retenu, pour ne pas alourdir la fiche d'une erreur sur une donnée secondaire.

## Décision 8 : un identifiant retiré par Riot est ignoré

- **Decision**: `byIds` renvoie `[for (final id in ids) ?all[id]]` : un identifiant absent est sauté.
- **Rationale**: commentaire : « Un identifiant que Riot ne publie plus est ignoré plutôt que de faire échouer l'affichage ». La section peut donc n'afficher qu'un sort, ou aucun (alors absente, car testée par `summonerSpells.isNotEmpty`).
- **Alternatives considered**: non documentées.

## Décision 9 : un onglet « Outils » plutôt qu'une section d'accueil

- **Decision**: la section d'outils est déplacée de l'accueil vers un onglet dédié de la barre de navigation, entre « Objets » et « Carte ».
- **Rationale**: demande de l'utilisateur (« cree un autre onglets dans la nav bar pour outils ») ; le commit `a4475d7` retire la section de `home_page.dart`. Le document de classe de `ToolsPage` précise le contenu de l'onglet.
- **Alternatives considered**: garder la section sur l'accueil (c'était l'état du commit `a96b9d2`) ; remplacée sur demande.

## Décision 10 : onglets construits à la première visite, puis conservés

- **Decision**: `MainNavigation` ne construit un onglet que s'il est dans `visitedTabs`, et les garde dans un `IndexedStack`.
- **Rationale**: commentaire : revenir à un onglet retrouve « son défilement, sa recherche et ses filtres, sans pour autant télécharger au démarrage les données des onglets que l'utilisateur n'a jamais visités ». Le principe date du commit `6ea513f` ; l'onglet Outils s'y ajoute sans changement.
- **Alternatives considered**: reconstruire à chaque visite (comportement antérieur à `6ea513f`).

## Décision 11 : tuiles sur deux colonnes calculées par `LayoutBuilder`

- **Decision**: la largeur d'une tuile est `(largeur disponible − 10) / 2` dans un `Wrap`.
- **Rationale**: aucune justification écrite. Le code ne gère pas un nombre de colonnes variable (contrairement à la spécification 009 pour les grilles d'objets) : sur un écran très large, les tuiles s'étirent. Constaté, non justifié.
- **Alternatives considered**: non documentées.
