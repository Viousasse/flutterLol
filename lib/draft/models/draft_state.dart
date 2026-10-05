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

/// Les champions choisis par chaque camp, un par rôle.
///
/// L'état est immuable : chaque choix en produit un nouveau, ce qui permet à
/// l'écran de comparer l'avant et l'après sans surprise.
class DraftState {
  final List<Champion?> blue;
  final List<Champion?> red;

  const DraftState._(this.blue, this.red);

  factory DraftState.empty() {
    return DraftState._(
      List.filled(teamRoles.length, null),
      List.filled(teamRoles.length, null),
    );
  }

  List<Champion?> teamOf(DraftSide side) => side == DraftSide.blue ? blue : red;

  int get pickCount {
    return [...blue, ...red].where((champion) => champion != null).length;
  }

  bool get isComplete => pickCount >= draftPickOrder.length;

  /// Le camp qui doit choisir, ou `null` quand la draft est terminée.
  DraftSide? get nextSide => isComplete ? null : draftPickOrder[pickCount];

  Set<String> get pickedIds => {
    for (final champion in [...blue, ...red]) ?champion?.id,
  };

  /// Place [champion] au rôle [roleIndex] du camp [side].
  ///
  /// Refuse un rôle déjà pris ou un champion déjà choisi : dans une vraie
  /// draft, ni l'un ni l'autre n'est possible.
  DraftState pick(DraftSide side, int roleIndex, Champion champion) {
    if (teamOf(side)[roleIndex] != null) {
      throw StateError('Le rôle ${teamRoles[roleIndex]} est déjà pris.');
    }
    if (pickedIds.contains(champion.id)) {
      throw StateError('${champion.name} est déjà choisi.');
    }

    final updated = [...teamOf(side)]..[roleIndex] = champion;

    return side == DraftSide.blue
        ? DraftState._(updated, red)
        : DraftState._(blue, updated);
  }
}
