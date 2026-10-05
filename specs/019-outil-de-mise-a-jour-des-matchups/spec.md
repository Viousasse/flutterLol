# Feature Specification: Outil de mise à jour des matchups

**Feature Branch**: `019-outil-de-mise-a-jour-des-matchups` (travail livré sur `main`)

**Created**: 2026-09-16 (premier calcul réel : commits `6436bbb` et `d26e563` ; durcissement de l'outil : `0b3b86d` et `0afb3b1` ; régénération : `55b4700`)

**Status**: Implemented

**Input**: User description : « RGAPI-... voicie la cle api de riot fais ce que tu a faire » (la clé réelle fournie dans la conversation n'est reproduite nulle part ; elle n'a été utilisée que comme variable d'environnement pour la commande), puis « telecharge plus de donner » (télécharger plus de parties pour avoir des données plus fiables). Contexte : l'API Riot n'offre pas d'endpoint de « contre-picks » ; l'application les calcule hors ligne à partir de vraies parties classées et embarque le résultat.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Générer le fichier de matchups à partir de parties classées (Priority: P1)

Le mainteneur lance une commande avec sa clé de développement Riot (passée uniquement par une variable d'environnement). L'outil lit des parties classées solo/duo de joueurs Master, compte pour chaque voie qui a gagné contre qui, et écrit un fichier de données (champion, adversaire, voie, parties, victoires) avec un en-tête (patch, plateforme, rang, nombre de parties).

**Why this priority**: sans ce fichier, la fiche champion, les contre-picks, les points forts, le quiz « Duels » et le conseiller de draft n'ont aucune donnée.

**Independent Test**: lancer l'outil avec une clé valide et un petit nombre de parties (`--matches 400`) : le fichier de sortie existe et contient les paires et l'en-tête.

**Acceptance Scenarios**:

1. **Given** une clé valide dans `RIOT_API_KEY`, **When** je lance l'outil, **Then** il écrit le fichier avec `generatedAt`, `patch`, `platform`, `rank`, `matches`, `matchups`.
2. **Given** l'absence de la variable `RIOT_API_KEY`, **When** je lance l'outil, **Then** il s'arrête avec un message clair et un code d'erreur, sans rien écrire.
3. **Given** la limite d'une clé de développement (100 requêtes par 2 minutes), **When** l'outil tourne longtemps, **Then** il fait ses pauses seul et attend après une réponse « trop de requêtes ».
4. **Given** le nom de champion « FiddleSticks » dans les parties, **When** l'outil compte, **Then** il l'écrit « Fiddlesticks », comme les données de l'application.

---

### User Story 2 - Reprendre un long calcul interrompu (Priority: P1)

Un calcul de plusieurs heures peut être interrompu (coupure, clé expirée, partie supprimée). Le mainteneur relance la même commande avec `--resume` : les parties déjà traitées ne sont pas recomptées.

**Why this priority**: sans reprise, une interruption à 90 % fait tout perdre ; c'est ce qui rend viables les 7 600 parties.

**Independent Test**: interrompre l'outil, le relancer avec `--resume` : il indique le nombre de parties déjà traitées et reprend.

**Acceptance Scenarios**:

1. **Given** un calcul interrompu, **When** je relance avec `--resume` et le même `--output`, **Then** les parties déjà traitées sont ignorées.
2. **Given** une partie supprimée par Riot (HTTP 404), **When** l'outil la rencontre, **Then** il l'ignore et continue.
3. **Given** une clé expirée ou refusée, **When** l'outil reçoit une autre erreur HTTP, **Then** il sauvegarde la progression puis s'arrête avec l'erreur.
4. **Given** une coupure en pleine sauvegarde, **When** je reprends, **Then** la sauvegarde n'est jamais à moitié écrite.

---

### User Story 3 - Mettre à jour pour un nouveau patch sans tout refaire (Priority: P2)

Le mainteneur additionne les nouvelles parties au fichier existant, en faisant « vieillir » l'existant (`--decay`) et en ignorant les parties de patchs trop anciens (`--min-patch`).

**Why this priority**: évite de refaire des heures de calcul à chaque patch et garde les données pertinentes.

**Independent Test**: tests de `test/tool/matchup_tally_test.dart` sur le vieillissement, la comparaison de patchs et la fusion.

**Acceptance Scenarios**:

1. **Given** `--merge-with <fichier>`, **When** l'outil écrit, **Then** les bilans de ce fichier sont additionnés aux nouveaux.
2. **Given** `--decay 0.5`, **When** l'existant est fusionné, **Then** ses parties et victoires sont multipliées par 0,5 avant addition, arrondies, sans que les victoires dépassent les parties, et une paire tombée à 0 partie disparaît.
3. **Given** `--min-patch 16.20`, **When** l'outil lit une partie du patch 16.9 ou 16.19, **Then** elle est ignorée (comparaison numérique : 16.9 précède 16.10) mais comptée comme traitée.
4. **Given** un fichier mêlant plusieurs patchs, **When** l'outil écrit l'en-tête, **Then** `patch` est une plage (« 16.16–16.19 ») et un champ informatif `patches` donne les parties par patch.
5. **Given** `--decay` hors de 0..1 ou `--min-patch` illisible, **When** je lance l'outil, **Then** il refuse avec un message.

---

### User Story 4 - Embarquer des données plus fiables (Priority: P2)

Le fichier embarqué passe de 2 500 parties (patch 16.18) à 7 600 parties (patchs 16.16 à 16.19), de façon que presque tous les champions aient des contre-picks fiables.

**Why this priority**: c'est la demande « télécharge plus de données » : plus de parties = moins de paires tues faute de 8 parties.

**Independent Test**: `flutter test test/counters/counter_service_test.dart` : chaque champion des vraies données reçoit des contre-picks et des points forts.

**Acceptance Scenarios**:

1. **Given** le fichier embarqué, **When** l'application charge les matchups, **Then** l'en-tête indique 7 600 parties et la plage de patchs, et la note « d'où viennent les données » l'affiche telle quelle.
2. **Given** le fichier embarqué, **When** on cherche les contre-picks de chaque champion, **Then** tous en reçoivent (test sur le vrai fichier).
3. **Given** un fichier sans champ `patches`, **When** l'application le lit, **Then** il se lit sans erreur.

---

### Edge Cases

- Une partie qui n'est pas en solo/duo classé (file 420) est ignorée.
- Une voie où deux joueurs d'une même équipe ou un nombre de joueurs différent de deux sont repérés est ignorée ; une partie sans aucune voie exploitable n'est pas comptée comme exploitée.
- Un patch illisible n'est jamais écarté par `--min-patch` (« mieux vaut garder une partie que la perdre à tort ») ; en tri, un patch illisible est le plus ancien.
- Une paire de patchs identiques reste un seul patch (pas de plage).
- Écrire dans un `--output` hors de `assets/` évite de remplacer les données de l'application avant la fin du calcul.
- Une clé de développement vit 24 h : l'outil s'arrête avec l'erreur au lieu de boucler.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: L'outil DOIT lire la clé Riot uniquement dans la variable d'environnement `RIOT_API_KEY` et s'arrêter avec un code d'erreur si elle est absente.
- **FR-002**: Aucune clé Riot ne DOIT figurer dans le code, la documentation, les données ou l'historique du dépôt ; la documentation utilise un exemple `RGAPI-...`.
- **FR-003**: L'outil DOIT échantillonner des joueurs du classement Master d'une plateforme (défaut `euw1`), lire leurs parties classées solo/duo et compter, pour chaque voie (Top, Jungle, Milieu, Bot, Support), parties et victoires de chaque champion contre son vis-à-vis.
- **FR-004**: L'outil DOIT respecter la limite de 100 requêtes par 2 minutes d'une clé de développement et attendre le délai indiqué après une réponse 429.
- **FR-005**: L'outil DOIT aligner les noms de champions sur les identifiants Data Dragon (« FiddleSticks » devient « Fiddlesticks »).
- **FR-006**: L'outil DOIT écrire un fichier JSON avec `generatedAt`, `patch`, `platform`, `rank` (`MASTER+`), `matches`, `patches` (informatif) et `matchups` triés par nombre de parties décroissant.
- **FR-007**: L'outil DOIT permettre d'écrire ailleurs que dans les données de l'application (`--output`).
- **FR-008**: L'outil DOIT sauvegarder sa progression toutes les 100 parties dans un fichier voisin, par écriture atomique, et permettre de reprendre (`--resume`) sans recompter les parties déjà traitées.
- **FR-009**: L'outil DOIT ignorer une partie supprimée (404) et DOIT, pour toute autre erreur HTTP, sauvegarder puis s'arrêter.
- **FR-010**: L'outil DOIT permettre d'additionner un fichier existant (`--merge-with`), avec un facteur de vieillissement (`--decay`, 0 à 1, défaut 1) appliqué aux parties, aux victoires, au total de parties et au décompte par patch avant l'addition.
- **FR-011**: Le vieillissement DOIT arrondir à l'entier, borner les victoires aux parties et retirer les paires à 0 partie.
- **FR-012**: L'outil DOIT permettre d'ignorer les parties d'un patch antérieur à un seuil (`--min-patch`), avec une comparaison numérique des patchs, tout en les marquant comme traitées.
- **FR-013**: L'étiquette `patch` DOIT être un patch seul si toutes les parties en viennent, sinon une plage « ancien–récent » qui intègre aussi la plage déjà présente dans le fichier fusionné.
- **FR-014**: L'application DOIT lire le fichier sans recalcul au lancement et DOIT tolérer l'absence du champ `patches` ; elle DOIT taire les paires de moins de 8 parties.
- **FR-015**: Le fichier embarqué DOIT être déclaré comme ressource de l'application et DOIT permettre de donner des contre-picks et des points forts à tous les champions qui y figurent.
- **FR-016**: Un guide DOIT décrire les prérequis, la régénération complète, la mise à jour par patch, la reprise, l'installation du fichier, la vérification de couverture et le format.

### Key Entities

- **Bilan de paire** : parties et victoires d'un champion contre un adversaire dans une voie.
- **Fichier de matchups** : en-tête (patch ou plage, plateforme, rang, nombre de parties, parties par patch) et liste de bilans.
- **Progression** : bilans déjà comptés, identifiants de parties traitées, nombre de parties exploitées, parties par patch.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Le fichier embarqué repose sur 7 600 parties (contre 2 500 au premier calcul) et couvre 168 champions sur 173 avec des contre-picks fiables (chiffre du message du commit `55b4700`).
- **SC-002**: Une interruption à n'importe quel moment ne fait perdre au plus que les parties traitées depuis la dernière sauvegarde (moins de 100).
- **SC-003**: Aucune occurrence de clé Riot réelle dans le dépôt (vérifiable par recherche du préfixe `RGAPI-` : seuls des exemples `RGAPI-...` existent).
- **SC-004**: 100 % des champions des vraies données reçoivent des contre-picks et des points forts (tests `counter_service_test.dart`).
- **SC-005**: Le vieillissement ne produit jamais plus de victoires que de parties (test dédié).

## Assumptions et limites connues

- La plateforme par défaut est `euw1` (Master+ EUW) ; l'option `--platform` existe, mais seul `euw1` a été utilisé pour les données embarquées.
- Les données sont un échantillon de joueurs Master mélangeant trois patchs ; elles ne reflètent pas un seul patch du jeu.
- **Écart** : le fichier embarqué, régénéré dans `55b4700`, ne contient pas le champ `patches` (ajouté ensuite à l'outil dans `0afb3b1`) ; il se lit normalement.
- **Limite** : l'outil n'a pas de test d'intégration : seule la logique pure (`tool/matchup_tally.dart`) est testée ; les appels Riot, la reprise et l'écriture du fichier ne le sont pas.
- **Limite** : la génération de 7 600 parties prend des heures avec une clé de développement (environ 1 h pour 3 000 parties selon le guide) ; elle est manuelle.
- **Limite** : l'outil ne lit que les 30 dernières parties de chaque joueur échantillonné (`count=30`).
- Les spécifications ne contiennent pas la clé fournie par l'utilisateur ; sa seule trace est ce paragraphe `Input`, sous forme d'exemple.
