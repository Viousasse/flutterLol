# Feature Specification: Entraîneur de draft

**Feature Branch**: `015-entraineur-de-draft` (travail livré sur `main`, pas de branche dédiée)

**Created**: 2026-10-05

**Status**: Implemented

**Input**: User description : « dans l'outils composition fais un entraineurs de draft contre le site et ils me dis si elle bien quesqui a ameliorer dans la draft qui pk une draft et meilleurs que l'autre » ; puis « fais le 1 et 2 et 3 » (bannissements, historique, partage) ; « dans choix filtre de draft mettre les perso par roles » ; « fais 3 et 4 » (test de bout en bout, analyse des bannissements dans le bilan) ; puis les conseils « Aide au choix ».

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Faire une draft contre le site (Priority: P1)

Depuis l'outil « Composition », l'utilisateur ouvre « Entraîneur de draft : jouer contre le site ». Il joue le camp bleu, le site joue le camp rouge. Les choix alternent dans l'ordre d'une partie classée (bleu, rouge, rouge, bleu, bleu, rouge, rouge, bleu, bleu, rouge) : le joueur choisit, pour le rôle de son choix (Top, Jungle, Milieu, Bot, Support), un champion libre ; le site répond après une courte attente ; la page indique à chaque instant à qui c'est de jouer et à quel numéro de choix (« choix 3 sur 10 »).

**Why this priority**: c'est le cœur de la demande : s'entraîner à drafter contre un adversaire.

**Independent Test**: ouvrir l'entraîneur, désactiver les bannissements, jouer cinq choix ; le site joue les cinq autres et la draft se termine.

**Acceptance Scenarios**:

1. **Given** une draft neuve sans bannissements, **When** la page s'ouvre, **Then** le statut indique « À vous de choisir (choix 1 sur 10) » et les cinq cases du camp bleu invitent à choisir.
2. **Given** le tour du joueur, **When** il touche un rôle libre puis un champion dans la feuille de choix, **Then** le champion est posé à ce rôle et le site « choisit… » avant de poser son propre champion.
3. **Given** dix champions posés, **When** le dernier est choisi, **Then** la page passe seule à l'analyse (aucun bouton à toucher) puis affiche le bilan.

---

### User Story 2 - Comprendre quelle draft est meilleure et quoi améliorer (Priority: P1)

Une fois la draft terminée, un bilan donne le verdict (« Votre draft l'emporte », « La draft du site l'emporte » ou « Drafts équivalentes ») avec le score en critères gagnés, la comparaison critère par critère (répartition des dégâts, première ligne, contrôle, duels de voie, taux de victoire moyen) avec pour chacun ce que fait chaque camp, qui l'emporte et pourquoi, puis « Ce qui va bien » et « À améliorer » (par exemple un champion précis qui contre mieux l'adversaire de la voie perdue).

**Why this priority**: c'est la deuxième moitié de la demande (« dis-moi si elle est bien, qu'est-ce qu'il y a à améliorer, pourquoi une draft est meilleure que l'autre »).

**Independent Test**: terminer une draft ; le bilan affiche un verdict, cinq critères, au moins une ligne dans « À améliorer ».

**Acceptance Scenarios**:

1. **Given** une draft terminée, **When** le bilan s'affiche, **Then** il contient le bloc « VERDICT », la section « POURQUOI » avec cinq critères et la section « À AMÉLIORER ».
2. **Given** un critère gagné par le joueur, **When** le bilan s'affiche, **Then** la ligne du critère dit « Avantage à vous » et le critère figure dans « CE QUI VA BIEN ».
3. **Given** un critère gagné par le site, **When** le bilan s'affiche, **Then** il dit « Avantage au site » (le vainqueur est dit en toutes lettres, pas seulement par la couleur et l'icône).
4. **Given** une voie perdue (le champion du joueur ne gagne que 47 % ou moins du duel), **When** le bilan s'affiche, **Then** « À améliorer » cite le champion encore libre qui bat le mieux l'adversaire à ce poste, ou « Essayez un autre choix à ce poste » faute de mieux.
5. **Given** une draft sans aucun défaut relevé, **When** le bilan s'affiche, **Then** « À améliorer » contient une phrase (« Votre draft n'a pas de point faible évident. ») plutôt qu'une liste vide.

---

### User Story 3 - Jouer avec des bannissements (Priority: P2)

Avant le premier coup, un interrupteur « Bannissements » (activé par défaut) permet de jouer comme en partie classée : chaque camp écarte cinq champions, un à un en alternance, le bleu en premier, avant le moindre choix. Le joueur touche sa rangée de bannissements pour choisir le champion à écarter ; le site bannit après une attente. Les champions bannis apparaissent en gris barrés et plus personne ne peut les prendre.

**Why this priority**: demandé dans « fais le 1 et 2 et 3 » ; rend la draft plus réaliste mais la draft sans bannissements reste utilisable.

**Independent Test**: ouvrir l'entraîneur, bannir cinq champions ; dix cases barrées apparaissent puis le statut passe à « choix 1 sur 10 ».

**Acceptance Scenarios**:

1. **Given** une draft neuve, **When** la page s'ouvre, **Then** l'interrupteur « Bannissements » est actif et le statut annonce « ban 1 sur 10 ».
2. **Given** la phase de bannissements, **When** le joueur bannit un champion, **Then** il apparaît barré dans sa rangée, puis le site bannit le sien ; au dixième ban, la phase de choix commence.
3. **Given** des champions bannis, **When** on ouvre la feuille de choix, **Then** ni les bannis ni les champions déjà choisis n'y figurent.
4. **Given** la draft jouée avec bannissements, **When** le bilan s'affiche, **Then** une section « BANNISSEMENTS » juge les bans du joueur (voir User Story 4).
5. **Given** un interrupteur désactivé avant le premier coup, **When** la draft commence, **Then** elle démarre directement par un choix et les rangées de bannissements n'apparaissent pas.

---

### User Story 4 - Savoir si ses bannissements ont servi (Priority: P2)

Quand des bannissements ont eu lieu, le bilan juge ceux du joueur : félicite les bans qui écartent un champion qui gagne souvent, signale ceux qui visent un champion qui perd plus qu'il ne gagne, et signale le champion fort que personne n'a banni et que l'adversaire a joué.

**Why this priority**: complète le bilan (« fais 3 et 4 ») ; sans lui, les bannissements n'auraient aucun retour.

**Independent Test**: jouer une draft avec bannissements ; le bilan contient « BANNISSEMENTS » avec au moins une remarque.

**Acceptance Scenarios**:

1. **Given** un ban sur un champion fiable à 52 % de victoires ou plus, **When** le bilan est établi, **Then** la remarque « Bannissements utiles : … » apparaît.
2. **Given** un ban sur un champion fiable à moins de 50 %, **When** le bilan est établi, **Then** la remarque « Bannissements peu utiles : … » apparaît.
3. **Given** un champion fort (52 % ou plus, fiable) joué par l'adversaire et banni par personne, **When** le bilan est établi, **Then** il est signalé comme non banni (deux au plus).
4. **Given** un champion peu joué (moins de 100 parties), **When** le bilan est établi, **Then** il n'est jugé ni utile ni inutile.
5. **Given** une draft sans bannissements, **When** le bilan est établi, **Then** la section « BANNISSEMENTS » n'apparaît pas.

---

### User Story 5 - Être conseillé pendant son choix (« Aide au choix ») (Priority: P3)

Avant le premier coup, un interrupteur « Aide au choix » (éteint par défaut) fait proposer au joueur, à son tour, trois champions avec la raison de chaque conseil (« Gagne 58 % contre Zed au milieu (120 parties). », « 54 % de victoires en Master+. », « Comble le manque de dégâts magiques de votre équipe. »). Toucher une carte joue ce champion au rôle indiqué. Une draft jouée avec l'aide est marquée « avec aide » dans l'historique.

**Why this priority**: amélioration ultérieure, non demandée dans la première version ; la draft se joue très bien sans.

**Independent Test**: activer l'interrupteur, passer les bannissements ; trois cartes « SUGGESTIONS » s'affichent ; en toucher une pose le champion.

**Acceptance Scenarios**:

1. **Given** l'aide activée et le tour du joueur en phase de choix, **When** la page s'affiche, **Then** trois cartes de suggestion sont visibles sous le statut.
2. **Given** la phase de bannissements, ou le tour du site, ou la draft terminée, **When** la page s'affiche, **Then** aucune suggestion n'est visible.
3. **Given** une suggestion, **When** le joueur la touche, **Then** le champion est posé au rôle annoncé, sans feuille de choix.
4. **Given** une draft jouée avec l'aide activée, **When** elle est terminée, **Then** son enregistrement dans l'historique est marqué « avec aide ».
5. **Given** le premier coup joué, **When** la page s'affiche, **Then** les interrupteurs de réglage ont disparu.

---

### Edge Cases

- Recommencer en pleine attente du site : le tour du site lancé avant « Recommencer » ne s'applique pas à la nouvelle partie (numéro de partie, `generation`).
- Aucun champion connu à un rôle (données absentes) : le site comme les conseils retombent sur n'importe quel champion libre au lieu de bloquer la draft (testé dans `draft_bot_test.dart`, `draft_advisor_test.dart`).
- Pas assez de parties pour comparer un duel : la voie est signalée « pas assez de parties » sans conclure ; si aucun taux de victoire n'est fiable, le critère « Taux de victoire moyen » affiche « données insuffisantes » et un nul.
- Échec de téléchargement des fiches des dix champions à l'analyse : un message d'erreur rédigé et un bouton « Réessayer » relancent l'analyse sans refaire la draft.
- Échec de chargement des champions ou des matchups à l'ouverture : message et « Réessayer ».
- Un champion déjà choisi ou banni ne peut être ni rechoisi ni rebanni (le modèle refuse l'opération).
- Les cases de bannissement laissées vides (champion introuvable) ne sont pas jugées.
- Écart trop faible entre deux camps : le critère est « Égalité » (chaque camp marque un demi-point) ; une différence de score inférieure à un demi-point donne « Drafts équivalentes ».
- Le dernier choix est fait : aucun bouton n'est nécessaire pour lancer l'analyse.
- Le filtre par rôle de la feuille de choix est décrit par la spécification 018 ; cette fonctionnalité ne fait que l'utiliser.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT proposer une draft contre le site depuis l'outil « Composition » : le joueur tient le camp bleu, le site le camp rouge.
- **FR-002**: Le système DOIT faire alterner les choix dans l'ordre bleu, rouge, rouge, bleu, bleu, rouge, rouge, bleu, bleu, rouge, chaque camp ayant exactement un champion par rôle (Top, Jungle, Milieu, Bot, Support), et laisser le joueur choisir le rôle qu'il remplit à chaque tour.
- **FR-003**: Le système DOIT afficher à chaque instant qui doit jouer et l'avancement (« choix X sur 10 », « ban X sur 10 »), annoncé aux lecteurs d'écran comme zone vive.
- **FR-004**: Le système DOIT faire jouer le site après un délai visible (« Le site choisit… », « Le site bannit… »), sans que le joueur ait rien à lancer.
- **FR-005**: Le site DOIT choisir un champion qui se joue réellement au rôle visé, de préférence en répondant à un rôle déjà pris par l'adversaire, en visant le contre de l'adversaire de la voie, un taux de victoire élevé et ce qui manque à son équipe, avec une part de hasard pour que deux drafts ne soient pas identiques.
- **FR-006**: Le système DOIT refuser de poser un champion déjà choisi ou banni, de remplir un rôle déjà pris, de choisir avant la fin des bannissements et de bannir hors de son tour.
- **FR-007**: Le système DOIT proposer, avant le premier coup, un interrupteur « Bannissements » (actif par défaut) ; actif, chaque camp bannit cinq champions en alternance, le bleu en premier, avant tout choix ; inactif, la draft commence par un choix.
- **FR-008**: Le système DOIT figer les réglages (bannissements, aide au choix) dès qu'un ban ou un choix a été joué.
- **FR-009**: Le système DOIT afficher les bannis dans une rangée par camp, en niveaux de gris barrés, et la première case libre du camp qui doit bannir DOIT inviter à bannir.
- **FR-010**: Une fois les dix champions posés, le système DOIT télécharger leurs fiches (jauges, sorts) puis comparer les deux drafts sans action du joueur.
- **FR-011**: Le bilan DOIT comparer cinq critères : répartition des dégâts (physiques et magiques), première ligne, contrôle (sorts qui immobilisent ou étourdissent), duels de voie, taux de victoire moyen des champions en parties classées Master+ ; chacun indique ce que fait chaque camp, qui gagne et une explication en français.
- **FR-012**: Un critère DOIT être déclaré égal quand l'écart est sous sa tolérance (équilibre des dégâts à 5 points, première ligne à moins d'un demi-champion, contrôle à moins d'un sort, voies à moins d'une voie, taux de victoire à moins d'un point) ; une voie est gagnée à 53 % de victoires en duel ou plus, perdue à 47 % ou moins, serrée entre les deux.
- **FR-013**: Le bilan DOIT donner un verdict (camp vainqueur, score, critères décisifs) : un critère gagné vaut 1 point, un nul un demi-point pour chaque camp ; moins d'un demi-point d'écart donne « Drafts équivalentes ».
- **FR-014**: Le bilan DOIT lister « Ce qui va bien » (critères gagnés) et « À améliorer » : manque de dégâts magiques ou physiques (part sous 20 %), absence de première ligne, contrôle insuffisant (moins de trois sorts), et pour chaque voie perdue le meilleur contre encore libre ; jamais une liste vide.
- **FR-015**: Le bilan DOIT juger les bannissements du joueur quand il y en a : bans utiles (champion fiable à 52 % ou plus), bans peu utiles (fiable à moins de 50 %), champions forts joués par l'adversaire et non bannis (au plus deux), ou une remarque neutre si rien n'est jugeable ; un champion de moins de 100 parties n'est jamais jugé.
- **FR-016**: Le système DOIT, quand l'aide au choix est active, proposer au joueur à son tour trois champions différents, chacun avec une à trois raisons tirées des données, de façon déterministe (même état, mêmes conseils), jamais pendant les bannissements, au tour du site ou une fois la draft finie ; le toucher d'une carte DOIT jouer le champion au rôle proposé.
- **FR-017**: Le système DOIT marquer « avec aide » la draft jouée avec l'aide activée dans l'historique des drafts (voir 017).
- **FR-018**: Le système DOIT enregistrer la draft dans l'historique dès qu'elle est jugée et permettre d'en copier un résumé à partager (voir 017), et proposer « Refaire une draft » qui repart d'une grille vide en conservant l'historique.
- **FR-019**: Le système DOIT afficher un message en français et un bouton « Réessayer » en cas d'échec du chargement ou de l'analyse, jamais un indicateur de chargement sans issue.
- **FR-020**: Le système DOIT afficher la source et la taille des données de matchups sous le bilan (note de source commune).
- **FR-021**: Les cases de choix, de bannissement, les cartes de conseil et les critères DOIVENT être annoncés aux lecteurs d'écran avec un libellé complet (« Top, vide, appuyer pour choisir un champion »), et les titres du bilan DOIVENT être des en-têtes sémantiques.

### Key Entities

- **Draft (état)** : champions choisis par camp et par rôle, champions bannis par camp ; immuable, chaque coup en produit un nouveau.
- **Camp** : bleu (le joueur) ou rouge (le site).
- **Critère** : titre, vainqueur (bleu, rouge, égalité), texte de chaque camp, explication.
- **Bilan** : critères, scores, vainqueur, verdict, forces, améliorations, remarques sur les bannissements.
- **Suggestion** : un champion, un rôle, 1 à 3 raisons, un score.
- **Données de matchups** : parties Master+ embarquées (champion contre champion par voie), source des taux de victoire.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Une draft complète (dix choix, avec ou sans bannissements) se joue de bout en bout, sans autre action que les choix du joueur, et aboutit à un bilan ; vérifié par `test/draft/draft_page_flow_test.dart`.
- **SC-002**: Aucun champion n'apparaît deux fois dans une draft (choisis et bannis confondus), quel que soit le nombre de parties jouées.
- **SC-003**: Pour un même état et les mêmes données, l'aide au choix donne exactement les mêmes trois conseils à chaque fois.
- **SC-004**: Chaque bilan contient les cinq critères et au moins une ligne dans « À améliorer ».
- **SC-005**: Le site n'interrompt jamais la draft faute de données : s'il n'existe aucun champion connu pour un rôle, il choisit parmi les champions libres.
- **SC-006**: Toute draft jugée est présente dans l'historique avant que le joueur ne touche un bouton.

## Assumptions

- L'utilisateur a l'outil « Composition » (page d'équipe) et ses données de champions (réseau, avec repli hors-ligne géré par la fonctionnalité 002).
- Les données de matchups sont un fichier embarqué de parties Master+ ; sa génération relève de la fonctionnalité 010.
- Le filtre de rôle de la feuille de choix relève de la spécification 018 ; l'historique, le partage et l'import des drafts de la 017 ; le mode à deux de la 016.
- Les bannissements sont des cases de champions, sans règle de rôle.

## Hypothèses et limites connues

- La demande disait « contre le site » : le site est un algorithme à barème et à part de hasard, pas un modèle d'apprentissage ; il tire au hasard parmi ses trois meilleures options (quatre pour un ban).
- Les conseils du bilan sont à la deuxième personne du pluriel (« Vous manquez… », « prenez un mage ») alors que la constitution (principe VII) demande le tutoiement : écart d'ensemble sur l'interface de la draft, voir `plan.md`.
- L'aide au choix s'éteint par défaut et ne se règle plus après le premier coup ; elle est aussi proposée en mode à deux (016), où elle conseille le camp qui doit jouer.
- Les bannissements du site ne sont jugés que dans le mode à deux ; contre le site, seuls ceux du joueur le sont.
- Aucun réglage n'est mémorisé d'une draft à l'autre (bannissements actifs, aide éteinte à chaque ouverture).
- Un « Recommencer » est proposé dans la barre de l'écran dès qu'un ban ou un choix existe ; la draft en cours n'est pas sauvegardée avant d'être jugée.
