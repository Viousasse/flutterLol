# Outils de génération des données

## `generate_matchups.dart` : les contre-picks

Produit `assets/data/champion_matchups.json` à partir de vraies parties
classées (Master+, solo/duo) via l'API officielle de Riot.

### Prérequis

- Une **clé de développement Riot** (https://developer.riotgames.com), valable
  **24 h** : il faut la renouveler chaque jour.
- Limite de la clé : **100 requêtes toutes les 2 minutes**. L'outil la respecte
  tout seul (pauses automatiques). Compter **environ 1 h pour 3 000 parties**.
- **Ne jamais écrire la clé dans un fichier** (code, README, `.env` commité,
  historique). On la passe uniquement par la variable d'environnement
  `RIOT_API_KEY`, le temps de la commande.

### Régénération complète

```bash
RIOT_API_KEY=RGAPI-... dart run tool/generate_matchups.dart --matches 3000 --output build/matchups.json
```

PowerShell :

```powershell
$env:RIOT_API_KEY = "RGAPI-..."
dart run tool/generate_matchups.dart --matches 3000 --output build/matchups.json
```

Écrire dans `--output` (hors de `assets/`) évite de remplacer les données de
l'application avant la fin du calcul.

### Mise à jour à un nouveau patch (sans tout refaire)

On garde l'existant mais on le **fait vieillir** : ses bilans comptent moins que
les parties fraîches, et on ignore les parties de patchs trop anciens.

```bash
RIOT_API_KEY=RGAPI-... dart run tool/generate_matchups.dart \
  --matches 2000 \
  --merge-with assets/data/champion_matchups.json \
  --decay 0.5 \
  --min-patch 16.20 \
  --output build/matchups.json
```

- `--merge-with <fichier>` : fichier existant à additionner aux nouvelles
  parties.
- `--decay <0..1>` (défaut `1`, sans effet) : facteur appliqué aux bilans du
  fichier fusionné **avant** l'addition. `0.5` divise leur poids par deux.
  Parties et victoires sont arrondies, les victoires ne dépassent jamais les
  parties, et une paire qui tombe à 0 partie disparaît. Le total `matches` est
  pondéré de la même façon.
- `--min-patch X.Y` : ignore les nouvelles parties d'un patch antérieur
  (comparaison numérique : `16.9` précède `16.10`). Elles sont tout de même
  marquées comme traitées, donc une reprise ne les relit pas.

### Reprise après interruption

La progression est sauvegardée toutes les 100 parties dans
`<output>.progress.json`. Relancer **la même commande** avec `--resume` en plus
(même `--output`) : les parties déjà traitées ne sont pas recomptées. Une
partie supprimée par Riot (404) est simplement ignorée ; une clé expirée arrête
l'outil après avoir sauvegardé.

### Installer le fichier

1. Copier le résultat vers `assets/data/champion_matchups.json`.
2. Lancer `flutter test` : les tests de données et d'écrans doivent passer.
3. Relire l'étiquette de patch affichée dans l'application (voir plus bas).

### Vérifier la couverture

Combien de champions ont au moins un contre-pick à **8 parties** ou plus (le
seuil en dessous duquel l'application tait les chiffres) ? Avec PowerShell :

```powershell
$d = Get-Content assets/data/champion_matchups.json -Raw | ConvertFrom-Json
($d.matchups | Where-Object { $_.games -ge 8 } |
  Select-Object -ExpandProperty champion -Unique).Count
```

Comparer au nombre total de champions (environ 170). Si trop de champions sont
absents, relancer avec davantage de parties plutôt que de baisser le seuil.

### Format du fichier et étiquette de patch

```json
{ "generatedAt": "…", "patch": "16.16–16.19", "platform": "euw1",
  "rank": "MASTER+", "matches": 7600,
  "patches": { "16.19": 4045, "16.18": 2100 },
  "matchups": [ { "champion": "Darius", "opponent": "Garen",
                  "lane": "TOP", "games": 12, "wins": 7 } ] }
```

- `patch` : un seul patch (`16.19`) si toutes les parties en viennent, sinon
  une **plage** (`16.16–16.19`) : le fichier mélange alors plusieurs versions du
  jeu, et l'application l'affiche telle quelle plutôt que de le cacher.
- `patches` : parties par patch (pondérées par `--decay`). Champ purement
  informatif, ignoré par l'application ; il sert à voir ce qui pèse vraiment
  dans la plage.
- `matches` : nombre total de parties exploitées (pondéré).

La logique pure (vieillissement, comparaison de patchs, fusion) est dans
`tool/matchup_tally.dart`, testée par `test/tool/matchup_tally_test.dart`.
