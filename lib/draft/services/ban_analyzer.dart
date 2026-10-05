import '../../matchups/models/matchup.dart';
import '../../matchups/services/matchup_service.dart';
import '../models/draft_report.dart';
import '../models/draft_state.dart';

/// Les remarques sur les bannissements de chaque camp.
class BanAnalysis {
  final List<String> blue;
  final List<String> red;

  const BanAnalysis({required this.blue, required this.red});

  const BanAnalysis.none() : this(blue: const [], red: const []);

  bool get isEmpty => blue.isEmpty && red.isEmpty;
}

/// Juge les bannissements d'une draft terminée.
///
/// Un bannissement est utile quand il écarte un champion qui gagne souvent. On
/// signale aussi le champion fort que personne n'a banni et que l'adversaire a
/// joué : c'est le bannissement qui aurait le plus changé la draft.
class BanAnalyzer {
  /// Taux de victoire global à partir duquel un champion est jugé fort.
  static const strongWinRate = 0.52;

  /// En dessous, un champion qui perd plus qu'il ne gagne : le bannir a peu
  /// servi.
  static const weakWinRate = 0.5;

  /// Nombre maximal de bannissements manqués signalés par camp : au-delà, la
  /// liste noie l'essentiel.
  static const maxMissed = 2;

  /// [blueBans] et [redBans] sont les identifiants bannis ; [bluePicks] et
  /// [redPicks] ceux qui ont été choisis. Sans bannissements, il n'y a rien à
  /// juger. Avec [players], les remarques nomment les joueurs ; sinon elles
  /// s'adressent au joueur (camp bleu) et nomment l'adversaire « le site ».
  static BanAnalysis analyze({
    required List<String> blueBans,
    required List<String> redBans,
    required List<String> bluePicks,
    required List<String> redPicks,
    required MatchupDataset dataset,
    required Map<String, String> names,
    DraftPlayers? players,
  }) {
    final blueBanned = _ids(blueBans);
    final redBanned = _ids(redBans);
    if (blueBanned.isEmpty && redBanned.isEmpty) {
      return const BanAnalysis.none();
    }

    String nameOf(String id) => names[id] ?? id;

    List<String> notes(
      DraftSide side,
      List<String> own,
      List<String> opposingPicks,
    ) {
      final duel = players;
      final subject = duel == null ? 'vous' : duel.of(side);
      final opponent = duel == null ? 'le site' : duel.of(side.opposite);

      return _notesFor(
        own: own,
        allBans: {...blueBanned, ...redBanned},
        opposingPicks: _ids(opposingPicks),
        dataset: dataset,
        nameOf: nameOf,
        subject: subject,
        opponent: opponent,
        secondPerson: duel == null,
      );
    }

    return BanAnalysis(
      blue: notes(DraftSide.blue, blueBanned, redPicks),
      red: notes(DraftSide.red, redBanned, bluePicks),
    );
  }

  static List<String> _ids(List<String> raw) => [
    for (final id in raw)
      if (id.isNotEmpty) id,
  ];

  static List<String> _notesFor({
    required List<String> own,
    required Set<String> allBans,
    required List<String> opposingPicks,
    required MatchupDataset dataset,
    required String Function(String) nameOf,
    required String subject,
    required String opponent,
    required bool secondPerson,
  }) {
    final notes = <String>[];

    String label(String id, OverallRecord record) =>
        '${nameOf(id)} (${_percent(record.winRate)} %)';

    final records = {
      for (final id in own) id: MatchupService.overallFor(id, dataset),
    };

    final good = [
      for (final id in own)
        if (records[id]!.isReliable && records[id]!.winRate >= strongWinRate)
          label(id, records[id]!),
    ];
    final weak = [
      for (final id in own)
        if (records[id]!.isReliable && records[id]!.winRate < weakWinRate)
          label(id, records[id]!),
    ];

    if (good.isNotEmpty) {
      notes.add(
        'Bannissements utiles : ${good.join(', ')}. '
        '${_capital(subject)} ${secondPerson ? 'avez' : 'a'} écarté '
        '${good.length > 1 ? 'des champions' : 'un champion'} qui '
        '${good.length > 1 ? 'gagnent' : 'gagne'} souvent.',
      );
    }

    if (weak.isNotEmpty) {
      notes.add(
        'Bannissements peu utiles : ${weak.join(', ')}. '
        '${weak.length > 1 ? 'Ces champions perdent' : 'Ce champion perd'} '
        'plus souvent qu\'${weak.length > 1 ? 'ils ne gagnent' : 'il ne gagne'} : '
        'un ban sur un champion plus fort aurait mieux servi.',
      );
    }

    // Les champions forts que ni l'un ni l'autre n'a bannis et que l'adversaire
    // a joués : ce sont ceux qu'on aurait dû écarter.
    final missed = <(String, OverallRecord)>[
      for (final id in opposingPicks)
        if (!allBans.contains(id))
          if (MatchupService.overallFor(id, dataset) case final record
              when record.isReliable && record.winRate >= strongWinRate)
            (id, record),
    ]..sort((a, b) => b.$2.winRate.compareTo(a.$2.winRate));

    for (final (id, record) in missed.take(maxMissed)) {
      notes.add(
        '${label(id, record)} n\'a pas été banni et $opponent l\'a joué : '
        'le bannir aurait retiré un de ses bons choix.',
      );
    }

    if (notes.isEmpty) {
      notes.add(
        'Aucune remarque : les données ne permettent pas de juger ces '
        'bannissements, ou ils sont neutres.',
      );
    }

    return notes;
  }

  static int _percent(double rate) => (rate * 100).round();

  static String _capital(String text) {
    return text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
  }
}
