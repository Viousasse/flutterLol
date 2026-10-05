# Feature Specification: Recherche et comparaison des champions

**Feature Branch**: `005-recherche-et-comparaison-des-champions` (travail livré sur `main`, sans branche dédiée)

**Created**: 2026-10-05

**Status**: Implemented

**Input**: User description: « fais tout les changements pour ameliorer ca » (commit `033ca39` : comparaison de champions, recherche globale, filtres) ; puis, avec une capture de la page de comparaison : « rajoute par nivaux pour les comparaison et on peut leurs ajouter des items pour les comparer » (commit `32fac77`, prolongé par `a30c9fc` qui permet d'équiper une build enregistrée).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Comparer deux champions, niveau et objets compris (Priority: P1)

Le joueur ouvre « Comparer » (depuis l'onglet Outils, depuis la liste des champions ou depuis la fiche d'un champion), choisit deux champions, règle le niveau de 1 à 18 et leur ajoute jusqu'à six objets chacun. L'écran affiche, ligne par ligne, les caractéristiques de chacun avec des barres face à face, le gagnant de chaque ligne, puis un bilan en duel tiré des parties classées Master+.

**Why this priority**: c'est le cœur de la demande (« par niveaux » et « items pour les comparer ») et la fonction qui n'existait pas du tout avant ce travail.

**Independent Test**: ouvrir Comparer, choisir deux champions, déplacer le curseur de niveau, ajouter un objet à l'un des deux : les valeurs affichées changent en conséquence, sans autre fonctionnalité.

**Acceptance Scenarios**:

1. **Given** deux champions choisis au niveau 1 et sans objet, **When** la comparaison s'affiche, **Then** les points de vie, dégâts d'attaque, vitesse d'attaque, armure, résistance magique, vitesse de déplacement, portée et difficulté sont ceux de base de Riot, et les lignes « Puissance », « Chances de coup critique » et « Vol de vie » sont absentes.
2. **Given** une comparaison affichée, **When** le joueur passe le niveau de 1 à 18, **Then** chaque caractéristique croît selon une courbe non linéaire (le milieu du curseur est sous la moitié du gain total) et atteint au niveau 18 le gain par niveau publié multiplié par 17.
3. **Given** un champion équipé d'un objet qui donne de la puissance, **When** la comparaison se met à jour, **Then** la ligne « Puissance » apparaît même si l'autre champion n'a aucun objet.
4. **Given** une ligne dont les deux valeurs diffèrent, **When** elle s'affiche, **Then** la plus forte est teintée, sa barre est pleine, l'autre est proportionnelle, et le gagnant est aussi annoncé en toutes lettres aux lecteurs d'écran (avantage à gauche, à droite ou égalité).
5. **Given** un champion équipé de six objets, **When** le joueur regarde ses emplacements, **Then** la case « + » a disparu ; **When** il appuie sur un objet, **Then** celui-ci est retiré.

---

### User Story 2 - Voir le bilan en duel et le taux de victoire global (Priority: P2)

Sous les caractéristiques, une carte « En duel » dit en une phrase qui l'emporte entre les deux champions d'après les parties Master+ et donne le taux de victoire global de chacun.

**Why this priority**: elle donne le sens « jeu » à la comparaison, mais la comparaison des caractéristiques reste utile sans elle.

**Independent Test**: comparer deux champions présents dans le fichier de matchups et lire la carte ; comparer ensuite deux champions jamais opposés et lire le message d'absence de tendance.

**Acceptance Scenarios**:

1. **Given** deux champions opposés dans au moins 8 parties du fichier de matchups, **When** la carte s'affiche, **Then** elle nomme le vainqueur du duel, le pourcentage de victoires du champion de gauche et le nombre de parties.
2. **Given** deux champions opposés dans moins de 8 parties, **When** la carte s'affiche, **Then** elle dit qu'il n'y a pas assez de parties Master+ pour en tirer une tendance.
3. **Given** un champion de moins de 100 parties au total, **When** son taux global s'affiche, **Then** la ligne indique « données insuffisantes » au lieu d'un pourcentage.
4. **Given** le fichier de matchups illisible, **When** la comparaison s'affiche, **Then** les caractéristiques restent comparables et la carte de duel est absente.

---

### User Story 3 - Équiper une build enregistrée (Priority: P2)

Sous un champion choisi, un lien « Charger une build » ouvre la liste des builds enregistrées ; en choisir une remplace les objets de ce champion par les siens.

**Why this priority**: ajouté en prolongement de la demande d'objets (commit `a30c9fc`) pour éviter de re-saisir six objets ; la saisie manuelle (US1) suffit à elle seule.

**Independent Test**: enregistrer une build, ouvrir Comparer, choisir un champion, appuyer sur « Charger une build », choisir la build.

**Acceptance Scenarios**:

1. **Given** au moins une build enregistrée, **When** le joueur en choisit une, **Then** les objets du champion sont remplacés (et non ajoutés) par ceux de la build, dans l'ordre.
2. **Given** aucune build enregistrée, **When** il appuie sur « Charger une build », **Then** un message l'invite à en créer une depuis l'onglet Objets et aucune feuille ne s'ouvre.
3. **Given** une build qui contient un objet que Riot a retiré depuis, **When** elle est chargée, **Then** cet objet est ignoré et les autres sont équipés.

---

### User Story 4 - Retrouver un champion ou un objet depuis l'accueil (Priority: P2)

Une loupe sur l'accueil ouvre une barre de recherche unique : en tapant, le joueur voit les champions et les objets correspondants et ouvre la fiche du champion ou le détail de l'objet.

**Why this priority**: répond à « améliorer ça » en évitant de savoir dans quel onglet chercher ; indépendante de la comparaison.

**Independent Test**: depuis l'accueil, appuyer sur la loupe, taper « ah » puis « zoe » sans accent.

**Acceptance Scenarios**:

1. **Given** la page de recherche ouverte, **When** le champ est vide, **Then** un message invite à taper le nom d'un champion ou d'un objet.
2. **Given** la saisie « ah », **When** les résultats s'affichent, **Then** les noms qui commencent par « ah » (Ahri) passent avant ceux qui le contiennent seulement (Shaco).
3. **Given** la saisie « zoe » ou « chogath », **When** les résultats s'affichent, **Then** Zoé et Cho'Gath sont trouvés (accents, apostrophes, espaces et tirets ignorés).
4. **Given** plus de 8 correspondances dans une section, **When** les résultats s'affichent, **Then** seules les 8 premières sont montrées.
5. **Given** aucune correspondance, **When** les résultats s'affichent, **Then** « Aucun résultat. » est affiché.
6. **Given** un échec réseau au chargement, **When** la page s'ouvre, **Then** un message en français et un bouton « Réessayer » sont proposés.

---

### User Story 5 - Filtrer et trier la liste des champions (Priority: P3)

Sur la liste des champions, le joueur filtre par nom (sans tenir compte des accents), par rôle, par région de Runeterra, et trie par ordre alphabétique, difficulté croissante, difficulté décroissante ou taux de victoire. Un compteur « x sur y » indique le nombre affiché, et un bouton « Comparer » mène à la comparaison.

**Why this priority**: amélioration de confort de la liste existante.

**Independent Test**: dans l'onglet Champions, combiner une région, un rôle et un tri, et vérifier le compteur.

**Acceptance Scenarios**:

1. **Given** un rôle et une recherche, **When** le joueur les combine, **Then** seuls les champions qui satisfont les deux restent.
2. **Given** le tri « Victoires », **When** certains champions n'ont pas assez de parties, **Then** ils passent après tous ceux qui ont un taux, par ordre alphabétique entre eux.
3. **Given** le tri par difficulté, **When** deux champions ont la même difficulté, **Then** l'ordre alphabétique les départage.
4. **Given** le fichier de matchups illisible, **When** le joueur choisit « Victoires », **Then** tous les champions sont à égalité (ordre alphabétique) et le reste de la page fonctionne.
5. **Given** un filtre qui ne laisse aucun champion, **When** la grille s'affiche, **Then** « Aucun champion ne correspond. » apparaît.

---

### User Story 6 - Lire l'histoire d'un champion sans perdre le reste de la fiche (Priority: P3)

Sur la fiche d'un champion, l'histoire est repliée sur quelques lignes avec un lien pour la lire en entier, et un lien « Comparer avec un autre champion » ouvre la comparaison avec ce champion déjà placé à gauche.

**Why this priority**: petit confort qui relie la fiche à la comparaison.

**Independent Test**: ouvrir une fiche, dérouler l'histoire, appuyer sur « Comparer avec un autre champion ».

**Acceptance Scenarios**:

1. **Given** une histoire longue, **When** la fiche s'affiche, **Then** elle est repliée sur 5 lignes avec un lien pour la déplier ; **Given** une histoire courte, **Then** aucun lien n'apparaît.
2. **Given** le lien de comparaison de la fiche, **When** le joueur l'active, **Then** la comparaison s'ouvre avec ce champion à gauche et l'emplacement de droite vide.

---

### Edge Cases

- Premier champion identique au second : le champion déjà placé de l'autre côté est exclu de la feuille de choix (`excludedIds`), donc impossible de comparer un champion avec lui-même.
- Changement de champion pendant le téléchargement des fiches : seules les données qui correspondent encore aux deux emplacements sont affichées (garde `left != currentLeft || right != currentRight` dans `ComparePage.loadDetails`).
- Échec du téléchargement des fiches détaillées : un message en français et « Réessayer » remplacent la comparaison ; les portraits et objets restent choisis.
- Échec du téléchargement des objets au premier ajout : un message s'affiche dans une barre éphémère, rien n'est ajouté.
- Niveau hors de 1 à 18 (valeur transmise au calcul) : ramené dans les bornes.
- Vitesse d'attaque : plafonnée à 2,5 attaques par seconde, quel que soit le cumul niveau et objets.
- Chance de coup critique : plafonnée à 100 %.
- Deux valeurs nulles sur une ligne : aucune division par zéro, barres vides, égalité.
- Recherche vide ou composée uniquement d'espaces : aucune liste, le message d'invitation reste affiché.
- Fichier de matchups absent : la carte de duel disparaît mais la comparaison fonctionne ; le tri « Victoires » dégrade en tri alphabétique.
- Niveau choisi conservé quand on change de champion (le curseur n'est pas remis à 1).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT permettre de choisir deux champions distincts pour les comparer, via une feuille de choix avec recherche par nom et, quand les données de voies sont disponibles, des puces de filtre par rôle.
- **FR-002**: Le système DOIT afficher pour chaque champion, à un niveau de 1 à 18 choisi au curseur, les points de vie, dégâts d'attaque, vitesse d'attaque, armure, résistance magique, vitesse de déplacement, portée d'attaque et difficulté.
- **FR-003**: Le système DOIT faire croître les caractéristiques avec le niveau selon une courbe non linéaire dont le facteur vaut 0 au niveau 1 et 17 au niveau 18, c'est-à-dire le gain par niveau publié multiplié par 17.
- **FR-004**: Le système DOIT permettre d'équiper chaque champion comparé de 0 à 6 objets (ajout depuis le catalogue avec recherche, retrait d'un appui) et ajouter leurs bonus chiffrés aux caractéristiques : points de vie, dégâts d'attaque, puissance, armure, résistance magique, vitesse d'attaque, vitesse de déplacement (fixe puis pourcentage), chance de critique, vol de vie.
- **FR-005**: Le système DOIT plafonner la vitesse d'attaque à 2,5 et la chance de critique à 100 %.
- **FR-006**: Le système DOIT n'afficher les lignes « Puissance », « Chances de coup critique (%) » et « Vol de vie (%) » que si au moins un des deux champions a une valeur non nulle.
- **FR-007**: Le système DOIT désigner pour chaque ligne le gagnant (valeur la plus forte) ou l'égalité, représenter les valeurs par des barres face à face proportionnelles à la plus grande, et annoncer le gagnant en texte et aux lecteurs d'écran en plus de la couleur.
- **FR-008**: Le système DOIT afficher la vitesse d'attaque avec deux décimales et les autres caractéristiques sans décimale.
- **FR-009**: Le système DOIT afficher une carte « En duel » donnant, d'après les parties Master+, le vainqueur du duel, le pourcentage de victoires et le nombre de parties lorsque les deux champions se sont affrontés au moins 8 fois, sinon un message d'absence de tendance.
- **FR-010**: Le système DOIT afficher le taux de victoire global de chaque champion, ou « données insuffisantes » en dessous de 100 parties.
- **FR-011**: Le système DOIT indiquer l'origine des données du duel (note sous la carte).
- **FR-012**: Le système DOIT permettre d'équiper à un champion les objets d'une build enregistrée en remplaçant les siens, ignorer les objets disparus du catalogue, et informer le joueur quand aucune build n'est enregistrée.
- **FR-013**: Le système DOIT pouvoir ouvrir la comparaison depuis l'onglet Outils, depuis un bouton « Comparer » de la liste des champions et depuis la fiche d'un champion (qui occupe alors l'emplacement de gauche).
- **FR-014**: Le système DOIT proposer une recherche unique, ouverte depuis l'accueil, qui cherche à la fois dans les champions et les objets, place avant les autres les noms qui commencent par la saisie, limite chaque section à 8 résultats, et ouvre la fiche du champion ou le détail de l'objet.
- **FR-015**: Le système DOIT ignorer majuscules, accents, apostrophes, points, tirets et espaces dans toute recherche de nom (liste des champions, recherche globale, choix d'un objet).
- **FR-016**: Le système DOIT permettre de filtrer la liste des champions par nom, rôle et région officielle, de combiner ces filtres, et d'afficher le nombre de champions retenus sur le total.
- **FR-017**: Le système DOIT permettre de trier la liste des champions par nom, difficulté croissante, difficulté décroissante et taux de victoire global, un tri secondaire alphabétique rendant l'ordre stable, les champions sans taux fiable passant après les autres.
- **FR-018**: Le système DOIT replier l'histoire d'un champion au-delà de cinq lignes avec un lien pour la lire en entier.
- **FR-019**: Le système DOIT, en cas de panne réseau sur chacun de ces écrans, afficher un message rédigé pour l'utilisateur et un bouton « Réessayer » plutôt qu'un chargement sans issue.
- **FR-020**: Le système DOIT exposer aux lecteurs d'écran un libellé pour chaque contrôle sans texte (retirer un objet, ajouter un objet, comparer, lien de la fiche) et pour chaque ligne de comparaison.

### Key Entities *(include if feature involves data)*

- **Caractéristiques de base d'un champion**: valeurs au niveau 1 (vie, armure, résistance magique, dégâts, vitesse d'attaque, déplacement, portée) et gain par niveau de chacune, plus les jauges de Riot de 0 à 10 (attaque, défense, magie, difficulté).
- **Caractéristiques en combat**: ce qu'un champion a réellement à un niveau donné avec ses objets (onze valeurs).
- **Ligne de comparaison**: un libellé, deux valeurs, un nombre de décimales ; en découlent le gagnant et la part de barre de chaque côté.
- **Objet**: nom, prix, bonus chiffrés nommés comme chez Riot.
- **Résultats de recherche**: deux listes (champions, objets) bornées à 8.
- **Duel et bilan global**: nombre de parties et de victoires d'un champion contre un autre, ou toutes opposantes confondues (voir `data-model.md`).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Un joueur obtient la comparaison complète de deux champions à un niveau donné en moins de 30 secondes après l'ouverture de l'écran, sans quitter l'écran.
- **SC-002**: Pour une paire de champions et un niveau, les valeurs affichées sont identiques à la formule documentée (base + gain × facteur + bonus d'objets) : les tests de calcul couvrent le niveau 1, le niveau 18, un niveau intermédiaire, les plafonds et les bornes de niveau.
- **SC-003**: La recherche d'un nom tapé sans accent ni ponctuation retrouve le champion ou l'objet dans 100 % des cas couverts par les tests (zoé, cho'gath, noms composés).
- **SC-004**: Aucun écran de cette fonctionnalité ne reste sur un indicateur de chargement sans issue quand le réseau est coupé : un message et un bouton « Réessayer » apparaissent.
- **SC-005**: L'ajout ou le retrait d'un objet, ou un changement de niveau, met à jour l'écran de comparaison sans nouveau téléchargement des fiches de champion.
- **SC-006**: Chaque ligne de comparaison est compréhensible sans voir la couleur (gagnant annoncé en toutes lettres pour les lecteurs d'écran).

## Assumptions

- Les caractéristiques de base et leur croissance viennent de la fiche détaillée de Data Dragon ; les bonus d'objets viennent du catalogue d'objets de Data Dragon. Le duel et le taux global viennent du fichier embarqué `assets/data/champion_matchups.json`, qui est hors du périmètre de cette fonctionnalité.
- Seuls les bonus chiffrés des objets sont comptés ; les effets passifs et actifs ne sont pas modélisés. La « Puissance » d'un champion ne vient que des objets (aucun gain naturel).
- La comparaison est faite à un niveau commun aux deux champions : il n'y a pas deux curseurs.
- Le choix des deux champions, des objets et du niveau n'est pas mémorisé entre deux ouvertures de l'écran.
- La courbe de croissance est celle du jeu (coefficients 0,7025 et 0,0175) ; elle s'applique de la même façon à toutes les caractéristiques qui croissent avec le niveau, y compris la vitesse d'attaque (dont le gain par niveau est un pourcentage).

### Limites connues

- Les textes d'invite de cette fonctionnalité (« Choisissez deux champions… », « Créez-en une… », « Tapez le nom… ») vouvoient l'utilisateur, alors que la constitution demande de le tutoyer (voir Complexity Tracking dans `plan.md`).
- Il n'existe pas de test de widget de `ComparePage`, `SearchPage`, `CompareItemSlots`, `SavedBuildPickerSheet` ni du bouton « Comparer » : seuls la logique (calcul, lignes, filtre, recherche, normalisation) et le texte repliable sont testés.
- La feuille de choix d'un champion filtre par nom avec une simple mise en minuscules (sans normalisation des accents), contrairement à la recherche globale et à la liste des champions : « zoe » ne trouve pas « Zoé » dans cette feuille.
- La demande « par niveaux » est livrée sous la forme d'un niveau commun unique, de 1 à 18.
