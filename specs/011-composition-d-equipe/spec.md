# Feature Specification: Composition d'équipe

**Feature Branch**: `011-composition-d-equipe` (travail livré sur `main`, commit `2fe70c0`)

**Created**: 2026-10-05

**Status**: Implemented

**Input**: User description : « fais moi tout ca le boss », en réponse à la liste d'idées de fonctionnalités proposées, dont l'analyse de composition d'équipe.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Composer une équipe de cinq champions (Priority: P1)

Le joueur remplit les cinq places de l'équipe (Top, Jungle, Milieu, Bot, Support) en choisissant un champion pour chacune, peut en changer ou en retirer un, et vider l'équipe d'un geste.

**Why this priority**: sans équipe, il n'y a rien à analyser ; c'est le socle de l'écran.

**Independent Test**: ouvrir l'écran « Composition », remplir deux places, en retirer une, puis vider l'équipe.

**Acceptance Scenarios**:

1. **Given** l'écran « Composition », **When** il s'ouvre, **Then** cinq lignes vides (Top, Jungle, Milieu, Bot, Support) invitent à choisir un champion.
2. **Given** une ligne vide, **When** le joueur la touche, **Then** une feuille de choix de champion s'ouvre, qui exclut les champions déjà placés dans l'équipe et démarre filtrée sur le rôle de la ligne touchée.
3. **Given** un champion choisi, **When** la feuille se ferme, **Then** la ligne affiche son portrait et son nom, avec une croix pour le retirer.
4. **Given** au moins un champion placé, **When** le joueur touche l'icône « Vider l'équipe » de la barre du haut, **Then** les cinq places se vident ; l'icône n'existe pas quand l'équipe est vide.
5. **Given** un champion placé, **When** le joueur touche la ligne, **Then** il peut le remplacer.

---

### User Story 2 - Savoir si l'équipe est équilibrée en dégâts (Priority: P1)

Dès qu'un champion est placé, une barre montre la répartition des dégâts physiques et magiques de l'équipe, et un constat dit si un type de dégâts manque.

**Why this priority**: c'est l'analyse la plus attendue d'une composition (l'équipe adverse peut empiler l'armure ou la résistance magique).

**Independent Test**: placer cinq champions à dégâts physiques, vérifier la barre à 100 % physiques et le constat « Peu de dégâts magiques ».

**Acceptance Scenarios**:

1. **Given** une équipe de deux champions (8 attaque / 2 magie et 2 attaque / 8 magie), **When** le bilan s'affiche, **Then** la barre montre 50 % physiques, 50 % magiques.
2. **Given** moins de 20 % de dégâts magiques, **When** le bilan s'affiche, **Then** un avertissement « Peu de dégâts magiques » explique que l'équipe adverse peut empiler l'armure.
3. **Given** moins de 20 % de dégâts physiques (et au moins 20 % de magiques), **When** le bilan s'affiche, **Then** un avertissement « Peu de dégâts physiques » explique que l'adversaire peut empiler la résistance magique.
4. **Given** au moins 20 % de chaque type, **When** le bilan s'affiche, **Then** un constat positif « Dégâts équilibrés » donne les pourcentages.
5. **Given** une équipe 100 % physique, **When** la barre s'affiche, **Then** elle ne casse pas et seul le segment physique est dessiné.

---

### User Story 3 - Repérer l'absence de première ligne et de contrôle (Priority: P2)

Le bilan dit aussi s'il y a au moins un champion capable d'encaisser en première ligne et si l'équipe compte assez de sorts de contrôle pour bloquer une cible.

**Why this priority**: complète le diagnostic ; moins immédiat que l'équilibre des dégâts, mais demandé dans la même analyse.

**Independent Test**: placer cinq champions sans tank ni sort de contrôle, vérifier les avertissements « Pas de première ligne » et « Peu de contrôle ».

**Acceptance Scenarios**:

1. **Given** aucun champion Tank et aucune défense de 7 ou plus, **When** le bilan s'affiche, **Then** « Pas de première ligne » apparaît en avertissement.
2. **Given** au moins un Tank ou un champion de défense 7 ou plus, **When** le bilan s'affiche, **Then** « Première ligne présente » indique combien de champions peuvent encaisser.
3. **Given** moins de 3 sorts de contrôle dans l'équipe, **When** le bilan s'affiche, **Then** « Peu de contrôle » avertit, en précisant que c'est une estimation d'après les descriptions des sorts.
4. **Given** au moins 3 sorts de contrôle, **When** le bilan s'affiche, **Then** « Contrôle suffisant » est affiché avec le nombre de sorts repérés.

---

### User Story 4 - Ne pas conclure trop tôt (Priority: P3)

Avec moins de trois champions, l'écran n'émet aucun verdict : il invite à compléter l'équipe. Tant que l'équipe n'est pas complète, il précise combien de champions manquent.

**Why this priority**: évite des alertes à tort sur une équipe à moitié remplie.

**Independent Test**: placer deux champions, vérifier le message « Équipe incomplète » ; en placer trois, vérifier la présence des trois constats et du message « Il manque 2 champions ».

**Acceptance Scenarios**:

1. **Given** deux champions placés, **When** le bilan s'affiche, **Then** un seul constat d'information « Équipe incomplète » demande d'ajouter au moins trois champions.
2. **Given** trois ou quatre champions placés, **When** le bilan s'affiche, **Then** les trois constats (dégâts, première ligne, contrôle) s'affichent suivis d'une précision « Il manque N champion(s) : le bilan peut encore changer ».
3. **Given** aucun champion, **When** l'écran s'affiche, **Then** il invite à placer des champions pour voir si l'équipe est équilibrée.

---

### Edge Cases

- La fiche détaillée d'un champion (jauges, sorts) est téléchargée à part : tant qu'elle n'est pas arrivée, un indicateur s'affiche sur la ligne et le champion n'est pas compté dans le bilan. Un échec de téléchargement affiche un message dans une barre d'information (snackbar) ; le champion reste dans l'équipe mais absent du bilan (`lib/team/team_page.dart`, `loadDetail`).
- Une fiche déjà téléchargée n'est pas redemandée quand le champion revient dans l'équipe.
- Échec du chargement de la liste des champions : message d'erreur avec « Réessayer ».
- Le filtre de rôle de la feuille de choix est chargé sans bloquer l'écran ; s'il échoue, la feuille s'affiche simplement sans puces.
- Équipe sans dégâts (jauges nulles) : pourcentages à 0 et barre grise (test « sans dégâts, la barre reste affichable »).
- Si les dégâts magiques et physiques sont tous deux sous 20 %, seul le manque de magie est signalé (le test des magiques est évalué en premier).
- Un même champion ne peut pas occuper deux places (la feuille exclut ceux déjà placés).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT afficher cinq places d'équipe nommées Top, Jungle, Milieu, Bot, Support, chacune vide ou occupée par un champion.
- **FR-002**: Le système DOIT permettre de choisir, remplacer et retirer le champion d'une place, et de vider toute l'équipe.
- **FR-003**: Le système DOIT empêcher de placer deux fois le même champion.
- **FR-004**: Le système DOIT démarrer la feuille de choix filtrée sur le rôle de la place touchée, quand les données de rôles sont disponibles, et fonctionner sans ce filtre sinon.
- **FR-005**: Le système DOIT calculer la part de dégâts physiques et magiques de l'équipe à partir des jauges d'attaque et de magie de chaque champion, et l'afficher en pourcentages arrondis et en barre à deux couleurs.
- **FR-006**: Le système DOIT signaler un manque quand un type de dégâts pèse moins de 20 %.
- **FR-007**: Le système DOIT compter comme première ligne tout champion de rôle Tank ou de jauge de défense d'au moins 7, et avertir quand il n'y en a aucun.
- **FR-008**: Le système DOIT repérer les sorts de contrôle (les quatre sorts actifs, pas le passif) d'après des mots-clés de leur description française, et avertir quand l'équipe en compte moins de 3.
- **FR-009**: Le système DOIT présenter le décompte des sorts de contrôle comme une estimation d'après les descriptions.
- **FR-010**: Le système NE DOIT PAS émettre de verdict avec moins de 3 champions analysés ; il DOIT inviter à compléter l'équipe.
- **FR-011**: Le système DOIT indiquer combien de champions manquent tant que l'équipe compte moins de 5 champions analysés.
- **FR-012**: Le système DOIT distinguer les constats par une icône et un titre en plus de la couleur (point fort, manque, précision).
- **FR-013**: Le système DOIT annoncer chaque place d'équipe et la barre de dégâts de façon utilisable par un lecteur d'écran.
- **FR-014**: Le système DOIT afficher une erreur avec « Réessayer » si la liste des champions ne charge pas.
- **FR-015**: Le système DOIT être accessible depuis la section Outils (entrée « Composition », sous-titre « Équilibrer son équipe »).

### Key Entities *(include if feature involves data)*

- **Place d'équipe** : un des cinq rôles (Top, Jungle, Milieu, Bot, Support), associé à une voie du jeu, occupé par au plus un champion.
- **Membre d'équipe** : un champion avec sa fiche détaillée (jauges d'attaque, de magie, de défense ; description des sorts).
- **Bilan d'équipe** : part de dégâts physiques et magiques, nombre de champions de première ligne, nombre de sorts de contrôle, nombre de membres analysés, liste de constats.
- **Constat** : un diagnostic de type « point fort », « manque » ou « précision », avec un titre et un message.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Un joueur obtient le bilan complet d'une équipe de cinq champions en cinq choix, sans autre action.
- **SC-002**: Le bilan se met à jour sans rechargement de l'écran dès qu'une fiche de champion est arrivée.
- **SC-003**: Pour une même équipe, le bilan est identique à chaque affichage (calcul déterministe, aucun aléa).
- **SC-004**: Aucun constat négatif n'est émis pour une équipe de moins de 3 champions.
- **SC-005**: Chaque constat est compréhensible sans voir sa couleur (icône et titre explicites).

## Assumptions et limites connues

- Le repérage du contrôle est une **estimation** : Data Dragon ne dit pas quel sort contrôle ; la liste de mots-clés est volontairement étroite et peut manquer des sorts ou en compter à tort. L'écran l'écrit dans le message.
- Un champion de défense élevée compte comme première ligne même sans le rôle Tank (seuil 7 sur la jauge de Riot).
- L'écran n'enregistre pas l'équipe : elle disparaît quand on quitte l'écran.
- L'analyse ne tient pas compte des voies réelles ni de l'équipe adverse ; elle n'utilise que les jauges et les descriptions de sorts.
- L'écran « Composition » héberge aussi des raccourcis vers l'entraîneur de draft, la draft à deux et l'historique des drafts : ils appartiennent à d'autres fonctionnalités et ne sont pas spécifiés ici.
- Le filtre de rôle de la feuille de choix (`RoleFilters`) a été ajouté après le premier commit, par une tâche distincte ; il est décrit ici car il fait partie de l'écran actuel.
- L'injection des sources de données de la page (`loadChampions`, `loadDetail`, `loadProfile`) est du travail de la phase tests, présent dans l'arbre de travail mais non commité ; il n'existe pas encore de test d'écran de `TeamPage`.
- Les textes d'avertissement vouvoient l'utilisateur (« Ajoutez au moins trois champions ») alors que la constitution demande le tutoiement (voir `plan.md`).
