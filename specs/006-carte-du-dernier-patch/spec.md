# Feature Specification: Carte du dernier patch sur l'accueil

**Feature Branch**: `006-carte-du-dernier-patch` (travail livré sur `main`, sans branche dédiée)

**Created**: 2026-10-05

**Status**: Implemented

**Input**: User description: « esque dans la page d'acceuil tu peux metre le dernier patch note » (commit `e973e19`).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Accéder aux notes du dernier patch depuis l'accueil (Priority: P1)

Le joueur ouvre l'application. Sur l'accueil, sous le champion du jour, une carte « DERNIER PATCH » annonce « Notes de patch 26.19 » (numéro du dernier patch) et un appui ouvre la page officielle des notes dans le navigateur.

**Why this priority**: c'est la demande entière ; la carte n'a pas d'autre rôle.

**Independent Test**: ouvrir l'accueil avec un accès réseau, vérifier le numéro, appuyer sur la carte.

**Acceptance Scenarios**:

1. **Given** la dernière version du jeu « 16.19.1 », **When** l'accueil s'affiche, **Then** la carte annonce « Notes de patch 26.19 ».
2. **Given** la carte affichée, **When** le joueur l'appuie, **Then** la page `https://www.leagueoflegends.com/fr-fr/news/game-updates/league-of-legends-patch-26-19-notes` s'ouvre dans une application externe (navigateur).
3. **Given** que la page ne peut pas s'ouvrir, **When** le joueur appuie sur la carte, **Then** le message « Impossible d'ouvrir les notes de patch. » s'affiche.

---

### User Story 2 - L'accueil reste complet sans la carte (Priority: P2)

Si la version du jeu ne peut pas être obtenue, ou n'a pas la forme attendue, l'accueil s'affiche entièrement sans la carte et sans message d'erreur.

**Why this priority**: la carte est un bonus et ne doit jamais dégrader la page d'accueil.

**Independent Test**: couper le réseau sans copie locale de la version, ouvrir l'accueil.

**Acceptance Scenarios**:

1. **Given** la version du jeu introuvable, **When** l'accueil se charge, **Then** aucune carte de patch n'apparaît et le reste de l'accueil est normal.
2. **Given** une version illisible (« abc », « 16.x.1 », vide), **When** le numéro de patch est déduit, **Then** il n'y a pas de carte.
3. **Given** une version sans numéro de correctif (« 16.3 »), **When** le numéro est déduit, **Then** la carte annonce 26.3.

---

### Edge Cases

- Carte lue par un lecteur d'écran : libellé « Lire les notes du patch 26.19 », annoncé comme bouton.
- Chargement de la version plus lent que celui des champions : la carte apparaît après coup, sans bloquer l'accueil ni afficher d'indicateur dédié.
- Échec du chargement de l'accueil lui-même (champions) : l'écran d'erreur « Réessayer » de l'accueil remplace tout, carte comprise.
- Thème clair ou sombre : la carte utilise les couleurs du thème (teinte d'accent douce).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT afficher sur l'accueil, sous le champion du jour, une carte annonçant le numéro du dernier patch du jeu.
- **FR-002**: Le système DOIT déduire le numéro du patch de la dernière version publiée du jeu, en ajoutant 10 au numéro de saison (16.19.1 devient 26.19).
- **FR-003**: Le système DOIT ouvrir, à l'appui sur la carte, la page officielle française des notes de ce patch dans une application externe.
- **FR-004**: Le système DOIT informer le joueur par un message quand la page ne peut pas être ouverte.
- **FR-005**: Le système DOIT omettre la carte, sans message, quand la version du jeu est indisponible ou illisible, et NE DOIT PAS en empêcher l'affichage du reste de l'accueil.
- **FR-006**: Le système DOIT exposer la carte aux lecteurs d'écran comme un bouton « Lire les notes du patch <numéro> ».
- **FR-007**: La carte NE DOIT PAS prétendre afficher le contenu des notes : elle indique seulement qu'elles sont sur le site officiel.

### Key Entities *(include if feature involves data)*

- **Notes de patch**: un numéro de patch affiché (« 26.19 ») et l'adresse de la page officielle correspondante.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: En un appui depuis l'accueil, le joueur atteint la page officielle des notes du dernier patch.
- **SC-002**: Pour toute version Data Dragon de la forme `saison.patch[.correctif]`, le numéro affiché est `saison+10.patch` (3 cas testés).
- **SC-003**: Quel que soit l'état du réseau, l'accueil s'affiche sans attente supplémentaire due à la carte (aucun indicateur de chargement lui est propre).
- **SC-004**: 100 % des versions illisibles testées donnent l'absence de carte, jamais une erreur visible.

## Assumptions

- La version la plus récente de Data Dragon est celle du dernier patch publié.
- L'adresse des notes suit le motif `league-of-legends-patch-<année>-<patch>-notes` : ce motif est codé en dur et n'a pas été vérifié par une requête dans le code ni dans les tests ; si Riot change de motif, le lien mènera à une page introuvable.
- Le décalage de 10 entre numéro de saison et numéro du site (16 → 26) est une valeur constante supposée stable.

### Limites connues

- **Écart avec la demande** : l'utilisateur voulait « mettre le dernier patch note » sur l'accueil ; ce qui est livré est un **lien** vers les notes officielles, pas leur contenu. Riot ne publie pas le contenu des notes dans une API, d'où le choix d'un lien (commentaire de `lib/patch_notes/models/patch_notes.dart`).
- La fonctionnalité ajoute une dépendance (`url_launcher`) absente de la liste de la constitution (voir `plan.md`).
- Aucun test de widget ne couvre la carte ni son ouverture ; seul le calcul du numéro est testé.
