# Feature Specification: Draft à deux

**Feature Branch**: `016-draft-a-deux` (travail livré sur `main`, pas de branche dédiée)

**Created**: 2026-10-05

**Status**: Implemented

**Input**: User description : « rajoute un mode local pour faire une draft contre un ami » ; puis « fais le 1 et 2 et 3 » (noms modifiables des joueurs) ; puis le score de la soirée mémorisé entre deux parties.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Faire une draft à deux sur le même appareil (Priority: P1)

Depuis l'outil « Composition », l'utilisateur ouvre « Draft à deux : jouer contre un ami ». Deux personnes se passent l'appareil : la première joue le camp bleu, la seconde le camp rouge. Chacune choisit à son tour, pour le rôle de son choix, dans le même ordre que pour la draft contre le site (voir 015), bannissements compris. Le statut dit à qui c'est de jouer (« Au tour de Joueur 2, camp rouge (choix 2 sur 10). Passez l'appareil si besoin, puis appuyez sur un rôle libre. »). Le site ne joue pas. À la fin, un bilan neutre compare les deux drafts et donne forces et conseils aux deux joueurs.

**Why this priority**: c'est la demande : une draft contre un ami en local, sans le site.

**Independent Test**: ouvrir la draft à deux, désactiver les bannissements, jouer dix choix en alternant ; le bilan nomme les deux joueurs.

**Acceptance Scenarios**:

1. **Given** une draft à deux neuve, **When** la page s'ouvre, **Then** le titre de l'écran est « Draft à deux », les colonnes s'appellent « Joueur 1 · BLEU » et « Joueur 2 · ROUGE » et le site ne joue jamais.
2. **Given** le tour de « Joueur 2 », **When** il touche un rôle libre de la colonne rouge puis un champion, **Then** le champion est posé dans la colonne rouge et le statut passe au joueur suivant.
3. **Given** le tour d'un camp, **When** on touche la colonne de l'autre camp, **Then** rien ne se passe (seules les cases du camp qui joue sont actives).
4. **Given** la draft terminée, **When** le bilan s'affiche, **Then** le verdict dit « La draft de Joueur 1 l'emporte » (ou « Joueur 2 », ou « Drafts équivalentes »), chaque critère dit « Avantage à Joueur 1 » ou « Avantage à Joueur 2 » avec la même couleur (aucun camp n'est « le mauvais »), et « CE QUI VA BIEN », « À AMÉLIORER » et « BANNISSEMENTS » sont donnés pour chacun, suffixés de son nom en majuscules.
5. **Given** les bannissements actifs, **When** la draft commence, **Then** chaque joueur bannit à son tour en touchant sa propre rangée de bannissements.

---

### User Story 2 - Nommer les joueurs (Priority: P2)

L'utilisateur touche le titre d'une colonne (un crayon le signale) : une boîte « Nom du joueur » s'ouvre avec le nom actuel. Le nom ne peut pas être vide ni identique, sans tenir compte de la casse, à celui de l'autre joueur ; il est limité à 12 caractères ; les espaces autour sont retirés. Le nom choisi apparaît partout : colonnes, statut, bilan, score. Les noms sont conservés d'un lancement à l'autre.

**Why this priority**: demandé ensuite (« fais le 1 et 2 et 3 ») ; la draft se joue avec « Joueur 1 » et « Joueur 2 » sans cela.

**Independent Test**: toucher « Joueur 1 · BLEU », saisir « Léa », valider ; la colonne devient « Léa · BLEU » et le nom survit à un redémarrage.

**Acceptance Scenarios**:

1. **Given** la boîte ouverte, **When** on saisit « Léa » entourée d'espaces et on valide, **Then** le nom devient « Léa ».
2. **Given** la boîte ouverte, **When** on saisit le nom de l'autre joueur (même en autre casse) ou un nom vide, **Then** la boîte reste ouverte avec une explication (« Ce nom est déjà pris par l'autre joueur. », « Saisissez un nom. »).
3. **Given** la boîte ouverte, **When** on annule, **Then** aucun nom ne change.
4. **Given** le bilan affiché, **When** on regarde les titres de colonne, **Then** ils ne se touchent plus (changer un nom rendrait le bilan faux).
5. **Given** un renommage, **When** on relance l'application et rouvre la draft à deux, **Then** les noms sont ceux choisis.

---

### User Story 3 - Suivre le score de la soirée (Priority: P2)

Une barre « SCORE DE LA SOIRÉE » en haut de la page affiche le score cumulé (« Léa 3 – 2 Tom », plus « 1 égalité » quand il y en a). Chaque draft terminée ajoute une victoire au vainqueur du bilan, ou une égalité. Le score et les noms sont conservés entre deux lancements. Un bouton remet le score à zéro après confirmation ; il est désactivé quand le score est déjà vide. Renommer un joueur ne change pas le score : c'est la même soirée.

**Why this priority**: ajouté après la version de base pour enchaîner des drafts entre amis ; la draft à deux se joue sans.

**Independent Test**: terminer deux drafts ; la barre affiche « 1 – 1 » ou le cumul correspondant ; relancer l'application ; le score est toujours là.

**Acceptance Scenarios**:

1. **Given** une soirée sans score, **When** la page s'ouvre, **Then** la barre affiche « Joueur 1 0 – 0 Joueur 2 » et le bouton de remise à zéro est désactivé.
2. **Given** une draft terminée avec un vainqueur, **When** le bilan s'affiche, **Then** le score de ce joueur augmente de un.
3. **Given** une draft terminée sur « Drafts équivalentes », **When** le bilan s'affiche, **Then** le compteur d'égalités augmente de un et s'affiche (« 1 égalité », « 2 égalités »).
4. **Given** un score non vide, **When** on touche le bouton de remise à zéro, **Then** une confirmation « Remettre le score à zéro ? » s'affiche ; « Annuler » ne change rien, « Remettre à zéro » vide les compteurs et garde les noms.
5. **Given** un score enregistré, **When** on relance l'application, **Then** les noms et le score sont relus.
6. **Given** un nom renommé après plusieurs parties, **When** on regarde la barre, **Then** le score est inchangé.

---

### User Story 4 - Rejouer un duel sans toucher au score (Priority: P3)

Depuis l'historique des drafts (spec 017), l'utilisateur rejoue un duel : la page reprend le mode, les noms et les bannissements de la draft d'origine. Le score de la soirée n'est ni affiché ni modifié par un duel rejoué, et les noms de la soirée restent ceux de la soirée.

**Why this priority**: évite qu'un rejeu fausse le score ; cas secondaire.

**Independent Test**: rejouer un duel entre « Alice » et « Bob » alors que la soirée oppose « Joueur 1 » et « Joueur 2 » ; la page n'a pas de barre de score et la session reste inchangée à la fin.

**Acceptance Scenarios**:

1. **Given** un duel rejoué, **When** la page s'ouvre, **Then** les colonnes portent les noms de l'original (« Alice · BLEU ») et aucune barre de score n'est affichée.
2. **Given** un duel rejoué terminé, **When** le bilan s'affiche, **Then** les victoires, égalités et noms de la soirée n'ont pas changé.
3. **Given** une draft à deux normale, **When** la page s'ouvre, **Then** la barre de score est affichée (distinction rejeu / non rejeu).

---

### Edge Cases

- Fichier de session illisible ou de mauvaise forme (JSON invalide, noms vides ou identiques, compteurs négatifs ou non entiers) : retour aux valeurs par défaut (« Joueur 1 », « Joueur 2 », score 0), sans erreur (testé).
- Stockage indisponible : noms et score restent justes en mémoire pour la partie en cours ; seule la sauvegarde est perdue, le prochain accès retentera.
- Renommage d'un joueur pendant la draft : les noms de la page suivent la soirée ; une fois le bilan établi, ils ne suivent plus pour ne pas le rendre faux.
- Les écritures se mettent en file : deux modifications rapprochées ne se doublent pas, et une écriture en échec ne bloque pas les suivantes.
- Un nom vide ou déjà pris, parvenu au service malgré la boîte, est ignoré sans erreur et sans rien changer.
- Une analyse échouée puis relancée avec « Réessayer » ne compte la victoire qu'une seule fois, à la fin de l'analyse réussie.
- Quitter avant le bilan : rien n'est compté.
- Dans un duel rejoué, renommer un joueur reste local à la page et n'écrit pas dans la soirée.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT proposer, depuis l'outil « Composition », une draft à deux sur un seul appareil où le premier joueur tient le camp bleu et le second le camp rouge, sans intervention du site.
- **FR-002**: Le système DOIT activer, à chaque tour, uniquement les cases (choix ou bannissement) du camp qui doit jouer, et annoncer son nom et son camp dans le statut avec le rappel de passer l'appareil.
- **FR-003**: Le système DOIT utiliser les mêmes règles d'ordre, de bannissement et de choix que la draft contre le site (spec 015), y compris l'aide au choix qui conseille alors le camp qui doit jouer.
- **FR-004**: Le bilan à deux DOIT être neutre : verdict, avantages, forces, conseils et remarques sur les bannissements nomment chaque joueur ; chaque joueur reçoit ses propres conseils ; les avantages des deux camps ont la même couleur.
- **FR-005**: Le système DOIT permettre de modifier le nom d'un joueur en touchant le titre de sa colonne tant que la draft n'est pas terminée, et annoncer ce titre aux lecteurs d'écran comme un bouton « Modifier le nom : … ».
- **FR-006**: Un nom DOIT être refusé s'il est vide, composé d'espaces, ou égal (sans tenir compte de la casse ni des espaces autour) au nom de l'autre joueur, avec un message qui explique pourquoi ; il DOIT être limité à 12 caractères et débarrassé des espaces autour.
- **FR-007**: Le système DOIT conserver entre deux lancements les noms des joueurs et le score de la soirée, et retomber sur « Joueur 1 », « Joueur 2 » et un score vide quand la sauvegarde est absente, illisible ou invalide.
- **FR-008**: Le système DOIT afficher le score cumulé (« Nom 3 – 2 Nom », égalités en plus si elles existent, accordées au pluriel) en haut de la draft à deux.
- **FR-009**: Le système DOIT ajouter une victoire au vainqueur, ou une égalité, quand un bilan est établi, une seule fois par draft.
- **FR-010**: Le système DOIT permettre de remettre le score à zéro après confirmation, en gardant les noms, et désactiver le bouton quand le score est vide.
- **FR-011**: Renommer un joueur NE DOIT PAS modifier le score.
- **FR-012**: Une draft à deux rejouée depuis l'historique DOIT reprendre le mode, les noms et les bannissements de l'original, NE DOIT PAS afficher la barre de score et NE DOIT PAS modifier le score ni les noms de la soirée.
- **FR-013**: La barre de score DOIT annoncer le score complet aux lecteurs d'écran (« Score de la soirée : Léa 3, Tom 2, 1 égalité ») et son bouton DOIT avoir une zone tactile d'au moins 48 px.
- **FR-014**: Le système DOIT enregistrer la draft à deux dans l'historique comme une draft « contre un ami », avec les noms des joueurs (spec 017).

### Key Entities

- **Joueurs** : deux noms (camp bleu, camp rouge), valeurs par défaut « Joueur 1 » et « Joueur 2 ».
- **Soirée (session)** : les deux noms, le nombre de victoires de chaque joueur et le nombre d'égalités ; unique pour l'appareil.
- **Résultat** : vainqueur du bilan (bleu, rouge ou égalité).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Une draft à deux complète (dix choix, avec ou sans bannissements) se joue sans autre action que les choix des deux joueurs et aboutit à un bilan qui nomme les deux joueurs ; vérifié par `test/draft/draft_page_flow_test.dart`.
- **SC-002**: Après chaque draft terminée, le total victoires + égalités de la soirée augmente d'exactement 1 ; un duel rejoué le laisse inchangé.
- **SC-003**: Noms et score relus après un redémarrage sont identiques à ceux d'avant, et une sauvegarde invalide ne provoque jamais d'erreur visible.
- **SC-004**: Aucun nom enregistré n'est vide, ni identique à celui de l'autre joueur, ni de plus de 12 caractères saisis.

## Assumptions

- Les deux joueurs sont devant le même écran : aucune information n'est cachée à l'adversaire (voir limites).
- Le mode à deux réutilise la page de la draft contre le site (spec 015), l'historique, le partage et le rejeu de la spec 017.
- Une seule soirée est gérée à la fois par appareil.

## Hypothèses et limites connues

- Aucun masquage : les deux joueurs voient les choix, les bannissements et les conseils de l'aide au choix en même temps, ce qui convient à une partie entre amis face à face mais n'est pas une vraie draft en aveugle.
- Les noms sont limités à 12 caractères à la saisie (`playerNameMaxLength`), mais cette limite n'est pas revérifiée à la relecture d'un fichier de session.
- Le texte de l'interface vouvoie (« Saisissez un nom. », « Remettre le score à zéro ? ») alors que la constitution demande le tutoiement : écart relevé dans `plan.md`.
- Le vainqueur d'un bilan « à deux » n'est qu'une comparaison des deux drafts par les cinq critères de la 015, pas un résultat de partie : le score de la soirée compte les drafts jugées meilleures.
- L'aide au choix en mode à deux n'a pas de test propre ; elle est testée en mode contre le site (`draft_page_advice_test.dart`).
- Le renommage pendant un duel rejoué reste local à la page ; aucun test ne le couvre.
