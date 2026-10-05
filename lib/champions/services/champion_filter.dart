import '../../regions/constants/champion_regions.dart';
import '../../shared/text/search_text.dart';
import '../../regions/models/lore_region.dart';
import '../models/champion.dart';
import '../models/champion_sort.dart';

/// Filtres et tri de la liste des champions, hors de l'écran pour pouvoir être
/// testés sans le monter.
class ChampionFilter {
  /// [winRates] associe l'identifiant d'un champion à son taux de victoire
  /// global. Un champion absent de la table (pas assez de parties) passe après
  /// tous ceux qui y figurent quand on trie par taux de victoire.
  static List<Champion> apply(
    List<Champion> champions, {
    String query = '',
    String? role,
    RegionId? region,
    ChampionSort sort = ChampionSort.name,
    Map<String, double> winRates = const {},
  }) {
    final normalizedQuery = normalizeSearchText(query);

    final list = champions.where((champion) {
      final matchesQuery = normalizeSearchText(
        champion.name,
      ).contains(normalizedQuery);
      final matchesRole = role == null || champion.tags.contains(role);
      final matchesRegion =
          region == null || championRegions[champion.id] == region;

      return matchesQuery && matchesRole && matchesRegion;
    }).toList();

    list.sort((a, b) {
      switch (sort) {
        case ChampionSort.name:
          return a.name.compareTo(b.name);
        case ChampionSort.difficultyAsc:
          return _byDifficulty(a, b, 1);
        case ChampionSort.difficultyDesc:
          return _byDifficulty(a, b, -1);
        case ChampionSort.winRate:
          return _byWinRate(a, b, winRates);
      }
    });

    return list;
  }

  /// À difficulté égale, l'ordre alphabétique garde une liste stable.
  static int _byDifficulty(Champion a, Champion b, int direction) {
    final byDifficulty = a.difficulty.compareTo(b.difficulty) * direction;

    return byDifficulty != 0 ? byDifficulty : a.name.compareTo(b.name);
  }

  static int _byWinRate(
    Champion a,
    Champion b,
    Map<String, double> winRates,
  ) {
    final rateA = winRates[a.id];
    final rateB = winRates[b.id];

    if (rateA == null && rateB == null) return a.name.compareTo(b.name);
    if (rateA == null) return 1;
    if (rateB == null) return -1;

    final byRate = rateB.compareTo(rateA);

    return byRate != 0 ? byRate : a.name.compareTo(b.name);
  }
}
