# Data Model: Quiz : chrono, historique des séries et duels

## QuizCategory (`lib/quiz/models/quiz_question.dart`)

| Valeur | Libellé affiché |
|--------|-----------------|
| `champions` | Champions |
| `regions` | Régions |
| `items` | Objets |
| `matchups` | Duels |

## QuizQuestion

| Champ | Type | Règle |
|-------|------|-------|
| `category` | `QuizCategory` | famille de la question |
| `prompt` | `String` | énoncé ; sans pourcentage pour les duels |
| `imageUrl` | `String?` | illustration de la question (ex. la cible d'un « contre X ») |
| `options` | `List<QuizOptionData>` | 2 à 4 propositions (2 pour un face-à-face, 3 à 4 pour un « contre X ») ; sans doublon de champion |
| `answerIndex` | `int` | indice de la bonne réponse dans `options` (propositions mélangées) |
| `explanation` | `String?` | « <A> gagne N % de ses duels contre <B> (M parties). » pour les duels |

`QuizOptionData` : `label`, `imageUrl?`.

## Matchup (existant, `lib/matchups/models/matchup.dart`)

`championId`, `opponentId`, `lane`, `games`, `wins` ; `winRate = wins / games` (0 si `games == 0`).

**Seuils appliqués par le quiz**

| Règle | Valeur |
|-------|--------|
| Parties minimum | `MatchupService.minGames` = 8 |
| Écart net (`DuelQuestionBuilder.minGap`) | 0,06 |
| Propositions d'un « meilleur contre X » | 3 à 4 |
| Propositions d'un face-à-face | 2 |

Une confrontation est écartée si `championId == opponentId`, si la voie n'est pas dans `laneLabels` (TOP, JUNGLE, MIDDLE, BOTTOM, UTILITY), ou si l'un des champions n'est pas dans la liste chargée.

## Persistance (`shared_preferences`)

| Clé | Type | Contenu |
|-----|------|---------|
| `quiz_best_streak` | entier | meilleure série de bonnes réponses |
| `quiz_recent_streaks` | liste de chaînes | séries terminées, la plus récente en premier, 8 au plus, chaque valeur > 0 |

Lecture : les valeurs non numériques sont ignorées. Écriture : file séquentielle ; une erreur n'interrompt pas les suivantes.

## État de l'écran (non persistant)

| État | Valeur initiale | Rôle |
|------|-----------------|------|
| `isTimed` | faux | chrono actif |
| `secondsLeft` | 15 | temps restant |
| `chosenIndex` | `null` | `-1` = temps écoulé ; sinon indice choisi |
| `timedOut` | faux | affiche « Temps écoulé : … » |
| `streak`, `correct`, `answered` | 0 | score de la session |
| `availableCategories` | toutes puis calculé au chargement | familles affichées |

## Transitions d'une question

```text
tirée ──(chrono actif)──> en attente ──réponse juste──> répondue (série +1, record éventuel)
                              │──réponse fausse──────> répondue (série → 0, série terminée enregistrée)
                              └──15 s écoulées───────> répondue, timedOut (même effet qu'une fausse réponse)
répondue ──« Suivante »──> tirée
```
