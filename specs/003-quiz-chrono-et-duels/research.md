# Research: Quiz : chrono, historique des séries et duels

## Chrono de 15 secondes, mauvaise réponse à l'expiration

- **Decision**: `_secondsPerQuestion = 15` ; à zéro, `_expire()` pose un index spécial `_timedOutIndex = -1`, incrémente `answered`, remet la série à 0 et enregistre la série terminée.
- **Rationale**: commentaires de `quiz_page.dart` : l'index « -1 » signifie qu'aucune proposition n'a été choisie mais que la question compte comme répondue, pour afficher la correction ; « le temps écoulé compte comme une mauvaise réponse : la série s'arrête ». La valeur de 15 secondes n'est pas justifiée dans le code : c'est une valeur de goût.
- **Alternatives considered**: aucune tracée (pas d'autres durées, pas de réglage utilisateur).

## Le chrono attend le retour sur l'onglet

- **Decision**: `_tick()` ne fait rien quand `TickerMode.valuesOf(context).enabled` est faux.
- **Rationale**: commentaire : l'onglet reste vivant sous l'`IndexedStack` (commit `6ea513f`) quand on en ouvre un autre, et son `TickerMode` est alors coupé ; le chrono attend le retour plutôt que de faire expirer la question dans le dos du joueur.
- **Alternatives considered**: détruire l'état de la page à chaque changement d'onglet est contraire au choix de l'`IndexedStack` ; aucune autre option tracée.

## Barre rouge et nombre toujours affiché

- **Decision**: `QuizTimerBar.urgentSeconds = 5` ; la barre passe à `quizWrongColor`, le nombre « N s » reste affiché, et une étiquette « N secondes restantes » est lue par les lecteurs d'écran.
- **Rationale**: commentaire de la classe : « le nombre reste lisible sans la couleur » (ne pas passer l'information par la couleur seule). Tests : `la barre vire au rouge sur les dernières secondes`, `affiche les secondes restantes`.
- **Alternatives considered**: aucune tracée.

## Historique : on retient les séries terminées, pas les séries nulles

- **Decision**: `recordFinished(streak)` ajoute la série en tête et garde 8 éléments (`maxRecentStreaks`) ; une série ≤ 0 est ignorée. `submit` ne gère que le record.
- **Rationale**: commentaires : « Au-delà, la liste ne tient plus sur une ligne de l'écran du quiz » ; « une série de zéro n'est pas une série ». Les écritures passent par une file (`_enqueue`) pour qu'une écriture en échec ne casse pas les suivantes. Tests dans `quiz_score_service_test.dart`.
- **Alternatives considered**: aucune tracée.

## Un notifieur comme les favoris

- **Decision**: `QuizScoreService` expose des `ValueNotifier` (`bestStreak`, `recentStreaks`), relus par l'écran sans rechargement.
- **Rationale**: commentaire : « même forme que les favoris » ; principe V de la constitution.
- **Alternatives considered**: aucune.

## Duels : une seule réponse défendable

- **Decision**: les duels sont tirés d'un jeu fiable : au moins `MatchupService.minGames` (8) parties, champions différents, voie connue. Le face-à-face exige que le vainqueur ait au moins 56 % (`minGap = 0.06` au-dessus de 50 %). Le « meilleur contre X » exige que la bonne réponse devance chaque autre proposition d'au moins 6 points, avec 3 à 4 propositions.
- **Rationale**: commentaire de la classe : « Une question n'est posée que si une seule réponse est défendable : les duels trop peu joués sont écartés, et il faut un écart net […]. Sans ça, le quiz récompenserait la chance. » Le seuil de 8 parties vient de `MatchupService` : en dessous, trois parties gagnées sur quatre ne sont pas un « counter ». L'ancienne question exigeait 12 points d'écart entre les deux premiers ; celle-ci passe à 6 points sur chaque proposition. Le commentaire sur `_minDuelEdge` précise qu'un duel à 56 % laisse l'adversaire à 44 %, soit 12 points d'écart entre les deux.
- **Alternatives considered**: l'ancienne question unique `_bestMatchup` (« Contre lequel X gagne-t-il le plus souvent ? ») est supprimée, remplacée par deux formes ; la raison du changement n'est pas écrite dans le code.

## Chiffres dans la correction, pas dans l'énoncé

- **Decision**: `_explain` produit « <A> gagne N % de ses duels contre <B> (M parties). » ; l'énoncé n'a aucun nombre.
- **Rationale**: commentaire : « dans l'énoncé ils auraient donné la solution ». Test : `les chiffres sont dans l explication, pas dans l énoncé`.
- **Alternatives considered**: aucune.

## Ordre aléatoire et pas de doublon dans une série

- **Decision**: l'ordre des deux noms dans le face-à-face est tiré au sort ; une clé par énoncé (`duel:A:B:lane` triée, `counter:cible|voie`) évite les répétitions ; quand tout a servi, `startOver()` vide l'ensemble.
- **Rationale**: commentaires : le gagnant ne doit pas toujours être cité en premier ; A contre B et B contre A sont la même question ; la série repart « pour que le quiz ne s'arrête jamais ».
- **Alternatives considered**: aucune tracée.

## Masquer la famille sans données

- **Decision**: `QuizGenerator.availableCategories()` sonde chaque famille avec un générateur à part (graine 0) ; la page transmet l'ensemble à `QuizCategoryBar(available: …)` et retombe sur « Tout » si la famille choisie disparaît. Les matchups illisibles donnent `MatchupDataset.empty()`.
- **Rationale**: commentaires : « l'écran la masque au lieu de proposer une catégorie qui ne rend rien » ; « le sondage passe par un générateur à part pour ne pas entamer la série de celui qui sert au quiz » ; « les duels enrichissent le quiz mais ne le conditionnent pas ».
- **Alternatives considered**: aucune tracée.
