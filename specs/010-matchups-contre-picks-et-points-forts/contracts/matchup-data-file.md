# Contrat : fichier de données `assets/data/champion_matchups.json`

Produit par `tool/generate_matchups.dart` (spécification 019), lu par `MatchupDataset.fromJson`. Déclaré dans `pubspec.yaml`.

```json
{
  "generatedAt": "2026-10-05T14:58:39.332198Z",
  "patch": "16.16–16.19",
  "platform": "euw1",
  "rank": "MASTER+",
  "matches": 7600,
  "matchups": [
    { "champion": "Jhin", "opponent": "Yunara", "lane": "BOTTOM", "games": 135, "wins": 63 },
    { "champion": "Yunara", "opponent": "Jhin", "lane": "BOTTOM", "games": 135, "wins": 72 }
  ]
}
```

| Clé | Type | Lue par l'application | Remarque |
|-----|------|-----------------------|----------|
| `generatedAt` | texte ISO 8601 | non | informatif |
| `patch` | texte | oui (`patch`) | peut être une plage `a–b` (tiret demi-cadratin) ; `DataSourceNote` accepte aussi `-` |
| `platform` | texte | non | `euw1` |
| `rank` | texte | non | `MASTER+` ; la note affichée dit « classées Master+ (EUW) » en dur |
| `matches` | entier | oui (`matches`, défaut 0) | parties exploitées |
| `matchups` | liste | oui (défaut vide) | une ligne par champion, adversaire et voie |

Chaque ligne : `champion` (texte), `opponent` (texte), `lane` (`TOP|JUNGLE|MIDDLE|BOTTOM|UTILITY`), `games` (entier), `wins` (entier). Les clés absentes ou de mauvais type d'une ligne font échouer le chargement (conversions `as`).

Contenu actuel : 7 600 parties, 17 284 lignes, 173 champions, répartition par voie TOP 4 890, JUNGLE 3 402, MIDDLE 4 030, BOTTOM 2 524, UTILITY 2 438.

Invariants testés (`test/counters/counter_service_test.dart`) : tout champion présent comme adversaire a au moins un contre-pick ; tout champion présent comme joueur a au moins un adversaire dans `strongAgainst`. `test/matchups/matchup_section_test.dart` vérifie qu'aucune paire ne cite un champion inconnu de Data Dragon.
