# Research : Entraîneur de draft

## 1. Ordre des choix et des bannissements « comme en classée »

- **Decision**: choix dans l'ordre bleu, rouge, rouge, bleu, bleu, rouge, rouge, bleu, bleu, rouge (`draftPickOrder`) ; bannissements un à un en alternance, bleu en premier, cinq par camp, avant tout choix (`draftBanOrder`, `bansPerSide = 5`).
- **Rationale**: commentaires de `lib/draft/models/draft_state.dart` : « comme en partie classée. Le camp rouge a donc le dernier mot » ; « les bannissements alternent un à un […] avant le moindre choix ». Le joueur est toujours le bleu et ouvre.
- **Alternatives considered**: aucune trace (un ordre en serpent plus simple ou un ordre aléatoire n'est mentionné nulle part).

## 2. État de draft immuable

- **Decision**: `DraftState` ne se modifie pas ; `pick` et `ban` renvoient un nouvel état et lèvent `StateError` si le coup est illégal (rôle pris, champion indisponible, mauvais camp, mauvaise phase).
- **Rationale**: commentaire : « permet à l'écran de comparer l'avant et l'après sans surprise ». Testé par « un choix ne modifie pas l'état précédent » et « un bannissement ne modifie pas l'état précédent ».
- **Alternatives considered**: non documentées.

## 3. Le site joue avec le même barème qu'un joueur, plus de hasard

- **Decision**: `DraftBot.choose` choisit d'abord un rôle déjà pris par l'adversaire s'il en existe (pour pouvoir contrer), puis score les champions libres qui se jouent à ce poste : `(taux de victoire − 0,5) × 100` si le taux est fiable, `(taux du duel − 0,5) × 150` contre l'adversaire de la voie, +6 par manque comblé (dégâts magiques, physiques, première ligne), + un aléa de 0 à 2. Il tire ensuite au hasard parmi les trois premiers.
- **Rationale**: commentaires de `lib/draft/services/draft_bot.dart` : « choisir toujours la première rendrait chaque draft identique » (`shortlistSize = 3`) ; `counterWeight` : « un champion à 60 % de victoire dans le duel gagne 15 points » ; `winRateWeight` : « 55 % rapporte 5 points » ; `jitter` : « pour départager les égalités ». Valeurs choisies à la main, aucune trace d'ajustement sur des parties réelles.
- **Alternatives considered**: non documentées.

## 4. « Se joue à ce poste » d'après les parties analysées

- **Decision**: `LaneProfile.fits` : un champion est à sa place dans une voie s'il y a au moins `MatchupService.minGames` (8) parties et au moins 15 % de ses parties dans cette voie.
- **Rationale**: commentaire de `minShare` : écarter « les paris isolés (un mage en jungle une fois sur cinquante) sans exclure les vrais choix polyvalents ». Testé (« écarte un pari isolé dans une autre voie »).
- **Alternatives considered**: non documentées. Repli : faute de candidat connu au poste, le site comme le conseiller prennent n'importe quel champion libre « plutôt que de bloquer la draft » (testé : « retombe sur n'importe quel champion libre faute de données »).

## 4 bis. `LaneProfile` déplacé vers `matchups`

- **Decision**: la classe est passée de `lib/draft/services/lane_profile.dart` à `lib/matchups/services/lane_profile.dart` (commit `0afb3b1`).
- **Rationale**: elle sert aussi aux contre-picks, aux points forts, au comparateur, à l'éditeur de builds et à la page d'équipe (voir `grep LaneProfile lib`). Le message du commit ne l'explique pas ; c'est la raison que montrent les usages.
- **Alternatives considered**: aucune trace.

## 5. Bannissements du site : forts et très joués

- **Decision**: `DraftBot.chooseBan` score chaque champion libre : aléa de 0 à 2, + `(taux − 0,5) × 100` s'il est fiable, + (parties / parties du champion le plus joué) × 4 ; tirage parmi les quatre premiers (`banShortlistSize = 4`).
- **Rationale**: commentaire : « de préférence un de ceux qui gagnent souvent et qu'on croise souvent, car ce sont ceux qu'un adversaire reprendra » (`banPopularityWeight`).
- **Alternatives considered**: non documentées.

## 5 bis. Un barème partagé entre le site et le conseiller

- **Decision**: `DraftBot.needBonusFor` et `needsFilledBy` sont publics et statiques, et `DraftAdvisor` y reprend `counterWeight`, `winRateWeight`, `needBonus`.
- **Rationale**: commentaire : « Partagé avec le conseiller de draft » ; le conseiller « reprend le barème du site […] mais sans hasard : le même état donne toujours les mêmes conseils, et chaque conseil dit pourquoi ». Test : « est déterministe ».
- **Alternatives considered**: dupliquer le barème dans le conseiller : écarté implicitement par le partage du code.

## 6. Seuils des « manques » d'une équipe

- **Decision**: une équipe manque de dégâts magiques (ou physiques) quand leur part est sous `TeamAnalyzer.minDamageShare` (20 %) pour le bilan, sous 30 % (`minDamageShare + 0,1`) pour décider qu'un candidat comble le manque, et le candidat doit avoir une note d'au moins 6 sur 10 dans ce type. La première ligne est un champion « Tank » ou à défense d'au moins 7.
- **Rationale**: valeurs de `team_analyzer.dart` réutilisées pour ne pas diverger de l'outil « Composition » ; la marge de 0,1 n'a pas de commentaire : sans trace de pourquoi.
- **Alternatives considered**: non documentées.

## 7. Comparaison par critères gagnés, tolérances

- **Decision**: cinq critères, chacun vaut 1 point (nul : un demi-point chacun) ; le verdict est un nul quand l'écart est inférieur à `tieScoreGap = 0,5`. Tolérances : équilibre des dégâts 0,05 (`balanceTolerance`), première ligne 0,5, contrôle 1 sort, voies 1 voie, taux de victoire moyen 0,01 (`winRateTolerance`). Voie gagnée à 53 % et plus (`laneWinThreshold`), perdue à 47 % et moins (`laneLossThreshold`).
- **Rationale**: commentaires : « entre les deux seuils, le duel est trop serré pour désigner quelqu'un » ; « Écart de répartition des dégâts en dessous duquel deux équilibres sont considérés comme équivalents ». Tests : « un duel serré ne désigne personne », « deux drafts identiques sont jugées équivalentes ». Le choix précis de ces seuils n'est pas expliqué.
- **Alternatives considered**: pondération des critères : aucune trace ; tous pèsent autant.

## 8. Conseil de voie perdue : le meilleur contre libre, sans parties douteuses

- **Decision**: pour une voie perdue, `_LaneResult.suggestion` cherche via `CounterService.counters(adversaire, lane:, includeLowConfidence: false)` le premier champion encore libre dont le taux dépasse 50 % ; sinon « Essayez un autre choix à ce poste ».
- **Rationale**: le commit `0b3b86d` ajoute `includeLowConfidence: false` (« le repli sur les bilans peu fiables donne toujours des propositions » côté contre-picks, spec 010) : la draft ne doit pas conseiller sur des bilans peu fiables. Tests : « conseille un contre-pick libre pour une voie perdue », « ne conseille pas un champion déjà pris dans la draft ».
- **Alternatives considered**: garder le repli peu fiable : écarté par ce commit.

## 9. Bannissements : seuils de jugement

- **Decision**: ban « utile » si le champion est fiable (100 parties et plus) et gagne 52 % et plus (`strongWinRate`) ; « peu utile » si fiable et sous 50 % (`weakWinRate`) ; au plus deux « manqués » par camp (`maxMissed`), triés du plus fort au moins fort, uniquement les champions de l'adversaire que personne n'a bannis.
- **Rationale**: commentaire : « au-delà, la liste noie l'essentiel ». Tests : « ne juge pas un champion trop peu joué », « ne reproche pas un champion que l'adversaire a banni lui-même », « limite les bannissements manqués signalés ».
- **Alternatives considered**: non documentées. Contre le site, les remarques sur les bans du site sont supprimées : « le bilan s'adresse au joueur : les bannissements du site ne l'intéressent pas » (commentaire de `draft_evaluator.dart`).

## 10. Le site joue après une attente, annulable

- **Decision**: attente de 900 ms avant chaque coup du site, et un compteur `generation` incrémenté par « Recommencer » : un tour lancé avant le redémarrage est ignoré à son retour.
- **Rationale**: commentaires : « sans lui, la draft se déroulerait d'un seul coup et on ne verrait pas qui choisit quoi » ; « Un tour du site lancé avant un "Recommencer" ne doit pas s'appliquer à la nouvelle partie ». Le délai est injectable (`botThinkingDelay`) pour les tests.
- **Alternatives considered**: annuler un `Timer` : non évoqué.

## 11. Aide au choix : un champion, son meilleur rôle

- **Decision**: `DraftAdvisor.suggest` évalue chaque champion libre pour chaque rôle libre mais ne garde que son meilleur rôle ; tri par score puis par index de rôle puis identifiant ; trois conseils par défaut, jamais pendant les bans ni quand la draft est finie ; 1 à 3 raisons par conseil, seulement des raisons positives (duel au-dessus de 50 %, taux au-dessus de 50 %, manques comblés), sinon « Se joue régulièrement à ce poste. ».
- **Rationale**: commentaire : « sinon le même nom reviendrait trois fois, une par poste libre » ; l'ordre de repli rend le tri stable. Test : « ne cite pas un duel trop peu joué » (un duel sous 8 parties n'est pas cité).
- **Alternatives considered**: non documentées.

## 12. Bannir : n'importe quel champion, filtre de rôle sans imposer de rôle

- **Decision**: la feuille de bannissement ouvre le filtre de rôle sans rôle initial ; celle d'un choix s'ouvre sur le rôle de la case touchée.
- **Rationale**: commentaire de `_roleFilter` : « Pour un choix, il démarre sur le rôle de la case touchée ; pour un bannissement, aucun rôle n'est imposé ». Le filtre lui-même est la spécification 018.
- **Alternatives considered**: non documentées.

## 13. Vainqueur dit en toutes lettres

- **Decision**: chaque critère affiche « Avantage à vous / au site / Égalité », en plus de l'icône et de la couleur.
- **Rationale**: commentaire de `CriterionTile` : « Le vainqueur est dit en toutes lettres, pas seulement par la couleur ». Cohérent avec le chantier d'accessibilité (`docs/agents/reports/a11y-audit.md`).
- **Alternatives considered**: couleur seule : écartée par ce commentaire.
