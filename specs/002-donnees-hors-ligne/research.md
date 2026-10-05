# Research: Données hors ligne

## Clé logique plutôt qu'URL

- **Decision**: la copie est rangée sous un nom logique (`champions`, `items`, `champion:Ahri`…) dans `shared_preferences`, préfixé `ddragon_offline_`.
- **Rationale**: commentaire d'`offline_json_cache.dart` : l'URL change à chaque patch, et chaque version resterait stockée à côté de la précédente jusqu'à saturer le stockage du navigateur.
- **Alternatives considered**: la clé par URL est écartée explicitement dans le commentaire.

## Écrire la copie seulement après décodage et validation

- **Decision**: le corps n'est enregistré qu'une fois décodé, et, si `isValid` est fourni, une fois la forme vérifiée.
- **Rationale**: commentaires de `data_dragon_service.dart` : un corps illisible ne doit pas écraser la dernière bonne version ; un CDN ou un portail captif peut répondre 200 avec un autre JSON, qui écraserait la bonne copie et casserait aussi le hors ligne. Test : `un JSON de mauvaise forme n ecrase pas la bonne copie`, `un corps illisible n ecrase pas la derniere bonne copie`.
- **Alternatives considered**: la première version (`284ebd7`) ne contrôlait que le décodage JSON ; l'audit (`offline-audit.md`) a relevé le cas du JSON valide de mauvaise forme.

## Un document refusé est traité comme une panne

- **Decision**: `isValid` négatif lève une `DataDragonException` (« Réponse inattendue du serveur de Riot. »), qui passe par le même chemin de repli que la panne réseau.
- **Rationale**: un seul chemin de repli, donc la copie est resservie ; si la copie aussi est mauvaise, la panne d'origine remonte.
- **Alternatives considered**: aucune tracée.

## Copie corrompue : remonter la vraie panne

- **Decision**: si `jsonDecode` échoue sur la copie, on relance la panne d'origine (`throw failure`) ; si la copie ne passe pas `isValid`, `rethrow` aussi.
- **Rationale**: l'audit : la `FormatException` brute ne sortait pas comme `DataDragonException` (le commentaire disait l'inverse, `rethrow` relançait la mauvaise exception). Test : `une copie corrompue remonte une DataDragonException`.
- **Alternatives considered**: aucune tracée.

## Bornage des fiches à 12 copies par famille

- **Decision**: `offlineKeepLast`, avec une liste d'ancienneté par famille (`ddragon_recent_<famille>`) ; `ChampionService` garde 12 fiches (`_detailCopiesKept`).
- **Rationale**: commentaires du service et de l'audit : ne pas remplir le stockage avec un fichier par champion consulté ; le stockage web est limité (environ 5 Mo). Le choix du nombre 12 n'est pas justifié par une mesure dans le code : c'est une valeur de compromis.
- **Alternatives considered**: télécharger toutes les fiches (environ 170 champions) n'est pas envisagé dans les traces ; une limite par taille non plus.

## Écriture de la copie sans conséquence

- **Decision**: `OfflineJsonCache.write` et `read` avalent toute exception.
- **Rationale**: commentaire : stockage plein ou indisponible, la copie hors ligne est un bonus, son absence ne doit jamais faire échouer un chargement réussi.
- **Alternatives considered**: aucune tracée.

## Ne pas figer l'échec de la version

- **Decision**: `_pendingVersion` est remis à `null` dans le `catch` de `_fetchLatestVersion`.
- **Rationale**: commentaire : sans cela, le « Réessayer » des écrans ne servirait à rien. Cette règle est aussi dans la constitution (principe II). Test : `la version est resservie hors ligne, et un echec se retente`.
- **Alternatives considered**: aucune.

## Page de la carte : futur recréé au retry

- **Decision**: `MapPage` reçoit `loadVersion` (injectable) et recrée son futur à chaque « Réessayer ».
- **Rationale**: commentaire de `_retryVersion` : hors ligne, la version est introuvable ; sans nouveau futur l'utilisateur devrait quitter la page pour retenter. L'injection permet de tester sans réseau.
- **Alternatives considered**: l'ancien `late final Future` (non rejouable) est remplacé ; le message « Chargement impossible » sans bouton disparaît.

## Forme attendue par jeu de données

- **Decision**: `hasDataMap` (objet avec clé `data` de type objet) pour champions, fiche, objets et sorts ; liste pour les runes ; liste non vide dont le premier élément est une chaîne pour les versions.
- **Rationale**: ce sont les formes que les services lisent ensuite (`data['data'] as Map`, `response as List`) ; une autre forme planterait à l'analyse.
- **Alternatives considered**: aucune tracée.
