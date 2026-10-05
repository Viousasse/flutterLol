# Feature Specification: Matchups, contre-picks et points forts

**Feature Branch**: `010-matchups-contre-picks-et-points-forts` (travail livré sur `main`, commits `20e90af`, `0b3b86d`, `55b4700`)

**Created**: 2026-10-05

**Status**: Implemented

**Input**: User description, en plusieurs demandes successives :

- le choix « Contre-picks » parmi les idées de fonctionnalités proposées ;
- « fais en sorte que quand je demande un conteurs il y a une data » ;
- « si je met mon perso mettre les perso contre qui c'est fort dans un nouvel onglets dans outils » ;
- « telecharge plus de donner » (suivie de la clé Riot fournie pour régénérer le fichier de données).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Trouver qui jouer contre un champion adverse (Priority: P1)

Le joueur sait quel champion il va affronter. Il l'indique et obtient la liste des champions qui le battent le plus souvent dans les parties classées Master+ analysées, du meilleur au moins bon, chacun avec son pourcentage de victoires face à cet adversaire et le nombre de parties derrière ce pourcentage.

**Why this priority**: c'est la demande d'origine (« Contre-picks »). Sans cet écran, la fonctionnalité n'existe pas.

**Independent Test**: ouvrir l'écran « Contre-picks », choisir un adversaire, vérifier que la liste s'affiche, ordonnée par pourcentage décroissant.

**Acceptance Scenarios**:

1. **Given** l'écran « Contre-picks » sans adversaire choisi, **When** il s'ouvre, **Then** il invite à choisir le champion à affronter.
2. **Given** un adversaire choisi qui a des bilans fiables, **When** la liste s'affiche, **Then** les champions sont classés du meilleur au moins bon taux de victoire, avec le rang, le nom, le nombre de parties et le pourcentage.
3. **Given** un adversaire affronté dans plusieurs voies, **When** l'écran s'affiche, **Then** une barre de voies propose « Toutes les voies » et chaque voie jouée ; choisir une voie restreint la liste à cette voie.
4. **Given** une voie sélectionnée, **When** le joueur change d'adversaire, **Then** le filtre de voie est remis sur « Toutes les voies » (la voie précédente n'a peut-être pas de données pour le nouvel adversaire).
5. **Given** une proposition affichée, **When** le joueur la touche, **Then** la fiche de ce champion s'ouvre.
6. **Given** un adversaire jamais affronté dans la voie choisie, **When** la liste est vide, **Then** un message invite à essayer une autre voie ou un autre champion.

---

### User Story 2 - Toujours obtenir des propositions, même avec peu de données (Priority: P1)

Quand le joueur demande des contre-picks, il ne reçoit jamais une liste vide pour un champion qui apparaît dans les données. Si un adversaire a été peu rencontré, la liste est complétée par des champions dont le bilan repose sur peu de parties, clairement marqués « peu de données » et classés avec prudence.

**Why this priority**: c'est la deuxième demande (« quand je demande un conteurs il y a une data ») : le premier jet affichait des listes vides pour des champions rares.

**Independent Test**: demander les contre-picks d'un champion peu joué : la liste contient des propositions marquées « peu de données » et une phrase de mise en garde.

**Acceptance Scenarios**:

1. **Given** un adversaire avec moins de 5 bilans fiables, **When** les contre-picks sont demandés, **Then** les bilans fiables passent d'abord, puis la liste est complétée par des bilans peu fiables jusqu'à 15 propositions au plus.
2. **Given** un adversaire sans aucun bilan fiable, **When** la liste s'affiche, **Then** elle contient quand même des propositions, toutes marquées « peu de données ».
3. **Given** une liste contenant au moins une proposition peu fiable, **When** elle s'affiche, **Then** une phrase indique que ces propositions sont indicatives.
4. **Given** 3 victoires sur 3 parties contre 14 sur 20, **When** le classement des bilans peu fiables est établi, **Then** le petit échantillon ne passe pas devant le bilan mieux fondé (le taux est tempéré par des parties neutres).
5. **Given** les vraies données embarquées, **When** on demande les contre-picks de n'importe quel champion qui y figure comme adversaire, **Then** la liste n'est jamais vide.

---

### User Story 3 - Voir contre qui mon champion est fort et contre qui il souffre (Priority: P2)

Le joueur indique son propre champion et obtient deux listes : les adversaires contre lesquels il gagne le plus (« FORT CONTRE ») et ceux contre lesquels il perd le plus (« DIFFICILE CONTRE »).

**Why this priority**: troisième demande (« si je met mon perso mettre les perso contre qui c'est fort dans un nouvel onglets dans outils ») ; c'est le miroir des contre-picks, utile mais secondaire.

**Independent Test**: ouvrir l'outil « Points forts » depuis la section Outils, choisir un champion, vérifier les deux sections.

**Acceptance Scenarios**:

1. **Given** l'écran « Points forts » sans champion choisi, **When** il s'ouvre, **Then** il invite à choisir son champion.
2. **Given** un champion choisi, **When** les résultats s'affichent, **Then** la section « FORT CONTRE » liste les adversaires du meilleur au moins bon taux de victoire du champion choisi, et « DIFFICILE CONTRE » liste jusqu'à 5 adversaires contre lesquels il perd, du pire au moins mauvais.
3. **Given** un champion sans aucune faiblesse fiable, **When** les résultats s'affichent, **Then** la section « DIFFICILE CONTRE » est absente.
4. **Given** un champion joué dans plusieurs voies, **When** le joueur choisit une voie, **Then** les deux sections se restreignent à cette voie.
5. **Given** les vraies données embarquées, **When** on demande les points forts de n'importe quel champion qui y figure, **Then** la liste « FORT CONTRE » n'est jamais vide.
6. **Given** un champion sans partie analysée (ou aucune dans la voie choisie), **When** les résultats s'affichent, **Then** un message le dit et suggère une autre voie ou un autre champion.

---

### User Story 4 - Savoir d'où viennent les chiffres (Priority: P2)

Chaque écran de résultats dit, avec les mêmes mots, sur combien de parties, de quel rang, de quelle région et de quels patchs reposent les pourcentages, et précise de quel champion est le pourcentage.

**Why this priority**: la quatrième demande (« telecharge plus de donner ») porte sur la fiabilité ; la note de provenance rend l'effort de données visible et évite de présenter un chiffre sans contexte.

**Independent Test**: ouvrir un écran de résultats et lire la note sous la liste (« Données : 7 600 parties classées Master+ (EUW), patchs 16.16–16.19. »).

**Acceptance Scenarios**:

1. **Given** le fichier de données embarqué, **When** une liste s'affiche, **Then** la note indique le nombre de parties avec séparateur de milliers, « classées Master+ (EUW) » et le ou les patchs.
2. **Given** un seul patch, **When** la note s'affiche, **Then** elle dit « patch » au singulier ; avec une plage, « patchs ».
3. **Given** un fichier de données vide ou sans patch, **When** la note s'affiche, **Then** elle dit « Aucune donnée de matchups disponible. »
4. **Given** les contre-picks, **When** la liste s'affiche, **Then** une ligne précise que le pourcentage est celui du champion proposé face à l'adversaire ; sur « Points forts », que c'est celui du champion choisi face à chaque adversaire.

---

### User Story 5 - Ouvrir ces outils depuis la fiche d'un champion (Priority: P3)

Sur la fiche d'un champion, deux liens ouvrent directement l'outil avec ce champion déjà choisi : « Contre qui est-il fort ? » (Points forts) et « Qui jouer contre lui ? » (Contre-picks).

**Why this priority**: raccourci de confort, les outils existent sans lui.

**Independent Test**: ouvrir la fiche d'un champion, toucher chaque lien et vérifier que le champion est pré-sélectionné.

**Acceptance Scenarios**:

1. **Given** la fiche d'un champion, **When** le joueur touche « Qui jouer contre lui ? », **Then** l'écran « Contre-picks » s'ouvre avec ce champion comme adversaire.
2. **Given** la fiche d'un champion, **When** le joueur touche « Contre qui est-il fort ? », **Then** l'écran « Points forts » s'ouvre avec ce champion choisi.

---

### Edge Cases

- Chargement des champions ou des matchups en échec : l'écran affiche le message d'erreur avec « Réessayer », et la page se charge au nouvel essai (`test/counters/counters_page_test.dart`, `test/strengths/strengths_page_test.dart`).
- Fichier de matchups vide ou illisible côté contenu : l'écran affiche « Les matchups ne sont pas disponibles pour le moment. » après le choix d'un champion.
- Une proposition dont le champion est absent de la liste de Data Dragon (par exemple un champion trop récent pour la version en cache) n'est pas affichée (ligne ignorée par `_tile`).
- Une paire de champions avec moins de 8 parties est considérée peu fiable : elle n'apparaît dans les faiblesses jamais, dans les listes de propositions seulement comme complément marqué « peu de données ».
- Un bilan à une seule partie dit « 1 partie » (singulier) et non « 1 parties ».
- La draft ne reprend pas les propositions peu fiables : elle demande les contre-picks sans repli (voir hypothèses).
- Le filtre de rôle de la feuille de choix de champion s'appuie sur les voies observées dans les données (voir `specs` des filtres de rôle, hors périmètre).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT proposer un écran « Contre-picks » où l'on choisit le champion adverse dans une feuille de choix.
- **FR-002**: Le système DOIT classer les champions qui battent l'adversaire du meilleur au moins bon taux de victoire, puis, à taux égal, par nombre de parties décroissant, puis par ordre alphabétique de l'identifiant.
- **FR-003**: Le système DOIT limiter la liste à 15 propositions.
- **FR-004**: Le système DOIT considérer un bilan comme fiable à partir de 8 parties.
- **FR-005**: Le système DOIT, quand l'adversaire compte moins de 5 bilans fiables, compléter la liste avec des bilans peu fiables classés par taux tempéré (ajout de 10 parties fictives à 50 %), puis nombre de parties, puis ordre alphabétique.
- **FR-006**: Le système DOIT marquer chaque bilan peu fiable « peu de données » (affichage et libellé d'accessibilité) et afficher une phrase de prudence dès qu'une proposition peu fiable est présente.
- **FR-007**: Le système DOIT permettre de restreindre les résultats à une voie, parmi celles réellement jouées dans les données, triées par volume de parties décroissant, avec « Toutes les voies » qui additionne les voies ; la barre de voies n'apparaît que s'il y a plus d'une voie.
- **FR-008**: Le système DOIT remettre le filtre de voie sur « Toutes les voies » quand le champion choisi change.
- **FR-009**: Le système DOIT proposer un écran « Points forts » où l'on choisit son champion et obtient « FORT CONTRE » (même règle de classement et de repli que FR-002 à FR-006) et « DIFFICILE CONTRE ».
- **FR-010**: Le système DOIT limiter « DIFFICILE CONTRE » à 5 adversaires, uniquement parmi les bilans fiables dont le taux de victoire est inférieur à 50 %, du pire au moins mauvais, puis par nombre de parties décroissant, puis ordre alphabétique.
- **FR-011**: Le système DOIT afficher, sur chaque résultat, le rang, le portrait, le nom du champion, le nombre de parties et le pourcentage de victoires arrondi, en vert quand il dépasse 50 %.
- **FR-012**: Le système DOIT ouvrir la fiche d'un champion quand on touche une proposition.
- **FR-013**: Le système DOIT afficher sous les résultats une note de provenance unique (nombre de parties, rang Master+, région EUW, patchs) et préciser de quel champion est le pourcentage.
- **FR-014**: Le système DOIT afficher l'erreur avec une action « Réessayer » si le chargement échoue, et un indicateur de chargement tant qu'il dure.
- **FR-015**: Le système DOIT lire les matchups depuis un fichier embarqué dans l'application, sans appel réseau, et le charger une seule fois par exécution même si plusieurs écrans le demandent en même temps.
- **FR-016**: Le système DOIT fournir un fichier de données dont chaque champion apparu comme adversaire a des contre-picks, et chaque champion joué a des points forts.
- **FR-017**: Le système DOIT proposer, sur la fiche d'un champion, les liens « Contre qui est-il fort ? » et « Qui jouer contre lui ? » qui ouvrent l'outil correspondant avec le champion déjà choisi.
- **FR-018**: Le système DOIT proposer « Points forts » et « Contre-picks » dans la section Outils de l'accueil.
- **FR-019**: Le système DOIT annoncer chaque ligne de résultat et chaque sélecteur de champion de façon utilisable par un lecteur d'écran (nom, pourcentage, nombre de parties, mention « peu de données »).

### Key Entities *(include if feature involves data)*

- **Matchup** : bilan d'un champion face à un adversaire précis dans une voie, sur un nombre de parties et de victoires.
- **Jeu de données de matchups** : l'ensemble des matchups, avec le patch (ou la plage de patchs), le nombre de parties analysées, la région et le rang ; peut être vide.
- **Proposition (contre-pick)** : un champion avec son nombre de parties et de victoires face à un adversaire ; fiable ou non selon le nombre de parties.
- **Bilan global** : parties et victoires d'un champion cumulées sur tous ses adversaires (utilisé par la fiche champion ; hors écrans de cette fonctionnalité).
- **Voie** : TOP, JUNGLE, MIDDLE, BOTTOM, UTILITY, affichées Top, Jungle, Mid, Bot, Support.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Pour 100 % des champions présents dans les données embarquées, l'écran « Contre-picks » affiche au moins une proposition et l'écran « Points forts » au moins un adversaire dans « FORT CONTRE ».
- **SC-002**: Un joueur obtient la liste des contre-picks d'un adversaire en moins de 3 gestes depuis l'écran d'accueil (Outils, Contre-picks, choix du champion) et en 1 geste depuis la fiche du champion.
- **SC-003**: Aucune proposition affichée ne repose sur moins d'une partie, et toute proposition de moins de 8 parties est signalée « peu de données ».
- **SC-004**: Les données embarquées reposent sur 7 600 parties classées Master+ EUW, patchs 16.16–16.19, soit plus de trois fois les 2 500 parties du premier jet.
- **SC-005**: Le classement est déterministe : deux affichages successifs du même adversaire donnent exactement le même ordre.

## Assumptions et limites connues

- Les données couvrent uniquement des parties classées Master+ de la région EUW ; la note de provenance le dit mais l'écran n'avertit pas que d'autres rangs ou régions peuvent différer.
- Le fichier de données est généré hors de l'application (outil `tool/generate_matchups.dart`, décrit dans la spécification 019) ; aucune clé Riot n'est embarquée dans l'application. La clé fournie par l'utilisateur n'est utilisée que par l'outil local.
- La draft (`lib/draft/services/draft_evaluator.dart`) demande les contre-picks sans le repli sur les bilans peu fiables (`includeLowConfidence: false`) pour ne pas présenter comme alternative un choix mal fondé.
- Le texte des écrans vouvoie l'utilisateur (« Choisissez… », « essayez… ») alors que la constitution demande le tutoiement : écart relevé dans `plan.md`.
- Les couleurs de la ligne de proposition (vert de victoire, orange d'avertissement) sont écrites en dur dans `CounterTile` ; c'est une exception tolérée aux couleurs de sens, relevée dans `plan.md`.
- La voie « principale » d'un champion (`MatchupService.mainLaneOf`) et le bilan en tête-à-tête (`headToHead`) servent la fiche champion et la comparaison ; ils ne font pas partie des parcours ci-dessus.
- L'injection des sources de données dans les pages (`loadChampions`, `loadDataset`) et les tests d'écran des deux pages sont du travail de la phase tests (T14), présent dans l'arbre de travail au moment de la rédaction, pas encore commité.
