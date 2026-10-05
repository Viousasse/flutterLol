# Feature Specification: Thème clair / sombre et palette du client LoL

**Feature Branch**: `013-theme-clair-sombre-et-palette-lol` (travail livré sur `main`, pas de branche dédiée)

**Created**: 2026-10-05

**Status**: Implemented

**Input**: User description : « fais un monde claire et sombre » ; puis « mets les couleurs a l'image de lol » ; puis la correction de la carte « Champion du jour », illisible en mode clair.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Basculer entre mode clair et mode sombre (Priority: P1)

Depuis l'accueil, l'utilisateur ouvre la feuille « Affichage » et choisit entre trois réglages : Automatique (suit l'appareil), Clair ou Sombre. L'application change de couleurs immédiatement, sans perdre l'écran affiché, l'onglet courant ni une saisie en cours.

**Why this priority**: c'est la demande d'origine (« un monde clair et sombre »). Sans bascule, rien d'autre dans cette fonctionnalité n'a de sens.

**Independent Test**: ouvrir l'accueil, appuyer sur l'icône d'affichage, choisir « Clair » puis « Sombre » ; tout l'écran change de couleurs à chaque choix, et la feuille reste ouverte avec la coche sur le bon choix.

**Acceptance Scenarios**:

1. **Given** l'accueil affiché en mode sombre, **When** l'utilisateur ouvre la feuille « Affichage » et choisit « Clair », **Then** toutes les surfaces, textes et accents passent à la palette claire sans changer d'écran.
2. **Given** la feuille « Affichage » ouverte, **When** l'utilisateur change de mode, **Then** la feuille elle-même prend les couleurs du nouveau mode et la coche suit le choix.
3. **Given** un champ de recherche contenant du texte, **When** le mode change, **Then** le texte saisi et l'onglet courant sont conservés.

---

### User Story 2 - Le choix est mémorisé et l'appareil est suivi (Priority: P1)

Le mode choisi est conservé entre deux lancements. Tant que l'utilisateur n'a rien choisi (ou choisit « Automatique »), l'application suit le réglage clair/sombre de l'appareil, y compris quand celui-ci change pendant que l'application est ouverte.

**Why this priority**: sans mémoire, l'utilisateur referait son choix à chaque ouverture ; sans suivi de l'appareil, le réglage « Automatique » serait trompeur.

**Independent Test**: choisir « Clair », fermer et rouvrir l'application : elle s'ouvre directement en clair, sans passer un instant par le sombre.

**Acceptance Scenarios**:

1. **Given** un mode « Clair » enregistré, **When** l'application démarre, **Then** le premier écran s'affiche déjà en clair.
2. **Given** le mode « Automatique » et un appareil en sombre, **When** l'appareil passe en clair (coucher/lever du soleil par exemple), **Then** l'application passe en clair d'elle-même.
3. **Given** le mode « Clair » choisi, **When** l'appareil passe en sombre, **Then** l'application reste claire.
4. **Given** aucune valeur enregistrée, **When** l'application démarre, **Then** le mode est « Automatique ».

---

### User Story 3 - Couleurs à l'image du client League of Legends (Priority: P2)

Les deux modes reprennent l'identité visuelle du client du jeu : bleu nuit presque noir et or pâle en mode sombre ; parchemin et encre bleu nuit en mode clair (or assombri pour garder la lisibilité).

**Why this priority**: seconde demande (« mets les couleurs à l'image de LoL ») ; elle change l'apparence, pas le comportement.

**Independent Test**: ouvrir n'importe quel écran dans chaque mode ; le fond est bleu nuit/parchemin et les accents sont dorés, plus aucune teinte corail.

**Acceptance Scenarios**:

1. **Given** le mode sombre, **When** on affiche un écran, **Then** le fond est bleu nuit (`#010A13`), les cartes `#0A1428`, l'accent or pâle `#C8AA6E` et le texte parchemin `#F0E6D2`.
2. **Given** le mode clair, **When** on affiche un écran, **Then** le fond est parchemin (`#F3EEE2`), les cartes `#FBF8F1`, l'accent or foncé `#7A5C1E` et le texte bleu nuit `#0A1428`.
3. **Given** le mode clair, **When** on fait défiler une page sous la barre du haut, **Then** aucune teinte rosée n'apparaît sur la barre ni sur les feuilles.

---

### User Story 4 - Lisibilité garantie dans les deux modes (Priority: P2)

Tous les textes (principal, secondaire, discret) et l'accent utilisé comme texte restent lisibles sur le fond, les cartes et une puce de filtre sélectionnée, avec un rapport de contraste d'au moins 4,5:1 (seuil RGAA).

**Why this priority**: l'accessibilité est une contrainte du projet ; une palette jolie mais illisible serait un défaut.

**Independent Test**: lancer `flutter test test/theme` ; les tests de contraste passent pour les deux palettes.

**Acceptance Scenarios**:

1. **Given** une des deux palettes, **When** on mesure le contraste du texte principal, secondaire et discret sur le fond et sur les cartes, **Then** chaque rapport est d'au moins 4,5:1.
2. **Given** une puce de filtre sélectionnée (accent doux sur fond), **When** on mesure le texte discret, secondaire et l'accent dessus, **Then** chaque rapport est d'au moins 4,5:1.

---

### User Story 5 - Carte « Champion du jour » lisible en mode clair (Priority: P3)

La carte du champion du jour sur l'accueil affiche son texte sur une photo. Elle garde un voile sombre et un texte clair dans les deux modes, pour que le nom et le titre ne disparaissent pas dans l'image en mode clair.

**Why this priority**: correctif d'un défaut visible apparu avec le mode clair ; circonscrit à une seule carte.

**Independent Test**: passer en mode clair, ouvrir l'accueil : nom, titre, étiquette de rôle et « Lire son histoire » sont lisibles sur la photo.

**Acceptance Scenarios**:

1. **Given** le mode clair, **When** l'accueil affiche la carte du champion du jour, **Then** le nom du champion est en texte clair sur un dégradé sombre, comme en mode sombre.

---

### Edge Cases

- Stockage indisponible au démarrage : l'application suit l'appareil au lieu de planter, et le chargement peut être retenté (`ThemeService._load`).
- Valeur enregistrée inconnue ou corrompue : le mode retombe sur « Automatique » (`ThemeService._decode`).
- Stockage indisponible au moment d'un choix : le choix reste appliqué pour la session, sans être gardé.
- Un changement du réglage de l'appareil sans effet réel (même luminosité) ne reconstruit rien (`_applyBrightness` sort si la luminosité est identique).
- Un changement de mode pendant que la feuille « Affichage » est ouverte : la feuille se repeint (le fond de la feuille n'est pas fixé à l'ouverture).
- Le changement de mode alors que des widgets constants sont à l'écran : toute l'arborescence est redessinée pour qu'ils relisent les couleurs.
- Page sous la barre d'application en mode clair : le mélange automatique de l'accent (teinte rosée) est désactivé.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT proposer trois modes d'affichage : Automatique, Clair, Sombre, avec pour chacun un libellé et une courte description en français.
- **FR-002**: Le système DOIT permettre de choisir le mode depuis une feuille « Affichage » ouverte par une icône de l'accueil dont l'info-bulle est « Changer l'affichage (clair ou sombre) » et dont l'icône reflète le mode courant.
- **FR-003**: Le système DOIT appliquer un changement de mode immédiatement à tout l'écran, sans perdre l'écran, l'onglet ni les saisies en cours.
- **FR-004**: Le système DOIT mémoriser le mode choisi entre deux lancements et le relire avant le premier rendu, pour ne jamais s'ouvrir dans le mauvais mode.
- **FR-005**: Le système DOIT, en mode Automatique (réglage par défaut), suivre la luminosité de l'appareil, y compris ses changements en cours d'utilisation.
- **FR-006**: Le système DOIT, quand le stockage est indisponible ou la valeur illisible, retomber sur « Automatique » sans erreur.
- **FR-007**: Le système DOIT fournir deux palettes (sombre et claire) de huit couleurs chacune : fond, surface, accent, texte principal, texte secondaire, texte discret, bordure, accent doux. La palette sombre reprend le bleu nuit et l'or du client LoL ; la claire un parchemin et une encre bleu nuit avec un or assombri.
- **FR-008**: Le système DOIT garantir un rapport de contraste d'au moins 4,5:1 pour le texte principal, secondaire et discret sur le fond, les cartes et une puce sélectionnée, et pour l'accent utilisé en texte, dans les deux palettes.
- **FR-009**: Le système DOIT empêcher tout mélange automatique de l'accent avec les barres et feuilles (teinte rosée en mode clair).
- **FR-010**: La feuille « Affichage » DOIT indiquer le mode courant (coche et état sélectionné) et annoncer son titre comme un titre aux technologies d'assistance.
- **FR-011**: La carte « Champion du jour » DOIT garder, dans les deux modes, un dégradé sombre et un texte clair pour rester lisible sur la photo.

### Key Entities

- **Mode d'affichage** : choix de l'utilisateur parmi automatique, clair, sombre ; mémorisé.
- **Palette** : ensemble de huit couleurs d'un mode (sombre ou clair).
- **Luminosité effective** : clair ou sombre, déduite du mode choisi et, en automatique, de l'appareil.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Un changement de mode est visible sur tout l'écran en une seule action de l'utilisateur (un appui), sans rechargement ni perte de saisie.
- **SC-002**: Après un redémarrage, 100 % des lancements s'ouvrent directement dans le mode choisi, sans affichage transitoire de l'autre mode.
- **SC-003**: 100 % des combinaisons texte/fond testées (principal, secondaire, discret, accent ; fond, carte, puce choisie ; deux modes) atteignent un contraste d'au moins 4,5:1.
- **SC-004**: Plus aucune couleur de l'interface (fond, surface, accent, texte, bordure) ne provient de l'ancienne palette corail ; seule subsiste la couleur de sens des dégâts physiques (`damage_split_bar`).
- **SC-005**: La feuille « Affichage » est utilisable avec un lecteur d'écran : son titre est annoncé comme titre et le choix courant est indiqué.

## Assumptions

- Le réglage clair/sombre de l'appareil est fourni par le système ; sur le web, c'est celui du navigateur.
- Les couleurs sensibles au sens (rôles, états) restent des constantes propres à leur écran et ne dépendent pas du mode.
- Les polices sont déjà embarquées et ne changent pas entre modes.

## Hypothèses et limites connues

- Les palettes ont **huit** couleurs, pas neuf comme l'indique le commentaire de la classe `AppPalette` dans `lib/theme/app_colors.dart` (commentaire inexact).
- Le commentaire sur le contraste « à 0,5 d'opacité… » placé au-dessus de la palette sombre date de l'ancienne palette (valeurs actuelles : 0,62 et 0,55) ; la raison reste valide (4,5:1) mais le chiffre cité est périmé.
- Les couleurs sont lues à la volée dans une palette globale statique, et le changement de mode force la reconstruction de tout l'arbre : choix assumé, plus simple qu'un `InheritedWidget`, mais il oblige tout widget à lire les couleurs à la construction.
- La carte « Champion du jour » force la palette sombre (`AppPalette.dark`) sur la photo ; elle n'a pas de test dédié.
- Les tests de contraste ne couvrent pas les couleurs de sens propres à chaque écran.
- Le contraste de la bordure n'est pas testé (élément décoratif).
