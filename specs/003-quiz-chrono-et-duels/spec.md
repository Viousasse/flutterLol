# Feature Specification: Quiz : chrono, historique des séries et duels

**Feature Branch**: `003-quiz-chrono-et-duels` (travail livré sur `main`, aucune branche dédiée)

**Created**: 2026-10-05 (premier commit `412ea8f` ; catégorie « Duels » livrée dans `0afb3b1`)

**Status**: Implemented

**Input**: User description : « ta des idee d'amelioration ? » suivi de « fais tout les changements pour ameliorer ca » pour le mode chrono et l'historique des séries ; plus tard, parmi les idées proposées, le choix « Quiz sur les matchups — Qui bat qui ? » pour la catégorie « Duels ». Le quiz du jour de l'accueil (`lib/quiz/services/quiz_service.dart`, `DailyQuizCard`) est hors périmètre : il n'est pas modifié.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Jouer contre la montre (Priority: P1)

Sur l'onglet Quiz, une puce « Chrono 15 s » active un compte à rebours. Une barre et un nombre de secondes montrent le temps qu'il reste pour répondre. Quand le temps est écoulé, la question compte comme une mauvaise réponse : la bonne réponse est montrée, la série s'arrête.

**Why this priority**: c'est l'amélioration principale demandée pour le quiz et elle change la manière de jouer.

**Independent Test**: activer le chrono, laisser passer 15 secondes sans répondre : la correction « Temps écoulé : … » s'affiche et la série retombe à 0.

**Acceptance Scenarios**:

1. **Given** le chrono désactivé, **When** l'utilisateur appuie sur « Chrono 15 s », **Then** la puce est sélectionnée et une barre avec « 15 s » apparaît au-dessus de la question en cours.
2. **Given** une question avec le chrono actif, **When** une seconde passe, **Then** le nombre de secondes baisse de 1.
3. **Given** il reste 5 secondes ou moins, **When** la barre s'affiche, **Then** elle passe en rouge ; le nombre reste affiché, la couleur n'est pas la seule information.
4. **Given** une question avec le chrono actif, **When** le temps arrive à zéro, **Then** le message « Temps écoulé : <bonne réponse>. » s'affiche, la série tombe à 0 et la question est comptée parmi les questions répondues.
5. **Given** une question avec le chrono actif, **When** l'utilisateur répond avant la fin, **Then** le chrono s'arrête et la barre disparaît.
6. **Given** une nouvelle question, **When** elle est tirée, **Then** le chrono repart de 15 secondes.
7. **Given** le quiz sous un autre onglet de l'application, **When** l'utilisateur change d'onglet pendant une question, **Then** le temps n'avance pas et la question n'expire pas avant son retour.

---

### User Story 2 - Garder l'historique de ses séries (Priority: P2)

Sous le score, une ligne « DERNIÈRES SÉRIES » liste les longueurs des séries de bonnes réponses terminées, de la plus récente à la plus ancienne, et reste mémorisée d'un lancement à l'autre.

**Why this priority**: elle donne un sens à la meilleure série et au chrono, mais le jeu fonctionne sans.

**Independent Test**: enchaîner 3 bonnes réponses puis une mauvaise : « 3 » apparaît en tête de la ligne ; relancer l'application : elle est toujours là.

**Acceptance Scenarios**:

1. **Given** une série de 3 bonnes réponses, **When** l'utilisateur se trompe ou laisse le temps s'écouler, **Then** « 3 » est ajouté en tête de l'historique.
2. **Given** une série de 0, **When** elle se termine, **Then** rien n'est ajouté.
3. **Given** déjà 8 séries retenues, **When** une neuvième se termine, **Then** la plus ancienne est retirée.
4. **Given** aucune série terminée, **When** l'écran s'affiche, **Then** la ligne n'est pas montrée.
5. **Given** une série qui dépasse le record, **When** une bonne réponse est donnée, **Then** la meilleure série est mise à jour et mémorisée.

---

### User Story 3 - La catégorie « Duels » : Qui bat qui ? (Priority: P2)

Une catégorie « Duels » pose deux sortes de questions tirées des parties réellement comptées. Le face-à-face : « En Mid, qui gagne le plus souvent : A ou B ? » (deux choix). Le meilleur contre une cible : « Quel champion gagne le plus souvent contre X en Mid ? » (trois ou quatre choix). Les chiffres exacts n'apparaissent qu'après la réponse.

**Why this priority**: elle enrichit le quiz avec les données de matchups, mais le quiz existait déjà sans elle.

**Independent Test**: choisir la puce « Duels » et répondre ; la correction cite le pourcentage et le nombre de parties.

**Acceptance Scenarios**:

1. **Given** des duels suffisamment joués avec un écart net, **When** la catégorie « Duels » est choisie, **Then** la question est un face-à-face à deux propositions ou un « meilleur contre X » à trois ou quatre propositions.
2. **Given** une question de face-à-face, **When** elle est posée, **Then** la bonne réponse est le champion qui gagne au moins 56 % de ce duel, et l'ordre des deux noms dans l'énoncé est aléatoire.
3. **Given** une question « meilleur contre X », **When** elle est posée, **Then** la bonne réponse devance chaque autre proposition d'au moins 6 points de taux de victoire, la cible n'est pas une proposition et aucun champion n'apparaît deux fois.
4. **Given** une question répondue, **When** la correction s'affiche, **Then** elle indique le taux de victoire arrondi et le nombre de parties ; l'énoncé ne contient jamais de pourcentage.
5. **Given** un duel joué moins de 8 fois, **When** les questions sont tirées, **Then** il n'est jamais utilisé.
6. **Given** des données de duels insuffisantes ou absentes, **When** l'écran se charge, **Then** la puce « Duels » n'est pas affichée et « Tout » reste utilisable avec les autres familles.
7. **Given** la catégorie « Duels » choisie puis devenue indisponible, **When** les données sont rechargées, **Then** la sélection revient à « Tout ».

---

### Edge Cases

- Fichier de matchups absent ou illisible : le quiz fonctionne sans « Duels » (la page attrape l'erreur et utilise un jeu vide).
- Champions ou objets introuvables (réseau, copie absente) : le message de la panne et « Réessayer » s'affichent à la place du quiz.
- Une catégorie ne produit aucune question : un bloc « Aucune question disponible dans cette catégorie. Touchez pour réessayer. » permet de retirer.
- Duels déjà tous posés : la série repart de zéro plutôt que de laisser la famille muette (comportement de `QuizGenerator.next` et `DuelQuestionBuilder.startOver`, sans test dédié ; `pas de doublon dans une même série` vérifie seulement l'absence de répétition tant qu'il reste des énoncés).
- Deux questions de suite n'ont jamais le même énoncé.
- Un champion qui n'est pas dans la liste chargée n'apparaît jamais dans une question de duel.
- Un écart trop faible entre deux taux de victoire ne produit pas de question.
- Désactiver le chrono en cours de question retire la barre et arrête le décompte.
- Un temps écoulé avec une série nulle n'ajoute rien à l'historique.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: L'utilisateur DOIT pouvoir activer ou désactiver un mode chrono de 15 secondes par question depuis l'écran du quiz ; il est désactivé par défaut.
- **FR-002**: Avec le chrono actif, le système DOIT afficher le temps restant sous forme de barre et de nombre de secondes pour la question en attente de réponse, et le redémarrer à chaque nouvelle question.
- **FR-003**: Le système DOIT passer l'affichage du temps en rouge à partir de 5 secondes restantes tout en gardant le nombre lisible, et annoncer « N secondes restantes » aux lecteurs d'écran.
- **FR-004**: À l'expiration du temps, le système DOIT compter la question comme répondue et ratée, interrompre la série, afficher « Temps écoulé : <bonne réponse>. » et la correction.
- **FR-005**: Le chrono NE DOIT PAS avancer quand l'écran du quiz n'est pas visible (autre onglet ouvert).
- **FR-006**: Le chrono DOIT s'arrêter dès qu'une réponse est donnée.
- **FR-007**: Le système DOIT mémoriser la meilleure série de bonnes réponses d'un lancement à l'autre.
- **FR-008**: Le système DOIT conserver la liste des 8 dernières séries terminées (par mauvaise réponse ou temps écoulé), de la plus récente à la plus ancienne, d'un lancement à l'autre.
- **FR-009**: Le système NE DOIT PAS retenir une série de zéro.
- **FR-010**: Le système DOIT afficher la ligne « DERNIÈRES SÉRIES » seulement quand l'historique n'est pas vide.
- **FR-011**: Le système DOIT proposer une famille de questions « Duels » avec deux formes : un face-à-face à deux choix, et « meilleur contre X » à trois ou quatre choix.
- **FR-012**: Le système DOIT n'utiliser pour les duels que des confrontations jouées au moins 8 fois, entre deux champions différents, sur une voie connue, et dont les deux champions sont dans la liste chargée.
- **FR-013**: Le système DOIT n'ouvrir un face-à-face que si le vainqueur a au moins 6 points au-dessus de 50 % de victoires, et n'ouvrir un « meilleur contre X » que si la bonne réponse devance chaque autre proposition d'au moins 6 points.
- **FR-014**: Le système DOIT ne montrer les chiffres (taux de victoire arrondi, nombre de parties) que dans la correction, jamais dans l'énoncé.
- **FR-015**: Le système DOIT ne pas poser deux fois le même duel dans une série, puis recommencer la série quand tous ont été posés ; il NE DOIT PAS poser deux fois de suite le même énoncé.
- **FR-016**: Le système DOIT masquer toute famille pour laquelle les données ne permettent aucune question, remettre la sélection sur « Tout » si la famille choisie disparaît, et continuer à fonctionner sans « Duels » quand le fichier de matchups n'est pas lisible.
- **FR-017**: Le système DOIT afficher le message de la panne et « Réessayer » quand les champions ou les objets ne peuvent pas être chargés.
- **FR-018**: Le système DOIT produire des tirages reproductibles à graine égale (utile pour les tests).

### Key Entities

- **Question de quiz** : une famille, un énoncé, une image optionnelle, 2 à 4 propositions, l'indice de la bonne réponse et une explication facultative.
- **Famille de questions** : Champions, Régions, Objets, Duels.
- **Confrontation (matchup)** : un champion contre un adversaire sur une voie, avec un nombre de parties et de victoires.
- **Série** : nombre de bonnes réponses d'affilée ; meilleure série (record) et séries terminées (historique borné à 8).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Avec le chrono actif et sans action, la question expire après 15 secondes et la série est remise à zéro.
- **SC-002**: L'historique contient au plus 8 séries et la plus récente est toujours en tête, après relance de l'application (`test/quiz/quiz_score_service_test.dart`).
- **SC-003**: 100 % des questions de la famille « Duels » ont une seule bonne réponse défendable : écart d'au moins 6 points, au moins 8 parties (`test/quiz/matchup_quiz_test.dart`).
- **SC-004**: Aucun énoncé de duel ne contient de pourcentage.
- **SC-005**: Sans données de duels, la puce « Duels » n'est jamais affichée et aucune question de cette famille n'est posée.
- **SC-006**: Les cinq puces (« Tout » et les quatre familles) tiennent sans défilement à 360 et 375 px de large.

## Assumptions

- Les données de matchups sont celles du fichier embarqué ; la fiabilité des taux dépend du nombre de parties comptées (fonctionnalité hors périmètre).
- L'utilisateur joue sur l'onglet Quiz de l'application, qui reste vivant sous les autres onglets.
- Les champions et objets sont ceux déjà chargés par l'application (copie hors ligne comprise, voir fonctionnalité 002).

### Hypothèses et limites connues

- Il n'y a **pas de test automatisé de la page** `QuizPage` : le décompte, l'expiration, la pause quand l'onglet est masqué et l'activation du chrono ne sont couverts ni par widget test ni par test de service. Seuls la barre de temps (`test/quiz/quiz_timer_bar_test.dart`), l'historique et le record (`test/quiz/quiz_score_service_test.dart`), la barre de familles (`test/quiz/quiz_category_bar_test.dart`) et les duels (`test/quiz/matchup_quiz_test.dart`, `test/quiz/quiz_generator_test.dart`) le sont. Le widget `QuizHistory` n'a pas de test propre.
- Le réglage du chrono n'est pas mémorisé : il revient à « désactivé » à chaque ouverture de l'application.
- Une série en cours n'entre dans l'historique que lorsqu'elle se termine : si l'utilisateur quitte l'application en pleine série, elle n'est pas retenue (le record, lui, est mis à jour à chaque bonne réponse).
- Les textes « Testez vos connaissances » et « Touchez pour réessayer » sont au vouvoiement, alors que la constitution demande le tutoiement.
- La catégorie s'appelait « Matchups » avant ce travail avec une seule question (« Contre lequel X gagne-t-il le plus souvent ? », écart de 12 points) ; elle est remplacée par les deux formes ci-dessus et renommée « Duels ».
- Un face-à-face part du taux de victoire du duel dans le sens enregistré : un duel à 62 % pour A contre B donne A pour bonne réponse ; son sens inverse (B contre A, 38 %) n'est pas retenu comme candidat.
