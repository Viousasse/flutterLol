# Feature Specification: Historique, partage et import des drafts

**Feature Branch**: `017-historique-partage-et-import-des-drafts` (travail livré sur `main`)

**Created**: 2026-10-05 (commit `57ca610`, puis `0afb3b1` pour la page de détail, le code de partage et l'import)

**Status**: Implemented

**Input**: User description : « fais le 1 et 2 et 3 » (réponse à une liste de pistes dont les trois premières étaient les bannissements, l'historique des drafts et le partage), puis, au choix suivant, « Historique des drafts », « Rejouer » et « Partage plus riche ». Cette spécification couvre l'historique, la page de détail, le rejeu avec les mêmes bannissements, le partage en texte et par code, et l'import d'un code reçu. Les bannissements eux-mêmes sont dans le même commit mais hors de ce dossier : seul leur effet sur l'historique (bannis conservés, rejouables) est décrit ici.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Retrouver mes drafts jouées et mon bilan (Priority: P1)

Chaque draft jugée (contre le site ou à deux) est gardée automatiquement. Une page « Historique des drafts » les liste, la plus récente en premier, avec un bilan en tête : nombre de drafts, victoires / égalités / défaites contre le site, champions les plus choisis. On peut supprimer une draft ou vider tout l'historique après confirmation.

**Why this priority**: sans historique il n'y a rien à rejouer, partager ni importer. C'est le socle des trois autres parcours.

**Independent Test**: jouer une draft jusqu'au verdict, ouvrir l'historique depuis l'icône horloge de la page de draft ou depuis la page Composition : la draft y figure sans autre action.

**Acceptance Scenarios**:

1. **Given** une draft qui vient d'être jugée, **When** j'ouvre l'historique, **Then** elle est en tête avec les deux noms, le vainqueur, la date et les dix champions.
2. **Given** un historique vide, **When** j'ouvre la page, **Then** un message m'invite à jouer une draft et aucune action « Vider » n'est proposée.
3. **Given** une draft listée, **When** je touche « Supprimer cette draft » et je confirme, **Then** elle disparaît ; si j'annule, elle reste.
4. **Given** plusieurs drafts, **When** je touche « Vider l'historique » et je confirme, **Then** la liste est vide.
5. **Given** que l'application est relancée, **When** j'ouvre l'historique, **Then** les drafts sont toujours là.

---

### User Story 2 - Voir le détail d'une draft et la rejouer (Priority: P2)

Toucher une draft ouvre sa page de détail : les deux équipes rôle par rôle, les bannis, le score, le verdict. Depuis cette page je peux copier un résumé ou rejouer la draft avec les mêmes bannissements.

**Why this priority**: c'est la valeur ajoutée visible de l'historique (« Rejouer »), mais elle suppose que l'historique existe.

**Independent Test**: ouvrir une draft de l'historique, appuyer sur « Rejouer avec les mêmes bannissements » : la draft démarre avec les cases de bannissement déjà remplies et aucune phase de bannissement.

**Acceptance Scenarios**:

1. **Given** une draft de l'historique, **When** je la touche, **Then** la page de détail montre l'en-tête (« A contre B », résultat, date), le score, les deux équipes et le verdict.
2. **Given** la page de détail, **When** je touche « Copier le résumé », **Then** le résumé est dans le presse-papiers et un message le confirme.
3. **Given** une draft avec dix bannis, **When** je la rejoue, **Then** les dix bannis sont posés, la phase de choix commence au « choix 1 sur 10 » et l'interrupteur des bannissements est masqué.
4. **Given** une draft à deux, **When** je la rejoue, **Then** le mode « Draft à deux » et les deux noms sont repris.
5. **Given** une draft rejouée et terminée, **When** je touche « Refaire une draft », **Then** les mêmes bannissements sont conservés.

---

### User Story 3 - Partager une draft par texte et par code (Priority: P2)

Depuis une tuile de l'historique, la page de détail ou le bilan de la draft, je copie un texte lisible (équipes, bannis, score, vainqueur, verdict) qui se termine par une ligne « Code : LOLD1… ». Mon ami peut lire le texte comme un message ordinaire.

**Why this priority**: c'est la demande « partage plus riche » ; elle n'a de sens qu'avec l'historique, et alimente le parcours d'import.

**Independent Test**: copier le résumé d'une draft : le texte contient les équipes et la dernière ligne « Code : LOLD1.… ».

**Acceptance Scenarios**:

1. **Given** une draft avec bannis, **When** je copie le résumé, **Then** chaque équipe liste ses cinq rôles et une ligne « Bannis : … ».
2. **Given** une draft sans bannissements, **When** je copie le résumé, **Then** aucune ligne « Bannis » n'apparaît.
3. **Given** un rôle resté vide, **When** je copie le résumé, **Then** il est écrit « — ».
4. **Given** deux drafts de même score, **When** je copie le résumé, **Then** il dit « Les deux drafts se valent. ».
5. **Given** un appareil qui refuse la copie, **When** je copie, **Then** le message « Copie impossible sur cet appareil » s'affiche au lieu d'un faux succès.

---

### User Story 4 - Importer la draft d'un ami (Priority: P3)

Dans l'historique, l'action « Importer une draft » ouvre une boîte où je colle le message reçu (ou le seul code). La draft rejoint mon historique, marquée « importée ».

**Why this priority**: complète le partage, mais seulement utile quand quelqu'un a déjà partagé.

**Independent Test**: coller dans la boîte d'import le texte produit par « Copier le résumé » d'une autre draft : « Draft importée » s'affiche et la tuile porte « IMPORTÉE ».

**Acceptance Scenarios**:

1. **Given** un message entier contenant un code `LOLD1.`, **When** je le colle et valide, **Then** la draft est ajoutée en tête, avec l'étiquette « IMPORTÉE », et « Draft importée » s'affiche.
2. **Given** un texte sans code valide, **When** je valide, **Then** la boîte reste ouverte et affiche « Ce texte ne contient pas de code de draft valide. » sans perdre ce que j'ai collé.
3. **Given** une draft déjà présente (mêmes équipes, mêmes bannis, même date), **When** je l'importe de nouveau, **Then** « Cette draft est déjà dans votre historique. » s'affiche et rien n'est ajouté.
4. **Given** le bouton « Coller », **When** le presse-papiers contient du texte, **Then** il remplit le champ ; s'il est indisponible, je peux coller à la main.

---

### User Story 5 - Un bilan qui reste honnête (Priority: P3)

Le taux de victoire contre le site ne compte que les drafts jouées seul, par moi. Les drafts jouées avec l'aide des conseils et les drafts importées figurent dans le total et dans les champions les plus choisis (selon le mode), mais pas dans le taux, et le bilan le dit.

**Why this priority**: évite un bilan trompeur, sans bloquer les parcours précédents.

**Independent Test**: construire un historique mêlant drafts seules, avec aide, importées et à deux : le taux ne change qu'avec les drafts seules.

**Acceptance Scenarios**:

1. **Given** deux victoires et une défaite contre le site, **When** j'ouvre l'historique, **Then** le bilan affiche les trois chiffres et le pourcentage arrondi.
2. **Given** une draft avec aide, **When** j'ouvre l'historique, **Then** elle porte « AVEC AIDE » et le bilan indique « dont N avec aide (non comptées dans le taux) ».
3. **Given** une draft importée, **When** j'ouvre l'historique, **Then** le bilan indique « dont N importée(s) (non comptées dans le taux) ».
4. **Given** uniquement des drafts à deux, **When** j'ouvre l'historique, **Then** « Aucune draft contre le site » remplace le taux.

---

### Edge Cases

- Une entrée enregistrée illisible est écartée sans perdre le reste de l'historique (`test/draft/draft_history_test.dart`, « une entrée illisible est écartée »).
- Une ancienne draft sans les marqueurs « avec aide » / « importée » se relit comme jouée seul et non importée.
- Au-delà de 50 drafts, les plus anciennes sont oubliées.
- Un champion absent de la liste actuelle (retiré du jeu) s'affiche sans image dans l'historique ; son nom reste lisible parce que la draft garde les noms.
- Un champion banni introuvable au rejeu : les bans sont posés dans l'ordre jusqu'au premier introuvable, puis la phase de bannissement reprend pour les cases restantes (`draft_page_replay_test.dart`).
- Une draft à deux n'attribue aucune victoire au joueur ; une draft rejouée à deux garde les noms d'origine et ne compte pas dans le score de la soirée.
- Un code tronqué, abîmé, au mauvais préfixe, avec un JSON invalide, des équipes qui n'ont pas cinq rôles, des noms vides ou trop longs, un verdict trop long ou trop de bannis est refusé (`draft_share_code_test.dart`).
- Un message contenant plusieurs codes : le premier lisible est retenu, un code abîmé est sauté.
- Importer deux fois de suite deux codes ne donne jamais le même identifiant.
- Le chargement de la liste des champions échoue : l'historique affiche un message d'erreur avec « Réessayer » et l'action d'import est désactivée.
- Un stockage indisponible : l'historique démarre vide plutôt que de planter ; une écriture échouée ne perd pas la liste en mémoire.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT enregistrer automatiquement chaque draft dès que son bilan est établi, sans demande au joueur, contre le site comme à deux.
- **FR-002**: Le système DOIT conserver pour chaque draft : date, mode (site ou à deux), noms des deux camps, les cinq choix de chaque équipe dans l'ordre des rôles, les bannissements, le nom de chaque champion, le vainqueur, les deux scores et le verdict.
- **FR-003**: Le système DOIT garder l'historique entre deux lancements et ne pas dépasser 50 drafts, en oubliant les plus anciennes.
- **FR-004**: Le système DOIT lister les drafts de la plus récente à la plus ancienne et se mettre à jour sans rechargement quand une draft est ajoutée ou supprimée.
- **FR-005**: Le système DOIT afficher en tête de liste un bilan : nombre de drafts, victoires, égalités et défaites contre le site avec le pourcentage, et les cinq champions les plus choisis.
- **FR-006**: Le système DOIT exclure du taux de victoire les drafts à deux, les drafts jouées avec aide et les drafts importées, tout en les comptant dans le total, et DOIT le signaler dans le bilan.
- **FR-007**: Contre le site, le système DOIT ne compter pour les champions les plus choisis que les choix du joueur ; à deux, il DOIT compter ceux des deux joueurs.
- **FR-008**: Le système DOIT permettre de supprimer une draft et de vider l'historique, chacun après une confirmation explicite.
- **FR-009**: Le système DOIT afficher le détail d'une draft (équipes, bannis, résultat, score, verdict, mention « jouée avec aide ») en lecture seule.
- **FR-010**: Le système DOIT permettre de rejouer une draft avec les mêmes bannissements, en reprenant son mode et ses noms, avec des choix repartant de zéro, et DOIT enregistrer la draft rejouée comme une nouvelle entrée.
- **FR-011**: Le système DOIT produire un résumé texte d'une draft (équipes, bannis s'il y en a, score, vainqueur, verdict) se terminant par une ligne « Code : » suivie du code de partage.
- **FR-012**: Le système DOIT permettre de copier ce résumé depuis la tuile, la page de détail et le bilan de la draft, et DOIT dire si la copie a échoué.
- **FR-013**: Le système DOIT produire un code de partage d'une draft, identifié par le préfixe `LOLD1.`, qui contient tout ce qu'il faut pour la restituer (FR-002 et marqueur « avec aide »).
- **FR-014**: Le système DOIT retrouver un code dans un texte quelconque collé, ignorer les codes illisibles et accepter qu'un code soit noyé dans un message.
- **FR-015**: Le système DOIT refuser un code dont le contenu est invalide ou hors bornes (équipes de taille différente de cinq, noms vides ou de plus de 40 caractères, verdict de plus de 300 caractères, plus de 10 bannis par camp, scores absents).
- **FR-016**: Le système DOIT, à l'import, attribuer un nouvel identifiant, conserver la date de la partie d'origine et marquer la draft « importée ».
- **FR-017**: Le système DOIT refuser d'ajouter une draft déjà présente (mêmes équipes, mêmes bannis, même date) et le dire.
- **FR-018**: La boîte d'import DOIT rester ouverte, avec un message, tant que le texte n'est pas compris, et proposer un bouton « Coller » lisant le presse-papiers.
- **FR-019**: Le système DOIT tolérer une entrée enregistrée corrompue ou un stockage indisponible sans perdre le reste de l'historique ni planter.
- **FR-020**: Le système DOIT rendre chaque tuile lisible par un lecteur d'écran en un seul libellé (noms, résultat, date, « jouée avec aide », « importée ») et nommer les boutons Partager et Supprimer.
- **FR-021**: L'historique DOIT être accessible depuis la page de draft et depuis la page Composition.

### Key Entities

- **Draft enregistrée** : une draft terminée et son bilan ; porte les noms des champions pour se lire sans recharger la liste ; marquée « avec aide » et/ou « importée ».
- **Historique** : la liste ordonnée (50 au plus) des drafts enregistrées, persistante.
- **Statistiques d'historique** : total, nombre contre le site, victoires/égalités/défaites, champions les plus choisis, nombre avec aide, nombre importées.
- **Code de partage** : texte compact préfixé `LOLD1.` qui encode une draft ; contrat dans `contracts/`.
- **Résumé de partage** : texte lisible se terminant par le code.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Une draft jugée apparaît dans l'historique en une action (ouvrir la page), sans geste de sauvegarde, et y reste après relance.
- **SC-002**: Pour 100 % des drafts valides, importer le code produit par « Copier le résumé » redonne une draft aux équipes, bannis, scores, vainqueur et verdict identiques.
- **SC-003**: Pour 100 % des textes sans code `LOLD1.` valide, l'import refuse et laisse la boîte ouverte avec un message.
- **SC-004**: Le taux de victoire affiché est identique avant et après ajout d'une draft avec aide, d'une draft importée ou d'une draft à deux.
- **SC-005**: Rejouer une draft de 10 bannis donne un écran où les 10 bannis sont posés et où le premier choix est proposé sans autre action.
- **SC-006**: Une entrée corrompue sur N laisse N-1 drafts lisibles.

## Assumptions et limites connues

- **Hypothèses** : l'identité du joueur contre le site est le camp bleu ; l'historique est local à l'appareil (aucun compte, aucun serveur).
- **Écart avec la constitution (principe VII)** : la boîte d'import, les messages « Cette draft est déjà dans votre historique. », « Collez le code… » et la page vide (« Jouez-en une ») vouvoient l'utilisateur, alors que la constitution demande de le tutoyer. Voir `plan.md`, Complexity Tracking.
- **Limite** : le code n'est pas signé ni chiffré ; il est lisible par quiconque (JSON en base64 « URL-safe »). Il n'y a pas de contrôle d'intégrité : un code modifié à la main mais dans les bornes est accepté.
- **Limite** : la détection de doublon ne compare pas les scores, le verdict ni les noms : deux drafts qui ne diffèrent que par ceux-ci sont considérées identiques.
- **Limite** : au rejeu, un champion du code non retrouvé dans la liste actuelle interrompt la pose des bans (voir cas limites).
- **Dépendance** : le moteur de bilan (`DraftEvaluator`) et la page de draft appartiennent à d'autres fonctionnalités ; cette fonctionnalité les consomme.
