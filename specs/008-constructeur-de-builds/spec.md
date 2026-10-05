# Feature Specification: Constructeur de builds, partage et import par code

**Feature Branch**: `008-constructeur-de-builds` (travail livré sur `main`, sans branche dédiée)

**Created**: 2026-10-05

**Status**: Implemented

**Input**: User description: « fais les deux » (apparences et constructeur de build, commit `c86ea71`) ; puis « * Constructeur de build ... c'est ou ca » (où le trouver : l'entrée « Mes builds » a été ajoutée à l'onglet Outils, commit `a4475d7`, en plus du bouton de l'onglet Objets) ; puis, au fil des idées, partager une build (commits `57ca610` : résumé à copier ; `0afb3b1` : code de partage `LOLB1.` et import par code), plus le filtre de rôle dans le choix du champion d'une build (commit `23ea5c6` et suivants).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Composer et enregistrer une build (Priority: P1)

Le joueur ouvre « Mes builds » (onglet Outils, ou bouton « Builds » de l'onglet Objets), appuie sur « Nouvelle build », donne un nom, choisit facultativement un champion, remplit jusqu'à six emplacements d'objets, voit le prix total et les bonus cumulés, puis enregistre.

**Why this priority**: c'est le cœur de la demande ; sans lui rien d'autre n'a de sens.

**Independent Test**: créer une build de deux objets, la retrouver dans la liste après un redémarrage.

**Acceptance Scenarios**:

1. **Given** l'éditeur ouvert, **When** aucun objet n'est choisi, **Then** « Enregistrer la build » est désactivé.
2. **Given** des objets choisis, **When** le joueur les place, **Then** le prix total (somme des prix des objets) et les bonus cumulés non nuls (dégâts, puissance, vitesse d'attaque, critique, vol de vie, vie, armure, résistance magique, mana, régénération, vitesse de déplacement) s'affichent et se mettent à jour ; les pourcentages sont affichés en pourcentage.
3. **Given** un nom vide, **When** il enregistre, **Then** la build s'appelle « Ma build » ; le nom est limité à 40 caractères.
4. **Given** une build enregistrée, **When** le joueur relance l'application, **Then** elle est toujours là, dans le même ordre d'objets, avec son champion.
5. **Given** un emplacement rempli, **When** le joueur le vide ou le remplace, **Then** seul cet emplacement change ; un champion choisi peut être retiré.

---

### User Story 2 - Gérer la liste de ses builds (Priority: P1)

La liste « Mes builds » montre chaque build (nom, champion et prix, vignettes d'objets). Un appui ouvre l'éditeur, une poubelle propose la suppression après confirmation. Les plus récemment enregistrées passent en tête.

**Why this priority**: sans liste, on ne retrouve ni ne modifie rien.

**Independent Test**: créer deux builds, modifier la plus ancienne, la supprimer.

**Acceptance Scenarios**:

1. **Given** aucune build, **When** la liste s'affiche, **Then** un message invite à en composer une.
2. **Given** une build, **When** le joueur appuie sur la poubelle, **Then** une confirmation « Supprimer cette build ? » propose « Annuler » et « Supprimer la build » ; seule la confirmation supprime.
3. **Given** une build modifiée et enregistrée, **When** il revient à la liste, **Then** elle est en tête et remplace l'ancienne version (pas de doublon).
4. **Given** un échec réseau au chargement des objets ou des champions, **When** la page s'ouvre, **Then** un message et « Réessayer » s'affichent ; pendant le chargement, ni « Nouvelle build » ni l'import ne sont proposés.
5. **Given** un objet retiré du jeu depuis, **When** une build qui le contient s'affiche, **Then** il est simplement absent des vignettes.

---

### User Story 3 - Partager une build (Priority: P2)

Un bouton de partage sur chaque build copie un résumé texte (titre, objets numérotés, total en or) qui se termine par une ligne « Code : LOLB1.… ».

**Why this priority**: né d'une idée en cours de route ; la liste fonctionne sans.

**Independent Test**: appuyer sur partager, coller le texte ailleurs.

**Acceptance Scenarios**:

1. **Given** une build avec champion, **When** le joueur la partage, **Then** le texte commence par « Build « nom » pour Champion » et l'application confirme « Résumé de la build copié ».
2. **Given** une build sans champion, **Then** le titre n'indique pas de champion ; **Given** une build sans objet, **Then** le texte dit « Aucun objet. ».
3. **Given** que la copie est refusée par l'appareil, **When** il partage, **Then** « Copie impossible sur cet appareil » s'affiche.

---

### User Story 4 - Importer une build par code (Priority: P2)

L'action « Importer une build » ouvre une boîte où l'on colle un code `LOLB1.…` ou tout le message reçu ; la build est enregistrée avec un nouvel identifiant et la liste se met à jour.

**Why this priority**: boucle le partage entre amis.

**Independent Test**: copier le résumé d'une build, l'importer.

**Acceptance Scenarios**:

1. **Given** un message qui contient un code valide, **When** le joueur l'importe, **Then** la build est enregistrée et « Build « nom » importée » s'affiche.
2. **Given** un texte sans code valide (tronqué, abîmé, JSON invalide, nom vide ou de plus de 60 caractères, plus de six objets), **When** il valide, **Then** la boîte reste ouverte avec le message « Ce texte ne contient pas de code de build valide. » ; le message disparaît dès qu'il retape.
3. **Given** deux codes dans un message dont le premier est abîmé, **When** il importe, **Then** le second est lu.
4. **Given** deux imports d'affilée, **When** ils sont enregistrés, **Then** les deux builds ont des identifiants différents.
5. **Given** le bouton « Coller », **When** le presse-papiers contient du texte, **Then** il remplit le champ ; s'il est indisponible, la saisie à la main reste possible.

---

### User Story 5 - Créer une build depuis les conseils d'un champion, et choisir le champion par rôle (Priority: P3)

Depuis la fiche d'un champion, « Créer une build avec ces objets » ouvre l'éditeur avec ce champion et ses objets conseillés. Dans l'éditeur, la feuille de choix du champion propose des puces de rôle quand les données de voies sont disponibles.

**Why this priority**: raccourcis qui ne changent pas le cœur du constructeur.

**Independent Test**: depuis une fiche avec objets conseillés, appuyer sur le lien ; dans l'éditeur, choisir un champion par rôle.

**Acceptance Scenarios**:

1. **Given** les objets conseillés d'un champion, **When** le joueur crée une build depuis la fiche, **Then** l'éditeur est prérempli (champion, objets) et rien n'est enregistré avant « Enregistrer la build ».
2. **Given** les données de voies indisponibles, **When** il choisit un champion, **Then** la feuille s'ouvre sans puces et la sélection reste possible.

---

### Edge Cases

- Une entrée enregistrée illisible ne fait pas perdre les autres builds (`tryFromJson` renvoie `null`, test dédié).
- Une build stockée ou importée ne dépasse jamais six objets (troncature à la lecture du stockage ; refus à l'import).
- Stockage indisponible : le magasin démarre vide au lieu de planter et pourra retenter.
- Écritures concurrentes : elles s'enchaînent sans se doubler, une écriture en échec ne rompt pas la suite.
- Champion enregistré qui n'existe plus dans les données : la build s'affiche sans nom de champion.
- Un objet dont on ne sait rien (disparu) dans les emplacements de l'éditeur : l'emplacement apparaît vide.
- Importer un code issu d'une version future qui a ajouté des champs : les champs inconnus sont ignorés.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT permettre de composer une build : un nom (40 caractères au plus, « Ma build » par défaut), un champion facultatif et jusqu'à six objets dans des emplacements numérotés.
- **FR-002**: Le système DOIT afficher le prix total de la build et les bonus chiffrés cumulés non nuls, les fractions de Riot étant montrées en pourcentage, dans un ordre de lecture fixe ; les effets passifs et actifs ne sont pas comptés.
- **FR-003**: Le système DOIT refuser d'enregistrer une build sans objet.
- **FR-004**: Le système DOIT conserver les builds entre deux lancements, dans l'ordre des emplacements, avec leur champion, les plus récemment enregistrées en tête, une build modifiée remplaçant sa version précédente.
- **FR-005**: Le système DOIT lister les builds avec nom, champion, prix total et vignettes d'objets, ouvrir l'éditeur à l'appui, et supprimer après confirmation explicite.
- **FR-006**: Le système DOIT donner accès aux builds depuis l'onglet Outils (« Mes builds ») et depuis l'onglet Objets (« Builds »).
- **FR-007**: Le système DOIT permettre de créer une build préremplie depuis les objets conseillés d'un champion.
- **FR-008**: Le système DOIT proposer, dans le choix d'un champion de build, un filtre de rôle quand les données de voies sont disponibles, et rester utilisable sans.
- **FR-009**: Le système DOIT produire, pour chaque build, un résumé texte copiable (titre, objets numérotés, total en or ou « Aucun objet. », ligne finale « Code : <code> ») et confirmer la copie ou son échec.
- **FR-010**: Le système DOIT produire un code de partage commençant par `LOLB1.` suivi d'un contenu compact en base64 « URL-safe » sans remplissage, portant le nom, le champion éventuel et les identifiants d'objets.
- **FR-011**: Le système DOIT importer une build depuis un texte libre contenant un code `LOLB1.` (code seul ou noyé dans un message), l'enregistrer sous un nouvel identifiant et le confirmer.
- **FR-012**: Le système DOIT refuser, sans rien enregistrer, un code absent, tronqué, corrompu, non JSON, ou dont le nom est vide ou dépasse 60 caractères, dont le champion n'est pas un texte, ou dont les objets ne sont pas une liste de six textes au plus ; il DOIT passer au code suivant d'un message si le premier est illisible, et ignorer les champs inconnus.
- **FR-013**: La boîte d'import DOIT rester ouverte tant que le texte n'est pas compris, afficher l'erreur, l'effacer à la saisie suivante, proposer « Coller » et « Annuler ».
- **FR-014**: Le système DOIT, en cas de panne réseau, afficher un message en français et « Réessayer » sur la liste et sur l'éditeur, sans conserver l'échec.
- **FR-015**: Le système DOIT tolérer une donnée enregistrée illisible, un objet retiré du catalogue et un champion inconnu sans perdre les autres builds.
- **FR-016**: Le système DOIT exposer aux lecteurs d'écran des libellés pour chaque emplacement, le choix du champion, les actions de partage, de suppression et d'import.

### Key Entities *(include if feature involves data)*

- **Build**: un identifiant, un nom, un champion facultatif, jusqu'à six identifiants d'objets ordonnés.
- **Code de partage**: texte `LOLB1.<base64url>` qui encode nom, champion et objets d'une build.
- **Résumé de build**: texte brut destiné à un message, qui contient le code.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Un joueur compose et enregistre une build de six objets en moins d'une minute, et la retrouve intacte après redémarrage (test d'aller-retour du stockage).
- **SC-002**: Un aller-retour code → import redonne une build identique (nom, champion, objets) avec un nouvel identifiant, pour 100 % des cas testés ; 100 % des codes invalides testés sont refusés sans enregistrement.
- **SC-003**: Une entrée stockée corrompue ne supprime jamais les autres builds.
- **SC-004**: Un ami reçoit en un message le résumé lisible et le code ; l'importer demande un collage et un appui.
- **SC-005**: Aucun écran de la fonctionnalité ne reste sur un chargement sans issue sans réseau : message et « Réessayer ».

## Assumptions

- Les objets et le prix viennent du catalogue Data Dragon (`ItemService`) ; le prix d'un objet est son coût total, composants compris.
- Les builds sont personnelles et locales : ni compte, ni synchronisation, ni serveur.
- Un code de partage ne porte pas le patch du jeu : si Riot retire un objet, il disparaît à l'affichage.
- Le champion et les objets sont référencés par identifiant Data Dragon.

### Limites connues

- Le nom d'une build est limité à 40 caractères dans l'éditeur mais l'import accepte 60 : une build importée peut porter un nom plus long que ce que l'éditeur permet de saisir.
- Les textes d'invite vouvoient l'utilisateur (« Composez-en une », « Collez le code ») alors que la constitution demande le tutoiement (voir `plan.md`).
- `importBuildFromText` (`lib/builds/services/build_import.dart`) n'est appelée que par ses tests : la page importe via `PasteCodeDialog` puis `BuildStore.save`.
- Aucun test de widget de l'éditeur ; la page de liste a des tests de widget (`test/builds/builds_page_test.dart`), fichier non encore suivi par git au moment de la rédaction.
- Le partage se fait par copie dans le presse-papiers ; il n'y a pas de feuille de partage système.
