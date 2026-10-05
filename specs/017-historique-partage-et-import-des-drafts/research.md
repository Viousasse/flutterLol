# Research: Historique, partage et import des drafts

Décisions tirées des commentaires du code, des tests et du commit `57ca610`. Quand aucune trace n'explique un choix, c'est écrit.

## 1. Sauvegarde automatique à la fin du bilan

- **Decision**: la draft est ajoutée à l'historique dès que `DraftEvaluator` a rendu son bilan, sans demande.
- **Rationale**: commentaire dans `lib/draft/draft_page.dart` : « on ne demande rien au joueur, et un « Recommencer » ne la perd pas ».
- **Alternatives considered**: bouton « Enregistrer » explicite : aucune trace dans le code, non étudié.

## 2. Une liste de chaînes JSON dans `shared_preferences`

- **Decision**: clé `draft_history`, `setStringList` avec un JSON par draft, 50 entrées au plus (`maxRecords`).
- **Rationale**: « l'historique ne doit pas grossir sans fin dans le stockage de l'appareil ». Une entrée par chaîne permet qu'une entrée corrompue soit écartée seule (`tryFromJson` renvoie `null`) sans perdre les autres. Même forme que le stockage des builds (commentaire du store).
- **Alternatives considered**: fichier JSON unique ou base locale : aucune trace, non étudié. Le seuil de 50 n'a pas de justification chiffrée.

## 3. File d'écritures séquentielle

- **Decision**: `_persist` enchaîne les écritures sur une file de `Future`, et une écriture qui échoue ne casse pas la file.
- **Rationale**: « Les écritures s'enchaînent pour ne pas se doubler » ; la liste en mémoire reste juste même si la sauvegarde est perdue.

## 4. Bilan : à qui appartient la victoire

- **Decision**: contre le site, le joueur est le camp bleu ; les drafts à deux, avec aide ou importées sont comptées dans le total mais pas dans le taux ; les égalités ne sont ni victoire ni défaite.
- **Rationale**: commentaires de `draft_history_stats.dart` : à deux « on ne sait pas qui est le joueur » ; avec les conseils « la victoire ne mesure plus le niveau du joueur » ; « le joueur d'une draft reçue n'est pas vous ». Les champions d'une draft à deux comptent pour les deux camps, ceux d'une draft importée contre le site comptent pour le camp bleu seulement (comportement du code).
- **Alternatives considered**: pas de trace.

## 5. Le résumé garde les noms de champions

- **Decision**: `DraftRecord` stocke `championNames` en plus des identifiants.
- **Rationale**: « le résumé à partager et l'historique se lisent sans recharger la liste des champions » ; un champion retiré du jeu reste nommé (`nameOf` retombe sur l'identifiant sinon).

## 6. Un code = préfixe versionné + JSON en base64 « URL-safe »

- **Decision**: `LOLD1.` + base64url sans remplissage du JSON compact (clés courtes `t`, `f`, `bn`, `rn`, `b`, `r`, `bb`, `rb`, `nm`, `w`, `bs`, `rs`, `v`, `a`).
- **Rationale**: commentaire de `share_code.dart` : le préfixe porte le type et la version, il change quand le format casse (`LOLB1.` deviendrait `LOLB2.`) ; ajouter un champ ne le change pas car les lecteurs ignorent les champs inconnus (testé : « ignore les champs inconnus » ; ancien code sans `a` se relit non assisté). Base64url pour tenir dans un message sans caractère à échapper.
- **Alternatives considered**: aucune trace écrite (pas de compression, pas de signature).

## 7. Recherche du code dans le texte collé

- **Decision**: `ShareCode.decode` cherche par expression régulière tous les codes du préfixe et renvoie le premier lisible.
- **Rationale**: « Le code est le plus souvent collé au milieu d'un message entier » ; un code tronqué ou abîmé est ignoré, on essaie le suivant.

## 8. Garde-fous sur un code venu de l'extérieur

- **Decision**: nom 1 à 40 caractères, verdict au plus 300, au plus 10 bannis par camp, exactement 5 rôles par équipe, scores numériques obligatoires, valeurs hors types refusées.
- **Rationale**: commentaire « Garde-fous sur un code venu de l'extérieur ». Les seuils 40/300/10 n'ont pas d'explication chiffrée dans le code ; 10 = 5 bans par camp attendus doublés (déduction, non écrite).
- **Alternatives considered**: pas de trace.

## 9. Import : nouvel identifiant, date d'origine, marquage « importée »

- **Decision**: `decode` génère un identifiant neuf (attente de la microseconde suivante si égal au précédent) mais garde `playedAt` ; `imported = true`.
- **Rationale**: « L'horloge peut rendre deux fois la même microseconde quand on lit deux codes d'affilée » (test « chaque lecture donne un nouvel identifiant »).

## 10. Doublon : comparer le contenu, pas l'identifiant

- **Decision**: `isAlreadySaved` compare date, équipes et bannis.
- **Rationale**: « l'identifiant, lui, change à chaque import ».

## 11. Boîte d'import générique

- **Decision**: `PasteCodeDialog<T>` reçoit une fonction `parse`, un titre, un indice et un message d'erreur ; elle reste ouverte tant que `parse` renvoie `null`.
- **Rationale**: « se tromper de copier-coller ne doit pas obliger à rouvrir la boîte » ; générique pour servir aussi aux builds.

## 12. Message d'import sans attendre l'écriture

- **Decision**: la confirmation s'affiche avant la fin de l'écriture disque.
- **Rationale**: « la liste est déjà à jour, et l'écriture peut être lente ».

## 13. Rejeu : poser les bans dans l'ordre et s'arrêter au premier manquant

- **Decision**: `_initialState` pose les bans selon `draftBanOrder` ; au premier champion introuvable (retiré du jeu) elle s'arrête et la phase de bannissement reprend.
- **Rationale**: `DraftState.ban` impose l'ordre et le camp, donc on ne peut pas sauter une case. Mode et noms repris de la draft d'origine ; le rejeu ne compte pas dans le score de la soirée (`_usesSession`).

## 14. Tuile : un seul libellé sémantique

- **Decision**: la zone touchable de la tuile est un bouton sémantique unique qui décrit la draft ; les boutons Partager et Supprimer sont hors de cette zone, avec info-bulle.
- **Rationale**: test « a un seul libellé sémantique pour la tuile ». Pas d'autre trace.

## 15. Copie : dire l'échec

- **Decision**: `copyToClipboard` affiche « Copie impossible sur cet appareil » si le système refuse.
- **Rationale**: « pour qu'on ne colle pas un ancien contenu en croyant avoir copié ».
