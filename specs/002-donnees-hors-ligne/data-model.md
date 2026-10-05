# Data Model: Données hors ligne

## Copie hors ligne (`shared_preferences`)

| Clé de stockage | Valeur | Rôle |
|-----------------|--------|------|
| `ddragon_offline_<nom>` | texte JSON brut tel que reçu | dernière copie valide du jeu de données `<nom>` |
| `ddragon_recent_<famille>` | liste de noms de la plus ancienne à la plus récente | ordre d'écriture des copies d'une famille, pour effacer les plus anciennes |

### Noms logiques en usage

| Nom | Contenu | Où il est demandé | Forme exigée |
|-----|---------|-------------------|--------------|
| `versions` | liste des versions du jeu | `DataDragonService._fetchLatestVersion` | liste non vide dont le premier élément est une chaîne |
| `champions` | `champion.json` | `ChampionService._fetchAll` | objet avec clé `data` de type objet |
| `champion:<id>` | fiche d'un champion | `ChampionService.fetchDetail` | idem ; famille `champion`, 12 copies |
| `items` | `item.json` | `ItemService` | idem |
| `runes` | `runesReforged.json` | `RuneService._download` | liste |
| `summoners` | `summoner.json` | `SummonerSpellService._fetchAll` | idem `champions` |

## Règles

- **Écriture** : seulement après téléchargement réussi, décodage et validation de la forme.
- **Borne** : avec `keepLast`, le nom DOIT être de la forme `famille:nom` ; la partie avant `:` est la famille. Réécrire un nom existant le remet en tête (le plus récent). Au-delà de `keepLast`, la copie la plus ancienne est supprimée.
- **Lecture** : `null` si aucune copie ou si le stockage est indisponible.
- **Échec d'écriture** : ignoré.

## États d'une récupération

```text
téléchargement ──ok, décodé, valide──> copie écrite ──> résultat servi
      │
      └─ panne (réseau, délai, code ≠ 200, corps illisible, forme refusée)
            ├─ pas de clé de copie ──────────────> DataDragonException
            ├─ pas de copie enregistrée ─────────> DataDragonException d'origine
            ├─ copie illisible ou de mauvaise forme -> DataDragonException d'origine
            └─ copie valide ─────────────────────> copie servie
```

## DataDragonException

| Champ | Type | Rôle |
|-------|------|------|
| `message` | `String` | texte en français affiché tel quel par l'écran (`userMessageFor`) |

Messages produits : délai dépassé, connexion impossible, code de réponse, réponse illisible, réponse inattendue, aucune version publiée.
