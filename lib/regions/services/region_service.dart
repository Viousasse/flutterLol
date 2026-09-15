import '../../champions/models/champion.dart';
import '../constants/champion_regions.dart';
import '../models/lore_region.dart';

class RegionService {
  /// Champions rattachés à [id], dans l'ordre alphabétique de la liste reçue.
  static List<Champion> championsOf(RegionId id, List<Champion> champions) {
    if (id == RegionId.unknown) return uncatalogued(champions);

    return champions.where((c) => championRegions[c.id] == id).toList();
  }

  /// Champions qu'aucune entrée de la table ne couvre.
  ///
  /// À distinguer de la région « Sans attache », qui est un choix de l'univers
  /// officiel : ceux-ci sont simplement absents de notre table, en général
  /// parce qu'ils sont sortis après sa rédaction. Les afficher évite qu'un
  /// champion disparaisse silencieusement de la carte.
  static List<Champion> uncatalogued(List<Champion> champions) {
    return champions.where((c) => !championRegions.containsKey(c.id)).toList();
  }

  static int countOf(RegionId id, List<Champion> champions) {
    return championsOf(id, champions).length;
  }
}
