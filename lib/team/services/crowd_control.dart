import '../../champions/models/champion_detail.dart';

/// Repère les sorts de contrôle d'un champion d'après leur description.
///
/// Data Dragon ne dit pas quel sort contrôle l'adversaire. On cherche donc, dans
/// le texte français des quatre sorts, les verbes qui désignent un contrôle
/// dur : l'estimation est honnête mais imparfaite, et l'écran la présente comme
/// telle.
class CrowdControl {
  /// Fragments de mots propres au contrôle. Volontairement étroits : « projette »
  /// ou « provoque » décrivent aussi bien un projectile ou des dégâts.
  static const keywords = [
    'étourdi',
    'immobilis',
    'charme',
    'terrifi',
    'effraie',
    'endort',
    'enracin',
    'entrave',
    'réduit au silence',
    'réduisant au silence',
    'dans les airs',
    'fait tomber',
    'repousse',
    'attire',
    'suspend',
    'paralys',
    'emprisonne',
    'stase',
  ];

  static bool controls(String description) {
    final text = description.toLowerCase();

    return keywords.any(text.contains);
  }

  /// Nombre de sorts (A, Z, E, R) qui contrôlent. Le passif n'est pas compté :
  /// il ne se lance pas.
  static int spellCount(ChampionDetail detail) {
    return detail.spells.where((spell) => controls(spell.description)).length;
  }
}
