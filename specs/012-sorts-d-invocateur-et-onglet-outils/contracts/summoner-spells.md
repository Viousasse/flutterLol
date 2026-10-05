# Contrat : sorts d'invocateur

## `SummonerSpellRecommender` (`lib/summoner_spells/services/summoner_spell_recommender.dart`)

```dart
class SummonerSpellPlan {
  final List<String> spellIds;   // deux identifiants Riot
  final String reason;           // phrase en français
  const SummonerSpellPlan({required this.spellIds, required this.reason});
}

class SummonerSpellRecommender {
  static const flash = 'SummonerFlash';
  static const smite = 'SummonerSmite';
  static const ignite = 'SummonerDot';
  static const teleport = 'SummonerTeleport';
  static const heal = 'SummonerHeal';
  static const exhaust = 'SummonerExhaust';

  /// lane : TOP, JUNGLE, MIDDLE, BOTTOM, UTILITY ou null (inconnue).
  /// Le profil est tags.first, ou 'Fighter' si tags est vide.
  static SummonerSpellPlan recommend({required List<String> tags, String? lane});
}
```

Pure, déterministe, sans E/S. Toujours deux identifiants et une raison non vide, pour toute valeur de `tags` et de `lane` (une voie inconnue de la table retombe sur le profil).

## `SummonerSpellService` (`lib/summoner_spells/services/summoner_spell_service.dart`)

```dart
class SummonerSpellService {
  /// Sorts de la partie classique, par identifiant Riot.
  /// Télécharge summoner.json une seule fois (futur et résultat en cache) ;
  /// un échec n'est pas mis en cache et ressort en exception de Data Dragon.
  static Future<Map<String, SummonerSpell>> fetchAll();

  /// Résout des identifiants dans l'ordre donné ; un identifiant inconnu est ignoré.
  static Future<List<SummonerSpell>> byIds(List<String> ids);
}
```

## `SummonerSpell` (`lib/summoner_spells/models/summoner_spell.dart`)

```dart
const SummonerSpell({required String id, required String name,
    required String description, required String imageUrl, required int cooldown});
factory SummonerSpell.fromJson(Map<String, dynamic> json, String version);
static bool isClassic(Map<String, dynamic> json);
```

## Widget

```dart
// lib/champion_detail/widgets/summoner_spell_section/summoner_spell_section.dart
SummonerSpellSection({required List<SummonerSpell> spells, required String reason});
```

Affiche chaque sort (icône 44 px, nom, recharge en `N s` si > 0, description) puis la raison en italique.

## Consommateur

`lib/champion_detail/champion_detail_page.dart` : `loadSummonerSpells(tags)` appelle `MatchupService.load()`, `MatchupService.mainLaneOf`, `SummonerSpellRecommender.recommend` puis `SummonerSpellService.byIds` ; toute exception est avalée.
