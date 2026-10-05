# Feature Specification: Données hors ligne

**Feature Branch**: `002-donnees-hors-ligne` (travail livré sur `main`, aucune branche dédiée)

**Created**: 2026-10-05 (premier commit `284ebd7` ; durcissement livré dans `0afb3b1`)

**Status**: Implemented

**Input**: User description : cette fonctionnalité fait partie de « ta des idee d'amelioration ? » suivi de « fais tout les changements pour ameliorer ca ». La demande n'est pas plus précise : elle consiste à garder une copie des données Riot pour ouvrir l'application sans connexion. Le durcissement (copies validées, fiches de champions bornées, copie corrompue, page de la carte avec « Réessayer ») est un audit demandé en cours de route et consigné dans `docs/agents/reports/offline-audit.md`.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Ouvrir l'application sans connexion avec les données du dernier lancement (Priority: P1)

Après un premier lancement réussi en ligne, l'utilisateur ouvre l'application sans réseau (métro, avion, panne du CDN de Riot). La liste des champions, les objets, les runes, les sorts d'invocateur et la version du jeu s'affichent à partir des dernières données reçues.

**Why this priority**: c'est le cœur de la demande : sans cette copie, l'application est vide dès que le réseau tombe.

**Independent Test**: charger les données une fois avec un faux serveur, puis couper le serveur et recharger : les mêmes données reviennent.

**Acceptance Scenarios**:

1. **Given** un document déjà reçu et enregistré, **When** le serveur de Riot est injoignable, **Then** le dernier document reçu est resservi.
2. **Given** aucune copie enregistrée, **When** le serveur de Riot est injoignable, **Then** l'écran reçoit une panne avec un message affichable (pas de plantage, pas d'attente sans fin).
3. **Given** un chargement qui n'a pas demandé de copie, **When** le réseau tombe ensuite, **Then** rien n'est resservi.
4. **Given** la version du jeu déjà connue d'un lancement précédent, **When** le réseau est coupé, **Then** la version enregistrée est utilisée.

---

### User Story 2 - Fiches de champions déjà consultées hors ligne (Priority: P2)

Une fiche de champion déjà ouverte en ligne reste lisible sans réseau, ainsi que le comparateur et la draft qui en dépendent. Pour ne pas saturer le stockage, seules les 12 fiches les plus récemment consultées sont gardées.

**Why this priority**: sans cela, la fiche d'un champion, le comparateur et la draft sont inutilisables hors ligne ; mais la liste, plus importante, est déjà couverte par l'US1.

**Independent Test**: ouvrir une fiche en ligne, couper le réseau, la rouvrir ; puis ouvrir une fiche jamais vue : un message d'erreur clair apparaît.

**Acceptance Scenarios**:

1. **Given** la fiche d'Ahri déjà consultée, **When** le réseau est coupé, **Then** la fiche d'Ahri s'affiche.
2. **Given** une fiche jamais consultée, **When** le réseau est coupé, **Then** le chargement échoue avec un message, sans plantage.
3. **Given** plus de copies de fiches que la limite, **When** une nouvelle fiche est enregistrée, **Then** les copies les plus anciennes sont effacées et seules les plus récentes restent lisibles hors ligne.

---

### User Story 3 - Une copie fiable : jamais écrasée par un mauvais document (Priority: P2)

Un portail captif, un CDN en erreur ou une page de maintenance peuvent répondre « 200 » avec un contenu qui n'est pas le bon. Ce contenu ne doit ni être affiché ni remplacer la bonne copie, sinon l'application casserait aussi hors ligne. Une copie corrompue ne donne jamais une erreur technique brute.

**Why this priority**: sans cette protection, la copie hors ligne pourrait se détruire elle-même.

**Independent Test**: enregistrer une bonne copie, faire répondre le serveur avec un JSON de mauvaise forme ou du HTML, couper le serveur : la bonne copie est toujours servie.

**Acceptance Scenarios**:

1. **Given** une bonne copie enregistrée, **When** le serveur répond « 200 » avec un JSON de mauvaise forme, **Then** la réponse est refusée et la bonne copie est servie à la place.
2. **Given** une bonne copie, **When** le serveur répond avec du HTML ou répond 503, **Then** la copie n'est pas écrasée et reste servie.
3. **Given** une copie illisible enregistrée, **When** le réseau est coupé, **Then** la panne remontée est un message affichable, pas une erreur de format brute.

---

### User Story 4 - « Réessayer » sur la page de la carte (Priority: P3)

Quand la version du jeu est introuvable (jamais lancée en ligne, réseau coupé), la page de la carte affiche le message de la panne et un bouton « Réessayer » qui relance le chargement, au lieu d'un texte « Chargement impossible » sans issue.

**Why this priority**: c'est la dernière page repérée par l'audit comme restant sans bouton de nouvelle tentative.

**Independent Test**: simuler un premier échec puis un succès : le bouton fait apparaître la carte.

**Acceptance Scenarios**:

1. **Given** la version du jeu qui échoue au premier appel, **When** la page de la carte s'ouvre, **Then** elle affiche un message et un bouton « Réessayer », sans carte.
2. **Given** cet écran d'erreur, **When** l'utilisateur appuie sur « Réessayer » et que le deuxième appel réussit, **Then** la carte s'affiche et le chargement a été relancé une seule fois de plus.

---

### Edge Cases

- Jamais lancé en ligne et réseau coupé : aucune version n'est connue, aucune copie n'existe ; l'écran affiche la panne et « Réessayer » doit pouvoir retenter (la version n'est pas figée en échec ; vérifié dans `test/data_dragon/data_dragon_service_test.dart`).
- Délai d'attente : au-delà de 15 secondes le serveur est considéré injoignable (message dédié).
- Réponse autre que 200 : message avec le code reçu ; avec une copie, c'est la copie qui est servie.
- Stockage plein ou indisponible : l'écriture de la copie échoue en silence, un chargement réussi n'est jamais transformé en échec.
- Copie enregistrée dont la forme n'est plus valide : la panne d'origine est remontée plutôt qu'une donnée de mauvaise forme.
- Une fiche sortie des 12 dernières, ou jamais consultée, reste indisponible hors ligne (limite acceptée).
- Les sections « bonus » de la fiche d'un champion (sorts, runes et objets conseillés) et la carte du patch de l'accueil sont masquées en silence si leurs copies manquent.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT garder sur l'appareil le dernier document de données Riot reçu pour chaque jeu de données demandé (version du jeu, champions, objets, runes, sorts d'invocateur) et le resservir quand Riot est injoignable.
- **FR-002**: Le système DOIT ne conserver une copie qu'après avoir décodé le document et vérifié sa forme.
- **FR-003**: Le système DOIT refuser un document de mauvaise forme comme s'il s'agissait d'une panne et servir la dernière bonne copie.
- **FR-004**: Le système DOIT remonter toute panne (réseau, délai de 15 s, code d'erreur, corps illisible, forme inattendue) sous la forme d'une erreur portant un message affichable en français.
- **FR-005**: Le système DOIT remonter la panne d'origine, et non une erreur technique brute, quand la copie enregistrée est illisible ou de mauvaise forme.
- **FR-006**: Le système DOIT garder hors ligne les fiches de champions déjà consultées, dans la limite des 12 plus récentes, en effaçant les plus anciennes.
- **FR-007**: Le système DOIT utiliser, pour nommer une copie, un nom logique et non l'adresse du fichier, afin de ne pas empiler une copie par patch.
- **FR-008**: Le système DOIT ne jamais faire échouer un chargement réussi à cause de l'impossibilité d'écrire la copie.
- **FR-009**: Le système DOIT ne pas figer un échec : après une panne de récupération de la version du jeu, un nouvel appel doit pouvoir retenter.
- **FR-010**: La page de la carte DOIT afficher le message de la panne et un bouton « Réessayer » qui relance réellement le chargement de la version du jeu.
- **FR-011**: Les écrans qui chargent champions, objets, runes ou sorts d'invocateur DOIVENT afficher un message et un bouton « Réessayer » en cas d'échec, jamais un indicateur de chargement sans issue.
- **FR-012**: Le système NE DOIT PAS conserver hors ligne un document pour lequel aucune clé de copie n'est demandée.

### Key Entities

- **Copie hors ligne** : le dernier texte JSON valide reçu pour un jeu de données, identifié par un nom logique (ex. `champions`, `champion:Ahri`).
- **Famille de copies** : l'ensemble des copies dont le nom a le même préfixe (`champion:`), borné à un nombre maximal de copies récentes.
- **Panne de données** : une erreur portant un message déjà rédigé pour l'utilisateur.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Après un premier lancement réussi, 100 % des écrans de liste (champions, objets, runes, sorts) s'ouvrent sans réseau avec les données du dernier lancement.
- **SC-002**: Une fiche de champion consultée parmi les 12 dernières s'ouvre sans réseau ; une 13e consultation en efface la plus ancienne.
- **SC-003**: Un document de mauvaise forme, un corps illisible ou une réponse d'erreur ne modifient jamais la copie enregistrée (testé).
- **SC-004**: Aucune panne de chargement ne laisse l'utilisateur sans message : tout échec affiche un texte lisible et, hors cas bonus, un bouton « Réessayer ».
- **SC-005**: Un échec de chargement de la version du jeu suivi d'un appel réussi ne demande pas de relancer l'application.

## Assumptions

- La copie n'a de sens que si l'application a été lancée au moins une fois avec du réseau.
- Les images ne font pas partie de cette fonctionnalité : elles ont leur propre cache (voir fonctionnalité 001) ; les matchups sont un fichier embarqué, donc toujours disponibles.
- Les favoris, builds, drafts, quiz et thème sont stockés localement et ne dépendent pas du réseau.

### Hypothèses et limites connues

- Les écrans de la fiche d'un champion avalent en silence l'erreur des sections « sorts », « runes » et « objets conseillés » : elles sont masquées sans message hors ligne si leurs copies manquent (acceptable, noté par l'audit).
- La carte du patch de l'accueil est absente en silence sans version (idem).
- Les index statiques de runes et d'objets consultés par certains widgets restent vides si la page parente n'a pas chargé le service : pas de plantage.
- Le stockage du navigateur est limité (environ 5 Mo selon l'audit) : c'est ce qui motive la limite de 12 fiches.
- Il n'y a pas de test direct de `OfflineJsonCache` (couvert via `DataDragonService`), ni des quatre services d'objets, runes et sorts, ni des pages d'écran qui affichent « Réessayer » (hors la page de la carte).
- La première version (`284ebd7`) relançait, en cas de copie illisible, une exception de format brute (le commentaire promettait l'inverse) ; elle est corrigée dans `0afb3b1`.
