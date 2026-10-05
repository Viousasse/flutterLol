import '../../team/constants/team_roles.dart';
import 'draft_report.dart';
import 'draft_state.dart';

/// Une draft terminée, telle qu'on la garde dans l'historique.
///
/// Elle porte les noms des champions en plus de leurs identifiants : le
/// résumé à partager et l'historique se lisent sans recharger la liste des
/// champions.
class DraftRecord {
  final String id;
  final DateTime playedAt;

  /// Vrai pour une draft à deux ; faux contre le site.
  final bool versusFriend;
  final String blueName;
  final String redName;

  /// Identifiants des champions, dans l'ordre des rôles. Un rôle vide donne
  /// une chaîne vide.
  final List<String> blue;
  final List<String> red;
  final List<String> blueBans;
  final List<String> redBans;

  /// Nom affichable de chaque identifiant.
  final Map<String, String> championNames;

  final DraftWinner winner;
  final double blueScore;
  final double redScore;
  final String verdict;

  const DraftRecord({
    required this.id,
    required this.playedAt,
    required this.versusFriend,
    required this.blueName,
    required this.redName,
    required this.blue,
    required this.red,
    required this.blueBans,
    required this.redBans,
    required this.championNames,
    required this.winner,
    required this.blueScore,
    required this.redScore,
    required this.verdict,
  });

  /// Garde la draft [state] et son bilan [report].
  factory DraftRecord.from({
    required String id,
    required DateTime playedAt,
    required DraftState state,
    required DraftReport report,
    required bool versusFriend,
    required String blueName,
    required String redName,
  }) {
    List<String> ids(List<dynamic> champions) => [
      for (final champion in champions) champion?.id ?? '',
    ];

    final names = <String, String>{
      for (final champion in [
        ...state.blue,
        ...state.red,
        ...state.blueBans,
        ...state.redBans,
      ])
        if (champion != null) champion.id: champion.name,
    };

    return DraftRecord(
      id: id,
      playedAt: playedAt,
      versusFriend: versusFriend,
      blueName: blueName,
      redName: redName,
      blue: ids(state.blue),
      red: ids(state.red),
      blueBans: ids(state.blueBans),
      redBans: ids(state.redBans),
      championNames: names,
      winner: report.winner,
      blueScore: report.blueScore,
      redScore: report.redScore,
      verdict: report.verdict,
    );
  }

  String nameOf(String championId) => championNames[championId] ?? championId;

  Map<String, dynamic> toJson() => {
    'id': id,
    'playedAt': playedAt.toIso8601String(),
    'versusFriend': versusFriend,
    'blueName': blueName,
    'redName': redName,
    'blue': blue,
    'red': red,
    'blueBans': blueBans,
    'redBans': redBans,
    'names': championNames,
    'winner': winner.name,
    'blueScore': blueScore,
    'redScore': redScore,
    'verdict': verdict,
  };

  /// Lit une draft enregistrée, ou renvoie `null` si l'entrée est illisible :
  /// une seule entrée corrompue ne doit pas faire perdre tout l'historique.
  static DraftRecord? tryFromJson(dynamic raw) {
    if (raw is! Map) return null;

    List<String>? strings(dynamic value) {
      if (value is! List) return null;

      return value.map((entry) => '$entry').toList();
    }

    final id = raw['id'];
    final playedAt = DateTime.tryParse('${raw['playedAt']}');
    final blue = strings(raw['blue']);
    final red = strings(raw['red']);
    final names = raw['names'];
    final winner = DraftWinner.values
        .where((value) => value.name == raw['winner'])
        .firstOrNull;

    if (id is! String ||
        playedAt == null ||
        blue == null ||
        red == null ||
        blue.length != teamRoles.length ||
        red.length != teamRoles.length ||
        names is! Map ||
        winner == null) {
      return null;
    }

    return DraftRecord(
      id: id,
      playedAt: playedAt,
      versusFriend: raw['versusFriend'] == true,
      blueName: '${raw['blueName'] ?? 'Vous'}',
      redName: '${raw['redName'] ?? 'Le site'}',
      blue: blue,
      red: red,
      blueBans: strings(raw['blueBans']) ?? const [],
      redBans: strings(raw['redBans']) ?? const [],
      championNames: {
        for (final entry in names.entries) '${entry.key}': '${entry.value}',
      },
      winner: winner,
      blueScore: (raw['blueScore'] as num?)?.toDouble() ?? 0,
      redScore: (raw['redScore'] as num?)?.toDouble() ?? 0,
      verdict: '${raw['verdict'] ?? ''}',
    );
  }
}
