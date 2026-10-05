# Contrat : fichier `assets/data/champion_matchups.json`

Produit par `tool/generate_matchups.dart`, lu par `MatchupDataset.fromJson` (`lib/matchups/models/matchup.dart`) via `MatchupService.load()` (`lib/matchups/services/matchup_service.dart`). Déclaré dans `pubspec.yaml`.

```json
{
  "generatedAt": "2026-10-05T14:58:39.332198Z",
  "patch": "16.16–16.19",
  "platform": "euw1",
  "rank": "MASTER+",
  "matches": 7600,
  "patches": { "16.19": 4045, "16.18": 2100 },
  "matchups": [
    { "champion": "Jhin", "opponent": "Yunara", "lane": "BOTTOM", "games": 135, "wins": 63 }
  ]
}
```

| Champ | Type | Lu par l'application | Sens |
|-------|------|----------------------|------|
| `generatedAt` | ISO 8601 UTC | non | date de génération |
| `patch` | chaîne | oui (nullable) | un patch `16.19` ou une plage `16.16–16.19` (tiret long) |
| `platform` | chaîne | non | `euw1` |
| `rank` | chaîne | non | `MASTER+` |
| `matches` | entier | oui (0 si absent) | parties exploitées (pondérées par `--decay`) |
| `patches` | objet | non | optionnel, informatif : parties par patch (absent du fichier embarqué actuel ; l'exemple ci-dessus vient du guide) |
| `matchups[]` | liste | oui | triée par `games` décroissant |

Une ligne : `champion` et `opponent` = identifiants Data Dragon ; `lane` ∈ `TOP`, `JUNGLE`, `MIDDLE`, `BOTTOM`, `UTILITY` ; `games` ≥ 1 ; `wins` ≤ `games`. Par construction chaque paire est écrite dans les deux sens (A contre B et B contre A) ; un vieillissement peut en supprimer un seul côté.

## Garanties attendues par l'application

- Un champion avec au moins un adversaire à 8 parties ou plus ne reçoit pas un état « sans données » (seuil `MatchupService.minGames`).
- Chaque champion du fichier reçoit des contre-picks et des points forts (tests sur le vrai fichier).
- La note de provenance affiche `patch` tel quel, au pluriel si c'est une plage.
- Changer l'ordre ou ajouter des champs n'invalide pas l'application ; supprimer `matchups`, `patch` ou `matches` la dégrade.
