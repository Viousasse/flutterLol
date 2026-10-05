# Contrat : ligne de commande `tool/generate_matchups.dart`

```bash
RIOT_API_KEY=RGAPI-... dart run tool/generate_matchups.dart [options]
```

PowerShell : `$env:RIOT_API_KEY = "RGAPI-..."` puis `dart run tool/generate_matchups.dart [options]`. La clé n'est jamais écrite dans un fichier.

## Environnement

| Variable | Obligatoire | Effet |
|----------|-------------|-------|
| `RIOT_API_KEY` | oui | clé de développement Riot (valable 24 h). Absente : message sur `stderr`, code de sortie 2. |

## Options

| Option | Défaut | Effet |
|--------|--------|-------|
| `--matches N` | 400 | nombre de parties à traiter |
| `--platform P` | `euw1` | plateforme ; la région est déduite (`europe`, `americas`, `asia`, `sea`) |
| `--output F` | `assets/data/champion_matchups.json` | fichier écrit |
| `--resume` | absent | reprend depuis `<F>.progress.json` |
| `--merge-with F` | absent | additionne ce fichier existant au résultat |
| `--decay X` | 1 | facteur 0..1 appliqué au fichier fusionné ; hors bornes : message, code 2 |
| `--min-patch X.Y` | absent | ignore les nouvelles parties d'un patch antérieur ; illisible : message, code 2 |

## Codes de sortie

0 succès ; 2 argument ou clé invalide ; autre : erreur HTTP non récupérable (progression sauvegardée d'abord).

## API de la logique pure (`tool/matchup_tally.dart`)

```dart
class Tally { int games; int wins; Tally(); Tally.of(int games, int wins); }
(int, int)? parsePatch(String patch);
int comparePatches(String a, String b);          // illisible = le plus ancien
bool isBeforePatch(String patch, String minPatch); // illisible : jamais écarté
int decayCount(int count, double factor);
Map<String, Tally> decayTally(Map<String, Tally> tally, double factor);
Map<String, int> decayPatches(Map<String, int> patches, double factor);
void mergeTally(Map<String, Tally> target, Map<String, Tally> source);
void mergePatches(Map<String, int> target, Map<String, int> source);
String patchRange(String a, String b);
```
