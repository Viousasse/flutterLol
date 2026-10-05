# Research: Recherche et comparaison des champions

Décisions tirées des commentaires du code, des messages de commit (`033ca39`, `32fac77`, `a30c9fc`) et des tests. Quand aucune trace d'alternative n'existe, c'est écrit.

## Croissance non linéaire des caractéristiques

- **Decision**: le gain par niveau publié par Riot est multiplié par `steps × (0,7025 + 0,0175 × steps)` où `steps = niveau − 1` (`CombatStatsCalculator.growthFactor`). Le facteur vaut 0 au niveau 1 et 17 au niveau 18.
- **Rationale**: le commentaire du code dit que « Riot ne fait pas croître les caractéristiques de façon linéaire ». Le test `la croissance n est pas linéaire : le milieu est sous la moitié` fixe ce comportement (au niveau 10, le gain reste sous la moitié du gain total augmenté d'une marge de 10 %).
- **Alternatives considered**: la croissance linéaire (gain × `niveau − 1`) n'est pas retenue dans le code ; aucune trace d'autre alternative.
- **Remarque**: le commentaire du code dit que le facteur « vaut 1 au niveau 18 », alors que le code et le test donnent 17 (17 niveaux de gain complets). Le comportement de référence est celui du code et du test.

## Plafonds de vitesse d'attaque et de critique

- **Decision**: vitesse d'attaque plafonnée à 2,5 (`attackSpeedCap`), chance de critique ramenée dans [0 ; 1].
- **Rationale**: « le jeu plafonne la vitesse d'attaque à 2,5 attaques par seconde » (commentaire) ; tests `la vitesse d attaque est plafonnée à 2,5` et `la chance de critique est plafonnée à 100 %`.
- **Alternatives considered**: aucune trace.

## Vitesse d'attaque et de déplacement : ordre des bonus

- **Decision**: le bonus de niveau (gain par niveau / 100 × facteur) et le bonus des objets (`PercentAttackSpeedMod`) s'additionnent, puis s'appliquent à la vitesse de base. Pour le déplacement, bonus fixe d'abord, bonus en pourcentage ensuite.
- **Rationale**: commentaires du code et tests `la vitesse d attaque des objets s applique à la vitesse de base` et `la vitesse de déplacement combine bonus fixe puis pourcentage`.
- **Alternatives considered**: aucune trace.

## Lignes alimentées seulement par les objets

- **Decision**: « Puissance », « Chances de coup critique (%) » et « Vol de vie (%) » n'apparaissent que si l'un des deux champions a une valeur non nulle (`ComparisonBuilder.build`).
- **Rationale**: « sans objet, elles seraient des rangées de zéros » (commentaire). Tests `sans objet, les lignes alimentées par les objets sont absentes` et `un seul champion équipé suffit à faire apparaître la ligne`.
- **Alternatives considered**: afficher toujours les onze lignes (rejeté implicitement par le commentaire).

## Barres relatives à la plus grande valeur

- **Decision**: la barre de la plus forte valeur est pleine, l'autre est proportionnelle ; avec une plus grande valeur nulle, la fraction est 0.
- **Rationale**: « la plus forte valeur remplit sa barre, l'autre se lit en proportion » (commentaire de `StatComparison`) ; test `deux valeurs nulles ne divisent pas par zéro`.
- **Alternatives considered**: aucune trace.

## Gagnant dit en toutes lettres

- **Decision**: `StatCompareRow` annonce « avantage au champion de gauche/droite » ou « égalité » dans son libellé sémantique, en plus de la teinte.
- **Rationale**: commentaire : « pour ne pas reposer sur la seule couleur ».
- **Alternatives considered**: aucune trace.

## Fiches détaillées téléchargées à la demande

- **Decision**: seules les fiches des deux champions choisis sont téléchargées (`ChampionService.fetchDetail`) ; les objets ne sont téléchargés qu'au premier ajout.
- **Rationale**: « téléchargée à la demande plutôt que pour les 170 d'avance » et « la comparaison de deux champions nus n'a pas besoin d'objets » (commentaires de `ComparePage`).
- **Alternatives considered**: précharger toutes les fiches (rejeté par le commentaire).

## Garde contre les choix qui arrivent pendant un chargement

- **Decision**: après `await`, les données ne sont écrites que si `left` et `right` sont toujours ceux qui ont déclenché le chargement.
- **Rationale**: « Un autre choix a pu arriver pendant le chargement » (commentaire). Aucun test d'écran ne le couvre.
- **Alternatives considered**: aucune trace.

## Duel : seuils de fiabilité

- **Decision**: un duel exige au moins 8 parties (`MatchupService.minGames`) ; un taux global exige au moins 100 parties (`OverallRecord.minReliableGames`). Le duel additionne toutes les voies.
- **Rationale**: commentaires de `MatchupService.headToHead` et `OverallRecord` (« en dessous, ça ne veut rien dire » pour le global) ; le test `donne le bilan d un duel précis, ou rien s il est trop rare` couvre le seuil du duel. L'origine des 8 et des 100 n'est pas documentée plus avant : pas de trace de calcul statistique.
- **Alternatives considered**: aucune trace.

## Le duel est un bonus

- **Decision**: la comparaison se charge même si le fichier de matchups échoue ; la carte de duel disparaît (`dataset.isEmpty`).
- **Rationale**: commentaire « Le duel est un bonus : sans le fichier embarqué, les caractéristiques restent comparables ». Même logique pour le tri par victoires de la liste des champions.
- **Alternatives considered**: afficher une erreur bloquante (non retenue).

## Normalisation de la recherche

- **Decision**: `normalizeSearchText` met en minuscules, replie les accents français courants (à â ä é è ê ë î ï ô ö ù û ü ç œ) et supprime espaces, apostrophes droites et courbes, points et tirets.
- **Rationale**: « pour que "zoe" trouve Zoé et "chogath" trouve Cho'Gath » (commentaire). Tests `search_text_test.dart`.
- **Alternatives considered**: aucune trace ; la table couvre les caractères français, pas toutes les langues.

## Recherche globale : préfixe avant contenu, 8 par section

- **Decision**: les noms qui commencent par la saisie passent avant ceux qui la contiennent ; 8 résultats maximum par section.
- **Rationale**: « "ah" doit proposer Ahri avant Shaco » ; « au-delà, la liste devient une page à défiler plutôt qu'un résultat : mieux vaut inviter à préciser » (commentaires). Tests `global_search_test.dart`.
- **Alternatives considered**: aucune trace.

## Filtre et tri hors de l'écran

- **Decision**: `ChampionFilter.apply` est une fonction pure qui renvoie une nouvelle liste ; à difficulté égale ou taux égal, l'ordre alphabétique départage ; un champion sans taux fiable passe après tous ceux qui en ont un.
- **Rationale**: « hors de l'écran pour pouvoir être testés sans le monter » (commentaire) ; tests `ne modifie pas la liste reçue`, `trie par taux de victoire, les champions sans donnée à la fin`.
- **Alternatives considered**: aucune trace.

## Histoire repliée

- **Decision**: `ExpandableText` replie à 5 lignes avec un lien pour déplier, et masque le lien pour un texte court.
- **Rationale**: « sans repli, elles repoussent les capacités, les runes et les matchups loin sous l'écran » (commentaire) ; tests `expandable_text_test.dart`.
- **Alternatives considered**: aucune trace.

## Équiper une build enregistrée

- **Decision**: charger une build remplace les objets du champion ; un objet retiré par Riot est ignoré (`ItemService.byIds` filtre les identifiants inconnus).
- **Rationale**: commentaire de `loadSavedBuild` ; commit `a30c9fc`.
- **Alternatives considered**: ajouter les objets de la build à ceux déjà présents (non retenu : le code remplace) ; aucune autre trace.

## Choix de la feuille de rôles dans la comparaison

- **Decision**: la feuille de choix de champion reçoit un filtre de rôle construit depuis le profil de voies des matchups (`RoleFilters.forProfile(LaneProfile.fromDataset(dataset))`), sans voie initiale (tous les champions).
- **Rationale**: apport ultérieur du filtre de rôle partagé (voir `lib/team/services/role_filters.dart`) ; sans fichier de matchups, la feuille s'ouvre sans puces.
- **Alternatives considered**: aucune trace.
