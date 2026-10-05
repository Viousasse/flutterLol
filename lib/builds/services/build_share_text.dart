import '../../items/models/item.dart';
import '../models/build.dart';
import 'build_share_code.dart';
import 'build_stats.dart';

/// Le résumé d'une build en texte brut, à coller dans un message.
class BuildShareText {
  /// [items] sont les objets de [build] dans l'ordre ; un objet disparu des
  /// données de Riot n'y figure plus. [championName] est `null` si la build ne
  /// vise aucun champion.
  static String of(Build build, List<Item> items, String? championName) {
    final title = championName == null
        ? 'Build « ${build.name} »'
        : 'Build « ${build.name} » pour $championName';

    return [
      title,
      if (items.isEmpty)
        'Aucun objet.'
      else ...[
        for (var index = 0; index < items.length; index++)
          '${index + 1}. ${items[index].name}',
        'Total : ${BuildStats.totalGold(items)} or',
      ],
      'Code : ${BuildShareCode.encode(build)}',
    ].join('\n');
  }
}
