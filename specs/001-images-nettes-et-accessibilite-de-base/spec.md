# Feature Specification: Images nettes et accessibilité de base

**Feature Branch**: `001-images-nettes-et-accessibilite-de-base` (travail livré sur `main`, aucune branche dédiée)

**Created**: 2026-10-05 (premier commit `ab817a6`)

**Status**: Implemented

**Input**: User description: « essaye d'avoir de meilleurs photo, ils sont pixelisés » (avec une capture de cartes de champions floues) puis « regarde tout les champions tout le monde n'est pas bien placé » (le cadrage des portraits). Le volet chargement, contraste et accessibilité (`a1c29ba`) prolonge la demande « ta des idee d'amelioration ? » suivie de « fais tout les changements pour ameliorer ca ».

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Des cartes de champions nettes et bien cadrées (Priority: P1)

Dans la liste des champions, chaque carte affiche une illustration verticale en haute définition, et non plus l'icône carrée agrandie qui devenait floue. Le visage du champion reste visible : quand l'image est rognée pour remplir la carte, c'est le haut qui est conservé.

**Why this priority**: c'est la demande explicite de l'utilisateur (images pixelisées, champions mal cadrés) et l'écran de la liste est la première chose qu'il voit.

**Independent Test**: ouvrir l'onglet des champions et regarder les cartes : aucune image n'est pixelisée, la tête de chaque champion est dans le cadre.

**Acceptance Scenarios**:

1. **Given** la liste des champions chargée, **When** une carte s'affiche, **Then** elle montre l'illustration verticale du champion (version de base) et non l'icône carrée.
2. **Given** une illustration plus haute que la carte, **When** elle est rognée, **Then** la partie haute (visage, épaules) reste visible et le bas est coupé.
3. **Given** la fiche de comparaison de champions, **When** un champion est choisi dans un emplacement, **Then** il utilise la même illustration verticale, ancrée en haut.

---

### User Story 2 - Une attente et un échec d'image lisibles (Priority: P2)

Pendant qu'une image se charge, un fond qui pulse doucement occupe sa place. Si Riot ne sert pas l'image (lien mort, panne), un fond discret ou le visuel de remplacement fourni par l'écran apparaît, jamais le bloc d'erreur du framework.

**Why this priority**: sur un réseau lent, une case vide immobile ressemble à une image cassée ; c'est un confort général, moins urgent que la netteté.

**Independent Test**: simuler un réseau lent puis un lien mort et observer une case qui pulse, puis une case de couleur de surface.

**Acceptance Scenarios**:

1. **Given** une image en cours de téléchargement, **When** l'écran s'affiche, **Then** un rectangle de la taille de l'image pulse entre la couleur de surface et une teinte légèrement plus claire.
2. **Given** une image introuvable, **When** le chargement échoue, **Then** l'écran affiche le visuel de remplacement de l'appelant s'il en fournit un, sinon un rectangle de couleur de surface.
3. **Given** une image déjà chargée une fois sur mobile, **When** elle est réaffichée, **Then** elle vient du cache disque et apparaît avec un fondu de 150 ms.

---

### User Story 3 - Lecteurs d'écran et contraste du texte discret (Priority: P3)

Les contrôles qui n'ont qu'une icône sont annoncés avec un nom et un état : le badge d'étoile des cartes (« Ajouter aux favoris » / « Retirer des favoris ») et chaque onglet de la barre de navigation (bouton, sélectionné ou non). Les images purement décoratives sont ignorées par les lecteurs d'écran, sauf si l'écran leur donne une description. Le texte discret atteint un rapport de contraste de 4,5:1.

**Why this priority**: valeur réelle mais invisible pour la majorité des utilisateurs ; elle ne bloque pas les autres parcours.

**Independent Test**: activer un lecteur d'écran (ou lancer les tests de sémantique) et parcourir une carte et la barre d'onglets.

**Acceptance Scenarios**:

1. **Given** une carte de champion non favorite, **When** un lecteur d'écran se place sur le badge, **Then** il annonce un bouton « Ajouter aux favoris » ; s'il est favori, « Retirer des favoris ».
2. **Given** la barre d'onglets, **When** un lecteur d'écran se place sur l'onglet actif, **Then** il annonce un bouton sélectionné ; les autres onglets sont des boutons non sélectionnés.
3. **Given** une image sans description, **When** un lecteur d'écran parcourt l'écran, **Then** l'image n'est pas annoncée ; avec une description, elle est annoncée comme image avec ce texte.
4. **Given** le texte secondaire ou discret posé sur le fond, la surface ou une puce choisie, **When** on mesure le contraste, **Then** il est d'au moins 4,5:1 dans les deux modes (clair et sombre).

---

### Edge Cases

- Sur le web, le cache disque n'est pas utilisé : l'image passe par le chargeur du navigateur, qui retombe sur un élément `<img>` quand le serveur n'envoie pas d'en-têtes CORS (commentaire de `lib/shared/widgets/remote_image/remote_image.dart`).
- Une image sans largeur ni hauteur impose son cadre au rectangle de chargement : le fond pulsé prend la taille que l'appelant a demandée (`ShimmerBox` accepte `null`).
- Un lien mort ne laisse jamais un chargement sans issue : l'état d'échec est affiché dès que le chargeur signale l'erreur.
- Un appelant qui fournit son propre visuel d'erreur le voit utilisé à la place du rectangle de surface.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT afficher, sur les cartes de la liste des champions, l'illustration verticale en haute définition du champion plutôt que son icône carrée.
- **FR-002**: Le système DOIT conserver la partie haute de l'illustration quand elle est rognée pour remplir son cadre (cartes de la liste et emplacements de la comparaison).
- **FR-003**: Le système DOIT continuer à utiliser l'icône carrée pour les affichages de petite taille.
- **FR-004**: Le système DOIT afficher, pendant le chargement d'une image, un fond de la taille de l'image dont la teinte oscille doucement.
- **FR-005**: Le système DOIT afficher, quand une image ne peut pas être servie, le visuel de remplacement fourni par l'écran ou à défaut un fond discret, et jamais le bloc d'erreur du framework.
- **FR-006**: Le système DOIT garder sur le disque les images déjà chargées (mobile) et les afficher avec un fondu court.
- **FR-007**: Le système DOIT ignorer pour les lecteurs d'écran toute image sans description, et annoncer comme image toute image qui en reçoit une.
- **FR-008**: Le système DOIT annoncer le badge favori des cartes comme un bouton nommé « Ajouter aux favoris » ou « Retirer des favoris » selon l'état.
- **FR-009**: Le système DOIT annoncer chaque onglet de la barre de navigation comme un bouton portant son libellé et son état sélectionné.
- **FR-010**: Le système DOIT garantir un rapport de contraste d'au moins 4,5:1 pour le texte secondaire et le texte discret, sur le fond, la surface et une puce choisie, dans les deux modes.

### Key Entities

- **Champion** : un personnage du jeu avec un identifiant, un nom, un titre, des rôles et deux visuels : une icône carrée pour les petits affichages et une illustration verticale (version de base) pour les grandes cartes.
- **Image distante** : une illustration servie par Riot, avec une taille demandée, un cadrage, une description optionnelle et un visuel de remplacement optionnel.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Sur la liste des champions, 100 % des cartes affichent l'illustration verticale, sans agrandir l'icône carrée.
- **SC-002**: Le visage est visible sur 100 % des cartes affichées (le cadrage conserve le haut de l'image).
- **SC-003**: Un lien d'image mort ne produit aucun bloc d'erreur du framework et aucun indicateur sans fin.
- **SC-004**: Le contraste du texte secondaire et du texte discret vaut au moins 4,5:1 sur chacun des trois fonds testés, dans les deux modes (`test/theme/contrast_test.dart`).
- **SC-005**: Tous les contrôles à icône seule des cartes et de la barre d'onglets ont un nom lu par un lecteur d'écran.

## Assumptions

- Les utilisateurs ont un accès réseau pour le premier chargement d'une image ; le cache disque ne sert que sur mobile.
- L'illustration verticale est celle de l'apparence de base (suffixe `_0`) : aucune apparence alternative n'est choisie pour les cartes.
- Le cadrage « haut du portrait » est le même pour tous les champions : il n'existe pas de réglage par champion.

### Hypothèses et limites connues

- Il n'y a **pas de test automatisé** dédié à `RemoteImage`, à `ShimmerBox`, à `ChampionCard` ni à `Champion.portraitUrl` : la netteté et le cadrage ont été vérifiés dans l'application. La sémantique des onglets est couverte par `test/main_navigation/app_nav_bar_test.dart` (la barre a été réécrite ensuite, `b9132b1`, en conservant ces annotations) et le contraste par `test/theme/contrast_test.dart` (ajouté plus tard, avec la palette claire/sombre).
- La valeur d'opacité du texte discret fixée dans `a1c29ba` (0,35 vers 0,5) a été remplacée depuis par les palettes `AppPalette.dark` et `AppPalette.light` ; le critère de 4,5:1 est resté.
- Le badge favori n'a pas de test de sémantique propre.
- Le fondu de 150 ms du chargeur mobile est une valeur littérale dans `remote_image.dart`, non nommée.
