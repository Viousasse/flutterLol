# Data Model: Galerie des apparences

Aucune donnée persistée ; les apparences sont lues dans la fiche détaillée du champion.

## ChampionSkin (`lib/champions/models/champion_skin.dart`)

| Champ | Type | Règle |
|-------|------|-------|
| championId | String | identifiant Data Dragon du champion (ex. `Ahri`) |
| number | int | numéro dans les adresses d'images ; 0 pour l'apparence d'origine |
| name | String | nom de Data Dragon ; « default » remplacé par « Apparence classique » |

Dérivés : `splashUrl = https://ddragon.leagueoflegends.com/cdn/img/champion/splash/<id>_<number>.jpg` ; `loadingUrl = …/loading/<id>_<number>.jpg`.

### Lecture (`listFromJson(championId, rawSkins)`)

- `rawSkins` n'est pas une liste → liste vide.
- Seules les entrées de type objet sont lues ; celles qui ont une clé `parentSkin` (variantes de couleur) sont écartées.
- `num` est lu comme entier ; une entrée sans `num` ou sans `name` texte lève une erreur de type (pas de garde dans le code actuel : les données Riot sont supposées bien formées).

## ChampionDetail.skins (`lib/champions/models/champion_detail.dart`)

`final List<ChampionSkin> skins` (vide par défaut), remplie par `ChampionSkin.listFromJson(json['id'], json['skins'])`.

## État du visualiseur (`SkinViewerPage`)

| Champ | Règle |
|-------|-------|
| skins | liste reçue, jamais vide (la galerie n'ouvre rien sinon) |
| initialIndex | index de la vignette appuyée |
| currentIndex | page courante ; la flèche précédente n'existe que si `> 0`, la suivante que si `< skins.length − 1` |
