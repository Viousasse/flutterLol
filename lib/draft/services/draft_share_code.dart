import '../../shared/services/share_code/share_code.dart';
import '../../team/constants/team_roles.dart';
import '../models/draft_record.dart';
import '../models/draft_report.dart';
import 'draft_history_store.dart';

/// Le code compact d'une draft terminée, à envoyer à un ami qui le colle dans
/// son application.
class DraftShareCode {
  static const prefix = 'LOLD1.';

  /// Garde-fous sur un code venu de l'extérieur.
  static const maxNameLength = 40;
  static const maxVerdictLength = 300;
  static const maxBansPerSide = 10;

  static String encode(DraftRecord record) {
    return ShareCode.encode(prefix, {
      't': record.playedAt.toIso8601String(),
      'f': record.versusFriend,
      'bn': record.blueName,
      'rn': record.redName,
      'b': record.blue,
      'r': record.red,
      'bb': record.blueBans,
      'rb': record.redBans,
      'nm': record.championNames,
      'w': record.winner.name,
      'bs': record.blueScore,
      'rs': record.redScore,
      'v': record.verdict,
      'a': record.assisted,
    });
  }

  /// Relit la première draft trouvée dans [text], ou `null` si le texte n'en
  /// contient pas de valide. Elle reçoit un nouvel `id` et garde la date de la
  /// partie d'origine.
  static DraftRecord? decode(String text) {
    final payload = ShareCode.decode(prefix, text);
    if (payload == null) return null;

    final playedAt = DateTime.tryParse('${payload['t']}');
    final blue = _strings(payload['b'], exactly: teamRoles.length);
    final red = _strings(payload['r'], exactly: teamRoles.length);
    final blueBans = _strings(payload['bb'] ?? const [], max: maxBansPerSide);
    final redBans = _strings(payload['rb'] ?? const [], max: maxBansPerSide);
    final names = payload['nm'];
    final winner = DraftWinner.values
        .where((value) => value.name == payload['w'])
        .firstOrNull;
    final blueName = payload['bn'];
    final redName = payload['rn'];
    final verdict = payload['v'] ?? '';

    if (playedAt == null ||
        blue == null ||
        red == null ||
        blueBans == null ||
        redBans == null ||
        names is! Map ||
        winner == null ||
        !_isName(blueName) ||
        !_isName(redName) ||
        verdict is! String ||
        verdict.length > maxVerdictLength) {
      return null;
    }

    final blueScore = payload['bs'];
    final redScore = payload['rs'];
    if (blueScore is! num || redScore is! num) return null;

    return DraftRecord(
      id: _freshId(),
      playedAt: playedAt,
      versusFriend: payload['f'] == true,
      blueName: blueName as String,
      redName: redName as String,
      blue: blue,
      red: red,
      blueBans: blueBans,
      redBans: redBans,
      championNames: {
        for (final entry in names.entries)
          if (entry.value is String) '${entry.key}': entry.value as String,
      },
      winner: winner,
      blueScore: blueScore.toDouble(),
      redScore: redScore.toDouble(),
      verdict: verdict,
      assisted: payload['a'] == true,
      imported: true,
    );
  }

  static String _lastId = '';

  /// L'horloge peut rendre deux fois la même microseconde quand on lit deux
  /// codes d'affilée : on attend la suivante pour que deux drafts importées
  /// n'aient jamais le même identifiant.
  static String _freshId() {
    var id = DraftHistoryStore.newId();
    while (id == _lastId) {
      id = DraftHistoryStore.newId();
    }

    return _lastId = id;
  }

  static bool _isName(dynamic value) {
    return value is String && value.isNotEmpty && value.length <= maxNameLength;
  }

  /// Liste de chaînes de longueur [exactly] (ou au plus [max]), `null` sinon.
  static List<String>? _strings(dynamic value, {int? exactly, int? max}) {
    if (value is! List || value.any((entry) => entry is! String)) return null;
    if (exactly != null && value.length != exactly) return null;
    if (max != null && value.length > max) return null;

    return value.cast<String>();
  }
}
