# Feature Specification: Objets favoris

**Feature Branch**: `004-objets-favoris` (travail livré sur `main`, aucune branche dédiée)

**Created**: 2026-10-05 (commit `993ab50`)

**Status**: Implemented

**Input**: User description : cette fonctionnalité fait partie de « ta des idee d'amelioration ? » suivi de « fais tout les changements pour ameliorer ca ». L'idée proposée était de pouvoir mettre des objets en favoris comme on le faisait déjà pour les champions. Contexte : `d7c57fe` (2026-09-15) avait fait des favoris de champions une source de vérité unique ; cette fonctionnalité l'étend aux objets.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Mettre un objet en favori depuis sa fiche (Priority: P1)

Dans la fiche d'un objet (feuille qui s'ouvre quand on touche un objet), une étoile permet d'ajouter l'objet aux favoris ou de l'en retirer. L'étoile est pleine et dorée quand l'objet est favori. Sur la grille des objets, la carte d'un objet favori affiche une petite étoile à côté de son prix.

**Why this priority**: c'est le geste de base ; sans lui, il n'y a pas de favoris.

**Independent Test**: ouvrir un objet, toucher l'étoile : elle se remplit, et la carte de l'objet dans la grille affiche son étoile.

**Acceptance Scenarios**:

1. **Given** un objet qui n'est pas favori, **When** l'utilisateur touche l'étoile de sa fiche, **Then** l'étoile devient pleine et l'info-bulle indique « Retirer des favoris ».
2. **Given** un objet favori, **When** l'utilisateur touche l'étoile, **Then** l'étoile redevient vide et l'info-bulle indique « Ajouter aux favoris ».
3. **Given** la grille des objets visible derrière la fiche, **When** un objet est mis en favori ou retiré, **Then** la petite étoile de sa carte apparaît ou disparaît sans rechargement.

---

### User Story 2 - Retrouver ses objets favoris (Priority: P1)

La page « Favoris » (accessible depuis l'accueil) a deux onglets, « Champions » et « Objets ». L'onglet « Objets » montre la grille des objets favoris ; toucher un objet ouvre sa fiche. Sans favori, un message l'indique.

**Why this priority**: marquer un favori n'a de valeur que si on peut le retrouver en un endroit.

**Independent Test**: mettre deux objets en favori, ouvrir la page Favoris puis l'onglet « Objets » : les deux cartes sont là.

**Acceptance Scenarios**:

1. **Given** deux objets favoris, **When** l'utilisateur ouvre l'onglet « Objets », **Then** une grille de deux cartes s'affiche, avec la même présentation que sur la page des objets.
2. **Given** un objet de cette grille, **When** l'utilisateur le touche, **Then** sa fiche s'ouvre ; en y retirant le favori, la carte disparaît de la grille.
3. **Given** aucun objet favori, **When** l'onglet s'ouvre, **Then** « Aucun objet favori pour le moment » s'affiche.
4. **Given** la liste des objets impossible à charger, **When** l'onglet s'ouvre, **Then** un message d'erreur et un bouton « Réessayer » s'affichent.

---

### User Story 3 - Des favoris qui survivent et ne se mélangent pas (Priority: P2)

Les objets favoris sont mémorisés d'un lancement à l'autre, séparément des champions favoris, et sont relus avant le premier affichage pour que les étoiles soient déjà allumées.

**Why this priority**: indispensable à l'usage durable, mais invisible tant que l'application n'est pas relancée.

**Independent Test**: marquer un objet, relancer l'application : l'étoile est déjà allumée dès l'ouverture de la grille ; les champions favoris sont inchangés.

**Acceptance Scenarios**:

1. **Given** des objets et des champions favoris enregistrés, **When** l'application démarre, **Then** les deux jeux sont relus avant le premier affichage.
2. **Given** un objet favori et un champion favori, **When** l'objet est retiré, **Then** la liste des champions favoris est inchangée.
3. **Given** un stockage indisponible, **When** l'application démarre, **Then** elle s'ouvre sans favoris, sans planter, et retentera la lecture à la demande suivante.

---

### Edge Cases

- Un favori dont l'objet n'est plus dans la liste chargée (objet retiré du jeu ou non disponible) reste enregistré mais n'est pas affiché dans la grille.
- Une écriture qui échoue n'empêche pas les suivantes (la file d'écriture ne se rompt pas).
- Plusieurs écrans qui demandent le chargement en même temps ne relisent le stockage qu'une fois.
- Basculer deux fois le même favori revient à l'état initial.
- L'identifiant d'un champion et celui d'un objet n'interfèrent pas : « Ahri » n'est jamais un objet favori (`test/items/services/item_favorites_service_test.dart`).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: L'utilisateur DOIT pouvoir ajouter un objet aux favoris ou l'en retirer depuis la fiche de l'objet, avec un contrôle qui indique l'état courant et l'action possible.
- **FR-002**: Le système DOIT afficher sur la carte d'un objet favori, à côté de son prix, une étoile ; une carte d'objet non favori n'en affiche pas.
- **FR-003**: Le système DOIT répercuter immédiatement un changement de favori dans tous les écrans qui montrent l'objet (carte, fiche, liste des favoris), sans rechargement.
- **FR-004**: La page des favoris DOIT proposer deux onglets, « Champions » et « Objets ».
- **FR-005**: L'onglet « Objets » DOIT afficher les objets favoris dans la même grille adaptative que la page des objets et ouvrir la fiche d'un objet quand on le touche.
- **FR-006**: L'onglet « Objets » DOIT afficher « Aucun objet favori pour le moment » quand il n'y a aucun favori affichable.
- **FR-007**: L'onglet « Objets » DOIT afficher le message de la panne et un bouton « Réessayer » quand la liste des objets ne se charge pas, et relancer le chargement au retry.
- **FR-008**: Le système DOIT mémoriser les objets favoris d'un lancement à l'autre, dans un espace distinct de celui des champions favoris.
- **FR-009**: Le système DOIT relire les favoris d'objets et de champions avant le premier affichage de l'application.
- **FR-010**: Le système DOIT démarrer sans favoris, sans erreur, quand le stockage est indisponible, et retenter la lecture à l'appel suivant.
- **FR-011**: Le système DOIT enregistrer les modifications de favoris dans l'ordre où elles sont faites, une écriture en échec ne bloquant pas les suivantes.
- **FR-012**: Les favoris de champions DOIVENT continuer à se comporter comme avant (même mécanisme partagé avec les objets).

### Key Entities

- **Favori d'objet** : l'identifiant d'un objet marqué par l'utilisateur ; l'ensemble est unique (un objet ne figure qu'une fois).
- **Favori de champion** : idem pour les champions ; stocké séparément.
- **Magasin d'identifiants favoris** : le mécanisme partagé qui conserve un ensemble d'identifiants sous une clé donnée.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Un objet marqué est retrouvé dans l'onglet « Objets » en un geste de navigation depuis l'accueil (accueil, favoris, onglet Objets).
- **SC-002**: Après relance de l'application, 100 % des favoris enregistrés sont encore présents et leur étoile est allumée dès le premier affichage.
- **SC-003**: Retirer un objet des favoris ne modifie jamais l'ensemble des champions favoris, et inversement (testé).
- **SC-004**: Un changement de favori est visible sur l'écran déjà ouvert en moins d'un affichage, sans action de l'utilisateur.
- **SC-005**: Une panne de stockage ou de chargement ne produit jamais d'écran blanc ni de plantage.

## Assumptions

- Les objets sont ceux de la liste chargée par l'application (copie hors ligne comprise, voir fonctionnalité 002) ; seuls les objets « disponibles » y figurent.
- La page « Favoris » existait déjà pour les champions et reste accessible depuis le raccourci de l'accueil.
- Le nombre de favoris n'est pas limité.

### Hypothèses et limites connues

- Le raccourci de l'accueil porte toujours le libellé « Mes champions favoris » (`lib/home/widgets/favorites_shortcut/favorites_shortcut.dart`) alors que la page ouverte contient aussi les objets.
- La petite étoile de la carte d'objet est purement visuelle : elle n'a pas d'étiquette pour les lecteurs d'écran. Sur la fiche, l'étoile est un bouton avec info-bulle.
- Il n'y a pas de test de widget pour l'onglet « Objets », la carte d'objet ni l'en-tête de la fiche. Seuls le service d'objets (`test/items/services/item_favorites_service_test.dart`) et celui des champions (`test/champions/services/favorites_service_test.dart`) sont testés ; `FavoriteIdsStore` n'a pas de test direct.
- Un favori d'un objet qui disparaît du catalogue reste dans le stockage (il n'est pas nettoyé).
- La page des favoris compose des widgets des fonctionnalités « champions » et « objets » (voir plan, Complexity Tracking).
- La page des objets elle-même n'a ni filtre « favoris » ni tri par favori : les favoris se consultent uniquement depuis la page « Favoris ».
