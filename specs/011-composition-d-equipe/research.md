# Research: Composition d'équipe

## Décision 1 : jauges de Riot pour la répartition des dégâts

- **Decision**: `physicalShare = attaque / (attaque + magie)` et `magicShare = magie / (attaque + magie)`, en additionnant les jauges `attackRating` et `magicRating` (0 à 10) de chaque champion ; 0 et 0 si le total est nul.
- **Rationale**: ce sont les seules données de dégâts fournies par Data Dragon sans calcul de build ; la fiche détaillée porte `ChampionStats.attackRating` et `magicRating` (commentaire de `TeamMember` : « l'analyse a besoin de ses jauges et de la description de ses sorts, que la liste ne donne pas »).
- **Alternatives considered**: aucune trace dans le code d'une autre source de dégâts (par exemple les statistiques de base) ; non étudié.

## Décision 2 : seuil de 20 % par type de dégâts

- **Decision**: `minDamageShare = 0.2` ; un type sous 20 % déclenche l'avertissement. Le manque de magie est testé avant le manque de physique.
- **Rationale**: commentaire : « Part minimale de chaque type de dégâts avant de signaler un manque ». Le message d'avertissement explique la conséquence (l'adversaire peut empiler l'armure ou la résistance magique). Aucune justification chiffrée de la valeur 20 % n'est écrite.
- **Alternatives considered**: non documentées.

## Décision 3 : première ligne = rôle Tank ou défense ≥ 7

- **Decision**: `frontlineDefense = 7` sur la jauge de défense de Riot, ou présence du tag `Tank`.
- **Rationale**: commentaire : « Une jauge de défense de Riot à partir de laquelle un champion tient la première ligne, même sans le rôle Tank ». Test `compte la première ligne par le rôle Tank ou la défense`.
- **Alternatives considered**: non documentées.

## Décision 4 : contrôle repéré par mots-clés dans la description française

- **Decision**: `CrowdControl.keywords` liste des fragments (`étourdi`, `immobilis`, `charme`, `terrifi`, `enracin`, `réduit au silence`, `dans les airs`…) cherchés en minuscules dans la description de chacun des quatre sorts ; le passif n'est pas compté.
- **Rationale**: commentaire de classe : « Data Dragon ne dit pas quel sort contrôle l'adversaire […] l'estimation est honnête mais imparfaite, et l'écran la présente comme telle » ; les mots sont « volontairement étroits : "projette" ou "provoque" décrivent aussi bien un projectile ou des dégâts ». Le passif est exclu car « il ne se lance pas ». Le message du bilan ajoute « estimation d'après les descriptions des sorts ».
- **Alternatives considered**: aucune trace d'une table manuelle de contrôles par champion ; la seule alternative implicite (« mots larges ») est rejetée par le commentaire.

## Décision 5 : trois sorts de contrôle minimum pour l'équipe

- **Decision**: `minControlSpells = 3`.
- **Rationale**: commentaire : « Sorts de contrôle attendus pour que l'équipe puisse bloquer une cible ». Valeur non justifiée plus avant.
- **Alternatives considered**: non documentées.

## Décision 6 : pas de verdict sous 3 champions

- **Decision**: `minMembersForVerdict = 3` ; avec 1 ou 2 membres, un seul constat « Équipe incomplète ». Entre 3 et 4 membres, les trois constats sont donnés plus une précision « Il manque N champion(s) ».
- **Rationale**: commentaire : « En dessous, un verdict sur l'équilibre ne repose sur rien : on invite à compléter l'équipe plutôt que d'alerter à tort ». Tests `invite à compléter l équipe avant de donner un avis` et `ajoute une précision tant que l équipe n est pas complète`.
- **Alternatives considered**: non documentées.

## Décision 7 : le bilan ne compte que les champions dont la fiche est arrivée

- **Decision**: `_members` ne retient que les places dont la fiche est dans `details` ; une fiche manquante n'empêche pas de placer le champion.
- **Rationale**: commentaire de `loadDetail` : « Un échec laisse le champion dans l'équipe, simplement absent du bilan ». Les fiches téléchargées sont conservées pour ne pas être redemandées.
- **Alternatives considered**: bloquer le placement tant que la fiche n'est pas là, non retenu (aucune trace de la raison).

## Décision 8 : constat non porté par la couleur seule

- **Decision**: `InsightTile` associe une icône et un titre à chaque constat (coche, triangle d'avertissement, information).
- **Rationale**: commentaire : « L'icône et le titre disent s'il s'agit d'un point fort ou d'un manque : la couleur seule ne porterait pas l'information ».
- **Alternatives considered**: non documentées.

## Décision 9 : segment à 0 % non dessiné

- **Decision**: `DamageSplitBar` n'ajoute un segment que si son pourcentage arrondi est supérieur à 0.
- **Rationale**: commentaire : « un `Expanded` de flex 0 n'a pas de largeur définie ». Tests `une équipe 100 % physique ne casse pas la barre` et `sans dégâts, la barre reste affichable`.
- **Alternatives considered**: non documentées.

## Décision 10 : filtre de rôle facultatif

- **Decision**: le profil de voies est chargé sans bloquer l'écran ; en cas d'échec `RoleFilters.loadProfile` renvoie `null` et la feuille s'affiche sans puces.
- **Rationale**: commentaire : « le filtre est un confort, son absence ne doit jamais empêcher de choisir un champion ». Ajouté après le premier commit de la fonctionnalité (tâche de câblage du filtre de rôle).
- **Alternatives considered**: non documentées.
