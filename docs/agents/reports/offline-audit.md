# Audit du mode hors-ligne

Seuls 5 fichiers font du réseau applicatif : `DataDragonService` (versions.json,
documents JSON) et les 4 services qui l'utilisent. Les matchups sont un asset
embarqué (`rootBundle`), les images passent par `RemoteImage`/`Image.network`
(échec = icône de repli, hors périmètre services). Les stores (builds, drafts,
favoris, quiz, thème) sont en `shared_preferences`, sans réseau.

## Services

| Service | Appel | Hors-ligne OK ? | Problème trouvé | Correctif |
|---|---|---|---|---|
| DataDragonService | `latestVersion` (versions.json, clé `versions`) | Oui si déjà lancé une fois en ligne | Un JSON de mauvaise forme (200) pouvait écraser la bonne copie et casser aussi le hors-ligne | `isValid` : copie écrite seulement si la forme est bonne, sinon traité comme une panne |
| DataDragonService | `fetchJson` | Oui (timeout 15 s, exceptions converties en `DataDragonException`) | Copie locale corrompue : `FormatException` brute au lieu de la panne réseau (commentaire disait l'inverse) | On relance maintenant la `DataDragonException` d'origine |
| DataDragonService | version introuvable (jamais lancé en ligne) | Non, normal | Aucune version codée en dur (`16.19.1` n'apparaît pas dans `lib`) ; échec => `DataDragonException` + `_pendingVersion` remis à zéro, donc « Réessayer » fonctionne | RAS |
| ChampionService | `fetchAll` (clé `champions`) | Oui | Forme non validée | `isValid: hasDataMap` |
| ChampionService | `fetchDetail` | **Non** (aucun `offlineKey`) | Fiche champion, comparateur et draft inutilisables hors ligne | Clé `champion:<id>`, bornée aux 12 dernières fiches (`offlineKeepLast`) pour ne pas saturer le stockage web (~5 Mo) |
| ItemService | `fetchAll` (clé `items`) | Oui | Forme non validée | `isValid: hasDataMap` |
| RuneService | `fetchAll` (clé `runes`) | Oui | Forme non validée | `isValid` : liste |
| SummonerSpellService | `fetchAll` (clé `summoners`) | Oui | Forme non validée | `isValid: hasDataMap` |
| MatchupService | `load` (asset embarqué) | Oui | Aucun | RAS |

Limite connue : une fiche champion jamais ouverte en ligne (ou sortie des 12
dernières) reste indisponible hors ligne, avec un message clair.

## Pages (état de la gestion d'erreur)

Toutes les pages qui chargent champions, objets, runes ou sorts passent par un
`catch` + `userMessageFor` + `ErrorRetryView`, sauf ceux ci-dessous.

## À traiter par l'architecte

| Fichier | Ligne | Problème |
|---|---|---|
| `lib/map/map_page.dart` | ~178-180 | `FutureBuilder` sur `latestVersion()` : l'échec affiche `MapPlaceholder('Chargement impossible')` sans bouton « Réessayer » et le futur (`late final _version`) n'est jamais relancé. Utiliser `ErrorRetryView` et recréer le futur au retry. |
| `lib/champion_detail/champion_detail_page.dart` | ~120-167 | Sorts et conseils (runes/objets) avalent l'erreur en silence : sections masquées hors ligne si les copies runes/summoners/items n'existent pas. Acceptable (bonus), à noter seulement. |
| `lib/home/home_page.dart` | ~44-53 | Carte du patch absente en silence si pas de version : acceptable (bonus). |
| `lib/champion_detail/widgets/rune_plan_section/rune_plan_section.dart`, `lib/items/widgets/item_detail_sheet/item_detail_sheet.dart` | — | Lisent des index statiques (`RuneService.treeByKey`, `ItemService.componentsOf`) sans appel réseau : OK tant que la page parente a chargé le service ; sinon résultat vide, sans plantage. |
