# Feature Specification: Grilles adaptées aux écrans larges

**Feature Branch**: `009-grilles-adaptees-aux-ecrans-larges` (travail livré sur `main`, commit `ae4c0c2`)

**Created**: 2026-10-05

**Status**: Implemented

**Input**: User description: « trop grands le cadre pour l'afichage » (message accompagné d'une capture d'écran où les cartes d'objets, étirées par l'écran large, devenaient géantes).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Des cartes d'objets de taille raisonnable sur grand écran (Priority: P1)

Sur un navigateur ou une tablette, l'onglet Objets affiche des cartes de la même taille qu'au téléphone : l'écran se remplit de colonnes supplémentaires au lieu d'étirer chaque carte.

**Why this priority**: c'est le défaut signalé par la capture de l'utilisateur ; la grille d'objets était fixée à 3 colonnes, donc chaque carte grandissait avec la fenêtre.

**Independent Test**: ouvrir l'onglet Objets dans une fenêtre large (par exemple 1200 px) puis étroite (360 px) et comparer la largeur des cartes.

**Acceptance Scenarios**:

1. **Given** une fenêtre de 360 px de large, **When** l'utilisateur ouvre l'onglet Objets, **Then** les cartes tiennent sur 3 colonnes et le nom sur deux lignes d'un objet n'est pas rogné.
2. **Given** une fenêtre de 1200 px de large, **When** l'utilisateur ouvre l'onglet Objets, **Then** la grille affiche davantage de colonnes et la largeur d'une carte ne dépasse pas 130 px.
3. **Given** une taille de police agrandie dans les réglages du téléphone, **When** l'onglet Objets s'affiche, **Then** la hauteur des cartes augmente avec la partie texte (nom et prix) et rien n'est rogné.

---

### User Story 2 - Des cartes de champions de taille raisonnable sur grand écran (Priority: P2)

La liste des champions applique le même principe : deux colonnes sur téléphone, davantage sur écran large, avec des cartes qui ne dépassent pas 220 px de large.

**Why this priority**: même défaut que pour les objets, signalé de façon plus générale (« le cadre pour l'affichage »), mais la carte de champion est une grande image, moins choquante étirée.

**Independent Test**: ouvrir l'onglet Champions en fenêtre large et vérifier que le nombre de colonnes augmente.

**Acceptance Scenarios**:

1. **Given** un téléphone (environ 360 px), **When** l'utilisateur ouvre Champions, **Then** la grille affiche 2 colonnes.
2. **Given** une fenêtre de 1200 px, **When** l'utilisateur ouvre Champions, **Then** la grille affiche plus de 2 colonnes et chaque carte mesure au plus 220 px de large.

---

### User Story 3 - Même grille dans les favoris (Priority: P3)

Les onglets Champions et Objets de la page Favoris utilisent les mêmes grilles que les listes, pour que la même fiche ait la même taille partout.

**Why this priority**: évite une incohérence visuelle, mais n'apporte pas de capacité nouvelle.

**Independent Test**: ajouter un champion et un objet en favoris puis ouvrir la page Favoris en fenêtre large.

**Acceptance Scenarios**:

1. **Given** un champion et un objet favoris, **When** l'utilisateur ouvre Favoris en fenêtre large, **Then** les cartes ont la même taille maximale que dans les listes complètes.

---

### Edge Cases

- Taille de police système agrandie : la hauteur d'une carte d'objet suit le facteur d'échelle du texte (`MediaQuery.textScalerOf`), seule la partie texte grandit (`lib/items/constants/item_grid.dart`).
- Fenêtre très étroite (moins de 360 px) : seule la largeur maximale des cartes est fixée, il n'y a pas de largeur minimale ; le nombre de colonnes se déduit de la largeur disponible.
- Liste vide ou filtre sans résultat : la grille ne change pas, l'écran garde son message existant (hors périmètre).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT limiter la largeur d'une carte d'objet à 130 px et ajouter des colonnes quand l'écran s'élargit.
- **FR-002**: Le système DOIT limiter la largeur d'une carte de champion à 220 px et ajouter des colonnes quand l'écran s'élargit.
- **FR-003**: Le système DOIT donner aux cartes d'objets une hauteur indépendante de leur largeur, de sorte qu'elles ne deviennent pas très hautes sur un écran large.
- **FR-004**: La hauteur d'une carte d'objet DOIT croître avec la taille de texte choisie par l'utilisateur pour que le nom (deux lignes) et le prix restent lisibles.
- **FR-005**: Le système DOIT utiliser la même grille d'objets dans l'onglet Objets et dans les favoris d'objets.
- **FR-006**: Le système DOIT utiliser la même grille de champions dans l'onglet Champions et dans les favoris de champions.
- **FR-007**: Le système DOIT conserver un espacement de 12 px entre les cartes dans les deux grilles.

### Key Entities *(include if feature involves data)*

Aucune donnée n'est manipulée : la fonctionnalité ne porte que sur la mise en page.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Quelle que soit la largeur de fenêtre, une carte d'objet ne dépasse jamais 130 px de large et une carte de champion jamais 220 px.
- **SC-002**: À 360 px de large, le nom sur deux lignes d'un objet est visible en entier (aucune ligne rognée), à taille de police normale comme agrandie.
- **SC-003**: Les listes et les favoris affichent, à largeur de fenêtre égale, exactement le même nombre de colonnes.

## Assumptions et limites connues

- La grille des champions garde un rapport largeur/hauteur fixe (0,82) ; seule celle des objets a une hauteur fixe, car sa carte contient peu de choses.
- La fonctionnalité ne comporte aucun test automatisé : la mise en page a été vérifiée dans l'application. C'est un écart à la constitution, consigné dans `plan.md`.
- Les autres grilles de l'application (régions, quiz, etc.) ne sont pas concernées.
