# Feature Specification: Barre de navigation

**Feature Branch**: `014-barre-de-navigation` (travail livré sur `main`, pas de branche dédiée)

**Created**: 2026-10-05

**Status**: Implemented

**Input**: User description : « ammeliore la nav bar elle faits pas trop navbar »

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Reconnaître et utiliser la barre d'onglets (Priority: P1)

L'utilisateur voit en bas de l'écran une vraie barre d'onglets : une icône et un libellé par destination (Accueil, Champions, Quiz, Objets, Outils, Carte), séparée de la page par un filet doré. Un appui sur un onglet ouvre la destination correspondante.

**Why this priority**: c'est le but de la demande. Avant, la barre n'était qu'une rangée de pastilles de texte, qui ne ressemblait pas à une barre de navigation.

**Independent Test**: lancer l'application, appuyer successivement sur chaque onglet ; la page change à chaque appui.

**Acceptance Scenarios**:

1. **Given** l'application ouverte, **When** on regarde le bas de l'écran, **Then** six onglets s'affichent, chacun avec une icône et un libellé, sur une surface distincte de la page, avec un filet de séparation en haut.
2. **Given** la barre affichée, **When** l'utilisateur touche l'onglet « Quiz », **Then** la page du quiz s'ouvre.

---

### User Story 2 - Voir clairement l'onglet actif (Priority: P1)

L'onglet actif se distingue de trois façons à la fois : un trait doré qui apparaît au-dessus de l'icône, une icône pleine (au lieu de l'icône au trait), et un libellé en gras de couleur d'accent. Les onglets inactifs sont en couleur discrète.

**Why this priority**: un indicateur d'état clair est ce qui fait « barre de navigation ». L'état n'est pas porté par la seule couleur (trait, icône pleine et graisse changent aussi).

**Independent Test**: ouvrir successivement deux onglets ; l'ancien perd son trait et son icône pleine, le nouveau les gagne.

**Acceptance Scenarios**:

1. **Given** l'onglet 0 actif, **When** on observe la barre, **Then** l'icône pleine de l'accueil est affichée et les autres onglets montrent leur icône au trait.
2. **Given** un onglet inactif, **When** il devient actif, **Then** le trait doré s'élargit en une courte animation et la hauteur de la barre ne change pas.

---

### User Story 3 - Barre accessible aux lecteurs d'écran (Priority: P2)

Chaque onglet est annoncé comme un bouton, avec son libellé, et l'onglet actif est annoncé comme sélectionné.

**Why this priority**: contrainte d'accessibilité du projet ; la barre est présente sur tous les écrans.

**Independent Test**: avec un lecteur d'écran, parcourir la barre ; chaque onglet est annoncé « bouton » et l'actif « sélectionné ».

**Acceptance Scenarios**:

1. **Given** l'onglet « Quiz » actif, **When** on lit l'arbre sémantique, **Then** « Quiz » est un bouton sélectionné et « Accueil » un bouton non sélectionné.

---

### User Story 4 - Retrouver l'état de chaque onglet (Priority: P2)

Quand l'utilisateur quitte un onglet puis y revient, il retrouve son défilement, sa recherche et ses filtres. Un onglet jamais visité n'est pas chargé au démarrage.

**Why this priority**: comportement hérité d'un commit antérieur (`6ea513f`), conservé par la refonte ; il évite des téléchargements inutiles tout en gardant l'état.

**Independent Test**: faire une recherche dans « Champions », aller sur « Quiz », revenir : la recherche est toujours là.

**Acceptance Scenarios**:

1. **Given** l'application démarrée, **When** aucun autre onglet n'a été ouvert, **Then** seule la page d'accueil est construite.
2. **Given** l'onglet « Champions » visité avec une recherche en cours, **When** l'utilisateur change d'onglet puis revient, **Then** la page est restée telle qu'il l'avait laissée.

---

### Edge Cases

- Écran étroit : le libellé est réduit pour tenir dans sa colonne (aucun débordement, aucun retour à la ligne).
- Appareil avec zone de sécurité en bas (barre de geste) : la barre en tient compte et la surface se prolonge dessous.
- Changement de mode clair/sombre : la barre se repeint avec la palette du mode (surface, bordure, accent, texte discret).
- Appui sur l'onglet déjà actif : l'onglet reste actif, rien d'autre ne change.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT afficher en bas de l'écran une barre d'onglets avec, pour chaque destination, une icône et un libellé.
- **FR-002**: Le système DOIT proposer six destinations dans cet ordre : Accueil, Champions, Quiz, Objets, Outils, Carte.
- **FR-003**: Le système DOIT ouvrir la destination touchée.
- **FR-004**: Le système DOIT signaler l'onglet actif par un trait d'accent, une icône pleine, un libellé en gras et la couleur d'accent, les onglets inactifs étant en couleur discrète.
- **FR-005**: La hauteur de la barre NE DOIT PAS varier quand l'onglet actif change.
- **FR-006**: Le système DOIT séparer la barre de la page par une surface distincte et un filet de bordure, et respecter la zone de sécurité inférieure de l'appareil.
- **FR-007**: Le système DOIT annoncer chaque onglet comme un bouton portant son libellé, et l'onglet actif comme sélectionné.
- **FR-008**: Le système DOIT conserver l'état d'un onglet visité quand l'utilisateur en ouvre un autre, et NE DOIT PAS construire un onglet avant sa première visite.
- **FR-009**: Le système DOIT réduire un libellé trop long pour tenir dans son onglet plutôt que de déborder.

### Key Entities

- **Destination** : un onglet de la barre, avec un libellé, une icône au trait (inactif) et une icône pleine (actif).
- **Onglet visité** : onglet déjà ouvert au moins une fois pendant la session, dont la page reste vivante.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Chacune des six destinations est atteignable en un seul appui depuis n'importe quel onglet.
- **SC-002**: À tout instant, exactement un onglet porte l'indicateur « actif » (trait, icône pleine, état « sélectionné »).
- **SC-003**: Au démarrage, une seule page (l'accueil) est construite ; les cinq autres le sont seulement après leur première ouverture.
- **SC-004**: L'état d'un onglet (défilement, recherche, filtres) est identique avant et après un passage par un autre onglet.

## Assumptions

- Les destinations elles-mêmes (pages Accueil, Champions, Quiz, Objets, Outils, Carte) existent déjà ; cette fonctionnalité ne modifie que la barre.
- L'ajout de l'onglet « Outils » date d'un commit antérieur (`a4475d7`) ; la refonte reprend la liste de six destinations telle quelle.

## Hypothèses et limites connues

- La zone tactile d'un onglet occupe toute la hauteur de la barre et un sixième de la largeur ; sa hauteur exacte dépend de la police (icône 22 + libellé + marges), non fixée à 44 px comme l'ancienne pastille.
- La taille du libellé est de 10,5 points, réduite au besoin : elle est petite mais conforme à l'usage des barres d'onglets.
- La couleur de l'icône et du libellé inactifs est la couleur discrète de la palette (contraste 4,5:1 vérifié par les tests de la fonctionnalité 013).
- Seul le composant `AppNavBar` est testé ; le comportement de `MainNavigation` (onglets construits à la première visite, état conservé) n'a pas de test automatisé.
- Le changement de mode clair/sombre est géré par la fonctionnalité 013 ; la barre lit simplement les couleurs courantes.
