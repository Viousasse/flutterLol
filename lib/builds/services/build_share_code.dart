import '../../shared/services/share_code/share_code.dart';
import '../models/build.dart';
import 'build_store.dart';

/// Le code compact d'une build, à envoyer à un ami qui le colle dans son
/// application.
class BuildShareCode {
  static const prefix = 'LOLB1.';

  /// Au-delà, un nom collé n'est plus un nom : on refuse le code plutôt que de
  /// le tronquer en silence.
  static const maxNameLength = 60;

  static String encode(Build build) {
    return ShareCode.encode(prefix, {
      'n': build.name,
      'c': ?build.championId,
      'i': build.itemIds,
    });
  }

  static String _lastId = '';

  /// L'horloge peut rendre deux fois la même microseconde quand on lit deux
  /// codes d'affilée : on attend la suivante pour que deux builds importées
  /// n'aient jamais le même identifiant.
  static String _freshId() {
    var id = BuildStore.newId();
    while (id == _lastId) {
      id = BuildStore.newId();
    }

    return _lastId = id;
  }

  /// Relit la première build trouvée dans [text], ou `null` si le texte n'en
  /// contient pas de valide. Elle reçoit un nouvel `id` : l'ami garde sa propre
  /// copie, indépendante de l'original.
  static Build? decode(String text) {
    final payload = ShareCode.decode(prefix, text);
    if (payload == null) return null;

    final name = payload['n'];
    final championId = payload['c'];
    final itemIds = payload['i'];

    if (name is! String || name.isEmpty || name.length > maxNameLength) {
      return null;
    }
    if (championId != null && championId is! String) return null;
    if (itemIds is! List ||
        itemIds.length > Build.maxItems ||
        itemIds.any((id) => id is! String)) {
      return null;
    }

    return Build(
      id: _freshId(),
      name: name,
      championId: championId as String?,
      itemIds: itemIds.cast<String>(),
    );
  }
}
