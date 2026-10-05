# Feature Specification: Filtre de rôle dans le choix d'un champion

**Feature Branch**: `018-filtre-de-role` (travail livré sur `main`)

**Created**: 2026-10-05 (commit `23ea5c6` pour la draft ; câblage dans les autres écrans dans `0afb3b1`)

**Status**: Implemented

**Input**: User description : « dans choix filtre de draft mettre les perso par roles ». La demande ne visait que la draft ; la même feuille de choix est partagée par la composition, les contre-picks, les points forts, le comparateur et l'éditeur de builds, qui ont reçu le même filtre ensuite.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Choisir un champion par rôle dans la draft (Priority: P1)

Dans la draft, quand je touche une case de choix, la feuille de sélection s'ouvre avec des puces « Tous, Top, Jungle, Milieu, Bot, Support », le rôle de la case touchée étant déjà sélectionné : je ne vois que les champions qui se jouent à ce poste. Pour un bannissement, aucun rôle n'est imposé.

**Why this priority**: c'est la demande d'origine ; choisir un champion parmi plus de 160 sans repère de poste est le point de friction.

**Independent Test**: ouvrir la feuille sur la case « Milieu » : seuls les champions jouables au milieu apparaissent et la puce « Milieu » est sélectionnée.

**Acceptance Scenarios**:

1. **Given** une draft, **When** je touche la case Top, **Then** la feuille s'ouvre filtrée sur Top.
2. **Given** la feuille filtrée sur Top, **When** je touche « Tous », **Then** tous les champions disponibles s'affichent.
3. **Given** la feuille filtrée, **When** je touche une autre puce, **Then** la liste change immédiatement.
4. **Given** un bannissement, **When** la feuille s'ouvre, **Then** « Tous » est sélectionné.
5. **Given** un champion polyvalent, **When** je filtre sur un de ses rôles, **Then** il apparaît pour chacun de ses rôles.

---

### User Story 2 - Combiner le filtre avec la recherche et les exclusions (Priority: P2)

Le filtre de rôle se cumule avec la recherche par nom, et les champions déjà placés ailleurs restent absents quel que soit le rôle.

**Why this priority**: sans cela le filtre casserait deux comportements existants de la feuille.

**Independent Test**: filtrer sur Top puis taper « fio » : seul Fiora reste ; un champion exclu n'apparaît sous aucun rôle.

**Acceptance Scenarios**:

1. **Given** le rôle Top et la recherche « fio », **When** je consulte la liste, **Then** seuls les champions Top dont le nom contient « fio » apparaissent.
2. **Given** un champion exclu, **When** je change de rôle, **Then** il n'est jamais proposé.
3. **Given** un filtre sans résultat, **When** la liste est vide, **Then** « Aucun champion ne correspond. » s'affiche.

---

### User Story 3 - Le même filtre partout où l'on choisit un champion (Priority: P2)

La composition d'équipe (rôle de la case touchée présélectionné), le choix d'un adversaire dans les contre-picks, le choix d'un champion dans les points forts, le comparateur et l'éditeur de builds proposent les mêmes puces.

**Why this priority**: cohérence ; chaque écran partage la même feuille.

**Independent Test**: ouvrir la composition, toucher la case Jungle : la puce Jungle est sélectionnée. Dans les contre-picks, « Tous » est sélectionné.

**Acceptance Scenarios**:

1. **Given** la page Composition, **When** je touche la case de rang n, **Then** le rôle de rang n est sélectionné à l'ouverture.
2. **Given** les contre-picks, les points forts ou le comparateur, **When** j'ouvre la feuille, **Then** les puces sont présentes avec « Tous » sélectionné.
3. **Given** que les données de matchups ne se chargent pas, **When** j'ouvre la feuille de la composition ou de l'éditeur, **Then** la feuille s'ouvre sans puces et je peux choisir n'importe quel champion.

---

### Edge Cases

- Un champion absent des parties analysées (nouveau, rare) n'apparaît sous aucun rôle précis mais reste visible sous « Tous » (`champion_picker_sheet_test.dart`, « sans rôle de départ, montre tous les champions »).
- Un champion qui n'a que quelques parties ou une part minime dans un rôle n'y figure pas (seuils de FR-005).
- Sans filtre fourni, aucune puce n'est affichée et la feuille se comporte comme avant (« sans filtre de rôle, aucune puce n'est affichée »).
- Les puces défilent horizontalement pour tenir sur un petit écran.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT proposer dans la feuille de choix d'un champion une rangée de puces « Tous » puis les cinq rôles dans l'ordre Top, Jungle, Milieu, Bot, Support.
- **FR-002**: Le système DOIT présélectionner le rôle de la case touchée dans la draft et la composition, et « Tous » pour un bannissement ou quand aucun rôle n'est connu.
- **FR-003**: Le système DOIT ne montrer, pour un rôle sélectionné, que les champions qui s'y jouent régulièrement ; « Tous » montre tous les champions disponibles.
- **FR-004**: Un champion polyvalent DOIT figurer sous chacun de ses rôles.
- **FR-005**: Un champion DOIT être considéré à sa place dans un rôle s'il y compte au moins 8 parties analysées et au moins 15 % de ses parties totales.
- **FR-006**: Le filtre DOIT se combiner avec la recherche par nom et avec la liste des champions exclus.
- **FR-007**: Le système DOIT afficher « Aucun champion ne correspond. » quand le filtre et la recherche ne laissent rien.
- **FR-008**: La feuille DOIT rester utilisable sans filtre : si les données de matchups ne se chargent pas, elle s'affiche sans puces et tous les champions sont proposés.
- **FR-009**: Le filtre DOIT être proposé dans la draft, la composition, les contre-picks, les points forts, le comparateur et l'éditeur de builds.
- **FR-010**: Les puces DOIVENT annoncer leur état sélectionné aux lecteurs d'écran (voir fonctionnalité 020).

### Key Entities

- **Rôle** : un des cinq postes d'une équipe, associé à une voie (Top, Jungle, Milieu, Bot, Support).
- **Profil de voies** : pour chaque champion, le nombre de parties analysées par voie ; sert à dire où un champion se joue.
- **Filtre de rôle** : les rôles proposés, la règle « ce champion se joue ici » et la voie de départ.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Ouvrir la feuille sur une case de rôle donne une liste ne contenant que des champions de ce rôle, sans geste supplémentaire.
- **SC-002**: Passer d'un rôle à un autre, ou à « Tous », met la liste à jour en un seul toucher.
- **SC-003**: Aucun champion exclu n'est jamais proposé, quel que soit le rôle.
- **SC-004**: Sans données de matchups, 100 % des champions restent choisissables.

## Assumptions et limites connues

- Le rôle d'un champion est déduit des parties classées Master+ EUW embarquées (voir fonctionnalité 019) et non d'une liste officielle : un champion récent ou rare peut manquer sous son rôle jusqu'à la prochaine mise à jour des données.
- Dans la draft, le filtre s'appuie sur le profil déjà chargé par le bot ; ailleurs, sur un profil chargé à l'ouverture de l'écran. Dans l'éditeur de builds et la composition, le profil se charge en arrière-plan : une feuille ouverte avant la fin du chargement s'affiche sans puces.
- Les barres de voie « Toutes les voies » des contre-picks et des points forts (`LaneFilterBar`) sont un autre contrôle, antérieur, qui filtre les résultats affichés et non la feuille de choix ; elles utilisent la même puce visuelle (`AppFilterChip`).
- Il n'y a pas de test d'écran propre à la draft, à la composition, au comparateur ou à l'éditeur pour le filtre : la règle est testée sur la feuille et sur le constructeur de filtre.
