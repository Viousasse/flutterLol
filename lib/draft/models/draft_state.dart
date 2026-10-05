import '../../champions/models/champion.dart';
import '../../team/constants/team_roles.dart';

enum DraftSide {
  blue,
  red;

  DraftSide get opposite => this == blue ? red : blue;
}

/// Ordre des choix : le camp bleu ouvre, puis les camps se répondent par deux,
/// comme en partie classée. Le camp rouge a donc le dernier mot.
const draftPickOrder = [
  DraftSide.blue,
  DraftSide.red,
  DraftSide.red,
  DraftSide.blue,
  DraftSide.blue,
  DraftSide.red,
  DraftSide.red,
  DraftSide.blue,
  DraftSide.blue,
  DraftSide.red,
];

/// Nombre de bannissements par camp quand ils sont activés.
const bansPerSide = 5;

/// Les bannissements alternent un à un, le bleu en premier, avant le moindre
/// choix : chaque camp écarte cinq champions que personne ne pourra jouer.
const draftBanOrder = [
  DraftSide.blue,
  DraftSide.red,
  DraftSide.blue,
  DraftSide.red,
  DraftSide.blue,
  DraftSide.red,
  DraftSide.blue,
  DraftSide.red,
  DraftSide.blue,
  DraftSide.red,
];

/// Les champions choisis par chaque camp, un par rôle, et ceux qu'il a bannis.
///
/// L'état est immuable : chaque choix en produit un nouveau, ce qui permet à
/// l'écran de comparer l'avant et l'après sans surprise.
class DraftState {
  final List<Champion?> blue;
  final List<Champion?> red;

  /// Les bannissements de chaque camp. Listes vides quand la draft se joue
  /// sans bannissements.
  final List<Champion?> blueBans;
  final List<Champion?> redBans;

  const DraftState._(this.blue, this.red, this.blueBans, this.redBans);

  factory DraftState.empty({bool withBans = false}) {
    final bans = withBans ? bansPerSide : 0;

    return DraftState._(
      List.filled(teamRoles.length, null),
      List.filled(teamRoles.length, null),
      List.filled(bans, null),
      List.filled(bans, null),
    );
  }

  List<Champion?> teamOf(DraftSide side) => side == DraftSide.blue ? blue : red;

  List<Champion?> bansOf(DraftSide side) =>
      side == DraftSide.blue ? blueBans : redBans;

  bool get hasBans => blueBans.isNotEmpty;

  int get pickCount {
    return [...blue, ...red].where((champion) => champion != null).length;
  }

  int get banCount {
    return [...blueBans, ...redBans].where((c) => c != null).length;
  }

  int get totalBans => blueBans.length + redBans.length;

  /// Vrai tant que tous les bannissements ne sont pas faits : aucun choix
  /// n'est possible avant.
  bool get isBanPhase => banCount < totalBans;

  bool get isComplete => pickCount >= draftPickOrder.length;

  /// Le camp qui doit jouer (bannir pendant la phase de bannissements, sinon
  /// choisir), ou `null` quand la draft est terminée.
  DraftSide? get nextSide {
    if (isBanPhase) return draftBanOrder[banCount];

    return isComplete ? null : draftPickOrder[pickCount];
  }

  /// Les champions déjà choisis, sans les bannis.
  Set<String> get pickedIds => {
    for (final champion in [...blue, ...red]) ?champion?.id,
  };

  /// Les champions que plus personne ne peut prendre : choisis ou bannis.
  Set<String> get unavailableIds => {
    ...pickedIds,
    for (final champion in [...blueBans, ...redBans]) ?champion?.id,
  };

  /// Place [champion] au rôle [roleIndex] du camp [side].
  ///
  /// Refuse un rôle déjà pris ou un champion déjà choisi ou banni : dans une
  /// vraie draft, ni l'un ni l'autre n'est possible.
  DraftState pick(DraftSide side, int roleIndex, Champion champion) {
    if (isBanPhase) {
      throw StateError('Les bannissements ne sont pas terminés.');
    }
    if (teamOf(side)[roleIndex] != null) {
      throw StateError('Le rôle ${teamRoles[roleIndex]} est déjà pris.');
    }
    if (unavailableIds.contains(champion.id)) {
      throw StateError('${champion.name} est déjà choisi ou banni.');
    }

    final updated = [...teamOf(side)]..[roleIndex] = champion;

    return side == DraftSide.blue
        ? DraftState._(updated, red, blueBans, redBans)
        : DraftState._(blue, updated, blueBans, redBans);
  }

  /// Bannit [champion] pour le camp [side] : il prend la première case libre.
  DraftState ban(DraftSide side, Champion champion) {
    if (!isBanPhase) {
      throw StateError('Les bannissements sont terminés.');
    }
    if (nextSide != side) {
      throw StateError('Ce n’est pas au tour de ce camp de bannir.');
    }
    if (unavailableIds.contains(champion.id)) {
      throw StateError('${champion.name} est déjà choisi ou banni.');
    }

    final slots = [...bansOf(side)];
    slots[slots.indexOf(null)] = champion;

    return side == DraftSide.blue
        ? DraftState._(blue, red, slots, redBans)
        : DraftState._(blue, red, blueBans, slots);
  }
}
