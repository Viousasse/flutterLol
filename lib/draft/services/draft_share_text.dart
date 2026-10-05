import '../../team/constants/team_roles.dart';
import '../models/draft_record.dart';
import '../models/draft_report.dart';

/// Le résumé d'une draft en texte brut, à coller dans un message.
class DraftShareText {
  static String of(DraftRecord record) {
    final lines = <String>[
      'Draft League of Legends : ${record.blueName} contre ${record.redName}',
      '',
      ..._team(record, record.blueName, record.blue, record.blueBans),
      '',
      ..._team(record, record.redName, record.red, record.redBans),
      '',
      'Score : ${_score(record.blueScore)} contre ${_score(record.redScore)}',
      _winnerLine(record),
    ];

    if (record.verdict.isNotEmpty) lines.add(record.verdict);

    return lines.join('\n');
  }

  static List<String> _team(
    DraftRecord record,
    String owner,
    List<String> picks,
    List<String> bans,
  ) {
    final banned = [
      for (final id in bans)
        if (id.isNotEmpty) record.nameOf(id),
    ];

    return [
      owner,
      for (var index = 0; index < teamRoles.length; index++)
        '  ${teamRoles[index]} : ${_name(record, picks[index])}',
      if (banned.isNotEmpty) '  Bannis : ${banned.join(', ')}',
    ];
  }

  static String _name(DraftRecord record, String id) {
    return id.isEmpty ? '—' : record.nameOf(id);
  }

  static String _winnerLine(DraftRecord record) {
    return switch (record.winner) {
      DraftWinner.blue => 'Meilleure draft : ${record.blueName}',
      DraftWinner.red => 'Meilleure draft : ${record.redName}',
      DraftWinner.tie => 'Les deux drafts se valent.',
    };
  }

  static String _score(double score) {
    return score == score.roundToDouble()
        ? '${score.round()}'
        : score.toStringAsFixed(1).replaceAll('.', ',');
  }
}
