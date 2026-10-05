# Feature Specification: Sorts d'invocateur conseillés et onglet Outils

**Feature Branch**: `012-sorts-d-invocateur-et-onglet-outils` (travail livré sur `main`, commits `a96b9d2` et `a4475d7`)

**Created**: 2026-10-05

**Status**: Implemented

**Input**: User description, en deux demandes :

- « oui les sort d'invocateur sont afficher » (réponse de l'utilisateur à la proposition d'afficher des sorts d'invocateur conseillés sur la fiche d'un champion) ;
- « cree un autre onglets dans la nav bar pour outils ».

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Voir les sorts d'invocateur conseillés sur la fiche d'un champion (Priority: P1)

Sur la fiche d'un champion, une section « Sorts d'invocateur » montre les deux sorts conseillés (par exemple Saut éclair et Châtiment pour un jungler), avec pour chacun l'icône, le nom, le temps de recharge, l'effet, et une phrase qui explique le choix.

**Why this priority**: c'est la demande de contenu : jusque-là, la fiche donnait les runes et les objets conseillés mais pas les sorts.

**Independent Test**: ouvrir la fiche d'un champion (un jungler, un tireur) et vérifier la section, ses deux sorts et sa phrase d'explication.

**Acceptance Scenarios**:

1. **Given** la fiche d'un champion dont la voie principale est la jungle, **When** la section s'affiche, **Then** elle propose Châtiment et Saut éclair, avec la raison « En jungle, Châtiment sert à sécuriser les monstres et les objectifs. »
2. **Given** un tireur dont la voie principale est le bas de la carte, **When** la section s'affiche, **Then** elle propose Saut éclair et Soins.
3. **Given** un combattant ou un tank en haut, **When** la section s'affiche, **Then** elle propose Saut éclair et Téléportation ; un mage en haut reçoit Saut éclair et Embrasement.
4. **Given** un champion de profil Support en voie de soutien, **When** la section s'affiche, **Then** elle propose Saut éclair et Épuisement ; un autre profil en soutien reçoit Embrasement.
5. **Given** un champion dont la voie est inconnue (trop peu de parties analysées), **When** la section s'affiche, **Then** c'est son profil (premier tag) qui décide : tireur Soins, soutien Épuisement, tank ou combattant Téléportation, autres Embrasement.
6. **Given** un champion sans aucun tag, **When** la section s'affiche, **Then** il est traité comme un combattant (profil par défaut).
7. **Given** la fiche affichée, **When** la section apparaît, **Then** chaque sort montre son temps de recharge en secondes (omis s'il est nul) et sa description.

---

### User Story 2 - Accéder aux outils par un onglet dédié (Priority: P1)

La barre de navigation du bas comporte un onglet « Outils » (entre « Objets » et « Carte »). Il ouvre une page « Outils » (« Préparez votre partie ») qui liste les outils de l'application.

**Why this priority**: c'est la deuxième demande ; les outils (contre-picks, composition, comparaison, builds) étaient enfouis dans l'accueil.

**Independent Test**: toucher l'onglet Outils depuis n'importe quel onglet et vérifier la page et ses raccourcis.

**Acceptance Scenarios**:

1. **Given** l'application ouverte, **When** le joueur regarde la barre du bas, **Then** il voit six destinations : Accueil, Champions, Quiz, Objets, Outils, Carte.
2. **Given** n'importe quel onglet, **When** le joueur touche « Outils », **Then** la page « Outils » s'affiche avec le sous-titre « Préparez votre partie ».
3. **Given** l'onglet Outils déjà visité, **When** le joueur change d'onglet puis revient, **Then** il retrouve la page dans son état (défilement conservé), et l'onglet n'est construit qu'à la première visite.
4. **Given** un lecteur d'écran, **When** il parcourt la barre, **Then** chaque destination est annoncée comme un bouton avec son libellé et son état « sélectionné ».

---

### User Story 3 - Lancer un outil depuis la page Outils (Priority: P2)

La page Outils affiche des tuiles sur deux colonnes, chacune avec une icône, un nom et une phrase d'accroche : « Contre-picks », « Points forts », « Composition », « Comparer », « Mes builds ». Toucher une tuile ouvre l'outil.

**Why this priority**: donne un sens à l'onglet ; l'onglet seul serait vide.

**Independent Test**: ouvrir la page Outils, toucher chaque tuile et vérifier l'écran ouvert.

**Acceptance Scenarios**:

1. **Given** la page Outils, **When** elle s'affiche, **Then** cinq tuiles apparaissent sur deux colonnes dans l'ordre Contre-picks, Points forts, Composition, Comparer, Mes builds.
2. **Given** une tuile, **When** le joueur la touche, **Then** l'outil correspondant s'ouvre au-dessus de la page ; le retour ramène à la page Outils.
3. **Given** la page d'accueil, **When** elle s'affiche, **Then** elle ne contient plus de section Outils (elle avait été ajoutée à l'accueil dans le premier commit, puis déplacée dans l'onglet).
4. **Given** un lecteur d'écran, **When** il atteint une tuile, **Then** elle est annoncée comme un bouton « Contre-picks, Qui jouer contre lui ? ».

---

### Edge Cases

- Les sorts conseillés sont un bonus : si le fichier de matchups, la liste des sorts de Data Dragon ou la résolution échouent, la section est simplement absente et la fiche reste complète, sans message d'erreur (`loadSummonerSpells` de `lib/champion_detail/champion_detail_page.dart`).
- La section n'apparaît que lorsque les conseils de runes et d'objets de la fiche sont eux-mêmes chargés (elle est rendue dans le même bloc conditionnel que les runes conseillées).
- Un identifiant de sort que Riot ne publie plus est ignoré au lieu de faire échouer l'affichage (`SummonerSpellService.byIds`).
- Riot liste aussi les sorts des modes événementiels : seuls ceux de la partie classique (`CLASSIC`) sont retenus ; un sort sans `modes` est écarté.
- Une voie principale n'est retenue qu'à partir de 30 parties analysées pour le champion ; en dessous, la voie est inconnue et le profil décide.
- Un sort sans temps de recharge (valeur absente ou liste vide) affiche une recharge de 0 et la valeur n'est pas écrite.
- Télécharger plusieurs fiches champion coup sur coup ne retélécharge pas la liste des sorts (futur en cours mis en cache).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT afficher sur la fiche d'un champion une section « Sorts d'invocateur » de deux sorts, avec icône, nom, temps de recharge en secondes, description et une phrase expliquant le choix.
- **FR-002**: Le système DOIT choisir les sorts d'après la voie la plus jouée du champion dans les parties analysées, et d'après son profil (premier tag) quand la voie est inconnue.
- **FR-003**: Le système DOIT appliquer ces conseils : jungle → Châtiment et Saut éclair ; bas de la carte → Saut éclair et Soins ; soutien de profil Support → Saut éclair et Épuisement, autre profil → Saut éclair et Embrasement ; haut ou milieu avec un profil Tank ou Combattant → Saut éclair et Téléportation, autre profil → Saut éclair et Embrasement.
- **FR-004**: Le système DOIT, sans voie connue, choisir selon le profil : Tireur → Saut éclair et Soins ; Support → Saut éclair et Épuisement ; Tank ou Combattant → Saut éclair et Téléportation ; tout autre profil → Saut éclair et Embrasement ; un champion sans tag est traité comme Combattant.
- **FR-005**: Le système DOIT ne retenir que les sorts d'invocateur de la partie classique.
- **FR-006**: Le système DOIT laisser la fiche complète, sans message d'erreur, si les sorts conseillés ne peuvent pas être obtenus.
- **FR-007**: Le système DOIT proposer, dans la barre de navigation, un onglet « Outils » entre « Objets » et « Carte ».
- **FR-008**: Le système DOIT n'initialiser un onglet qu'à sa première visite et conserver son état ensuite.
- **FR-009**: Le système DOIT afficher dans l'onglet Outils un titre « Outils », un sous-titre « Préparez votre partie » et cinq tuiles (Contre-picks, Points forts, Composition, Comparer, Mes builds) sur deux colonnes.
- **FR-010**: Le système DOIT ouvrir l'outil correspondant au toucher d'une tuile et permettre de revenir à la page Outils.
- **FR-011**: Le système NE DOIT PAS afficher la section Outils sur la page d'accueil.
- **FR-012**: Le système DOIT annoncer chaque destination de la barre (avec son état sélectionné) et chaque tuile d'outil à un lecteur d'écran.

### Key Entities *(include if feature involves data)*

- **Sort d'invocateur** : identifiant Riot (`SummonerFlash`…), nom, description, image, temps de recharge en secondes ; seuls ceux de la partie classique sont conservés.
- **Plan de sorts** : deux identifiants de sorts et la raison du choix en une phrase.
- **Outil** : icône, nom, phrase d'accroche, écran à ouvrir.
- **Destination de navigation** : libellé, icône au trait, icône pleine.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Pour chaque combinaison de profil (Tank, Combattant, Mage, Assassin, Tireur, Support, sans tag) et de voie (haut, jungle, milieu, bas, soutien, inconnue), le plan donne exactement deux sorts et une raison non vide.
- **SC-002**: Un joueur atteint n'importe quel outil en deux touches depuis n'importe quel onglet (onglet Outils, tuile).
- **SC-003**: L'absence de réseau ou une erreur sur les sorts n'empêche jamais l'affichage du reste de la fiche champion.
- **SC-004**: Les six destinations de la barre sont toutes accessibles et lisibles à 10,5 pt sans coupure de libellé (réduction automatique du texte si besoin).

## Assumptions et limites connues

- Data Dragon ne publie pas de sorts conseillés : les plans sont rédigés à la main d'après les usages les plus répandus (comme pour les runes). Ils ne sont pas calculés à partir des parties analysées, seule la voie principale en vient.
- Les raisons sont rédigées au vouvoiement pour certaines (« protège votre allié ») alors que la constitution demande le tutoiement : écart noté dans `plan.md`.
- Le conseil ne distingue pas les profils secondaires (un Mage Assassin est traité selon son premier tag).
- L'onglet Outils n'est pas testé par un test d'écran, et la section de sorts de la fiche non plus : seuls le recommandeur (`SummonerSpellRecommender`), le modèle `SummonerSpell` et la barre `AppNavBar` ont des tests.
- La barre de navigation a ensuite été refaite avec icônes et indicateur d'onglet actif (commit `b9132b1`) ; la spécification décrit l'état actuel à six destinations.
- Les écrans ouverts par les tuiles sont couverts par leurs propres spécifications (contre-picks et points forts : 010 ; composition : 011).
