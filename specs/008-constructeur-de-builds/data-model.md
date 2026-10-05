# Data Model: Constructeur de builds, partage et import par code

## Build (`lib/builds/models/build.dart`)

| Champ | Type | Règle |
|-------|------|-------|
| `id` | `String` | Obligatoire. Produit par `BuildStore.newId()` (microsecondes depuis l'époque). Clé de remplacement dans le magasin. |
| `name` | `String` | Obligatoire. L'éditeur le limite à 40 caractères et met « Ma build » s'il est vide ; l'import accepte 1 à 60 caractères. |
| `championId` | `String?` | Identifiant Data Dragon du champion, ou `null` (build valable pour tous). |
| `itemIds` | `List<String>` | Identifiants d'objets dans l'ordre des emplacements ; jamais plus de `Build.maxItems` (= `maxItemSlots` = 6). |

- `copyWith({name, championId, itemIds})` conserve l'identifiant. Limite : passer `null` à `championId` conserve l'ancienne valeur (retirer le champion se fait en reconstruisant une `Build`, ce que fait l'éditeur à l'enregistrement).
- `toJson()` : `{id, name, championId, itemIds}`.
- `tryFromJson(dynamic)` : renvoie `null` si l'entrée n'est pas une `Map` ou si `id`/`name` ne sont pas des textes ou `itemIds` n'est pas une liste ; sinon convertit chaque élément en texte et ne garde que les six premiers.

## BuildStore (`lib/builds/services/build_store.dart`)

- Stockage : `shared_preferences`, clé `saved_builds`, liste de chaînes dont chacune est le JSON d'une build.
- État : `builds` (`ValueNotifier<List<Build>>`), vide au départ.
- Chargement : paresseux et mémorisé (`ensureLoaded`). Les entrées illisibles (JSON invalide ou `tryFromJson` nul) sont écartées une à une. Si le stockage échoue, la liste reste vide et le chargement sera retenté au prochain appel.
- `save(build)` : retire toute build de même `id`, place la nouvelle en tête, publie la liste puis écrit.
- `delete(id)` : retire la build, publie, écrit.
- Écriture : file `_writeQueue` ; chaque écriture attend la précédente, une écriture en échec n'interrompt pas la file.
- `reset()` (`@visibleForTesting`) : vide le cache et la file.

États d'une build : composée dans l'éditeur (non enregistrée) → enregistrée (`save`) → modifiée (`save` du même `id`, passe en tête) → supprimée (`delete`, après confirmation).

## Statistiques cumulées (`lib/builds/services/build_stats.dart`)

- `StatLine {label, value}` : une ligne déjà formatée.
- `BuildStats.totalGold(items)` : somme de `Item.gold` (coût total, composants compris).
- `BuildStats.total(items)` : pour chacune des 12 définitions, dans cet ordre, somme `item.stats[clé]` et omet les sommes nulles :

| Clé Data Dragon | Libellé | Format |
|-----------------|---------|--------|
| `FlatPhysicalDamageMod` | Dégâts d'attaque | `+N` |
| `FlatMagicDamageMod` | Puissance | `+N` |
| `PercentAttackSpeedMod` | Vitesse d'attaque | `+N %` |
| `FlatCritChanceMod` | Chances de coup critique | `+N %` |
| `PercentLifeStealMod` | Vol de vie | `+N %` |
| `FlatHPPoolMod` | Points de vie | `+N` |
| `FlatArmorMod` | Armure | `+N` |
| `FlatSpellBlockMod` | Résistance magique | `+N` |
| `FlatMPPoolMod` | Mana | `+N` |
| `FlatHPRegenMod` | Régénération de PV | `+N` |
| `FlatMovementSpeedMod` | Vitesse de déplacement | `+N` |
| `PercentMovementSpeedMod` | Vitesse de déplacement | `+N %` |

Les valeurs sont arrondies à l'entier ; les « fractions » (0,25) sont multipliées par 100 avant arrondi.

## Code de partage de build

Texte `LOLB1.<base64url sans « = »>` ; le contenu décodé est un objet JSON :

| Clé | Type | Règle |
|-----|------|-------|
| `n` | texte | nom, 1 à 60 caractères |
| `c` | texte, absent si pas de champion | identifiant du champion |
| `i` | liste de textes | 0 à 6 identifiants d'objets |

L'identifiant de la build n'est pas dans le code : chaque lecture en génère un nouveau (`_freshId`, qui boucle tant qu'il égale le précédent généré). Les clés inconnues sont ignorées.

## Résumé de build (`BuildShareText.of`)

Lignes jointes par un saut de ligne : titre (`Build « nom »` ou `Build « nom » pour Champion`), puis soit `Aucun objet.`, soit `N. Nom de l'objet` par objet et `Total : X or`, puis `Code : LOLB1.…`.
