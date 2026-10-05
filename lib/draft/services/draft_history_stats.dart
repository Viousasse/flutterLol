import '../models/draft_record.dart';
import '../models/draft_report.dart';

/// Un champion et le nombre de fois où il a été choisi.
class PickCount {
  final String championId;
  final String name;
  final int count;

  const PickCount({
    required this.championId,
    required this.name,
    required this.count,
  });
}

/// Les chiffres de l'historique : combien de drafts, combien de victoires
/// contre le site, et les champions qu'on choisit le plus.
class DraftHistoryStats {
  /// Nombre de champions les plus choisis que l'on affiche.
  static const topCount = 5;

  final int total;
  final int againstSite;
  final int wins;
  final int ties;
  final int losses;
  final List<PickCount> mostPicked;

  /// Drafts jouées avec les conseils, tous modes confondus.
  final int assistedCount;

  /// Drafts reçues par code : elles comptent dans le total et les champions,
  /// pas dans le taux de victoire.
  final int importedCount;

  const DraftHistoryStats({
    required this.total,
    required this.againstSite,
    required this.wins,
    required this.ties,
    required this.losses,
    required this.mostPicked,
    this.assistedCount = 0,
    this.importedCount = 0,
  });

  /// Part des drafts contre le site que le joueur a gagnées, ou `null` s'il n'en
  /// a pas encore joué. Les égalités ne comptent ni comme victoire ni comme
  /// défaite, mais restent dans le total.
  double? get winRate => againstSite == 0 ? null : wins / againstSite;

  /// Les statistiques de [records].
  ///
  /// Contre le site, le joueur est le camp bleu : seule cette draft compte
  /// pour ses victoires et ses champions. À deux, les deux camps sont des
  /// joueurs, donc leurs choix comptent tous les deux, mais aucune victoire
  /// n'est attribuée : on ne sait pas qui est « le joueur ».
  factory DraftHistoryStats.of(List<DraftRecord> records) {
    var againstSite = 0;
    var wins = 0;
    var ties = 0;
    var losses = 0;
    final counts = <String, int>{};
    final names = <String, String>{};

    void count(DraftRecord record, List<String> picks) {
      for (final id in picks) {
        if (id.isEmpty) continue;
        counts[id] = (counts[id] ?? 0) + 1;
        names[id] = record.nameOf(id);
      }
    }

    var assistedCount = 0;
    var importedCount = 0;

    for (final record in records) {
      if (record.assisted) assistedCount++;
      if (record.imported) importedCount++;
      count(record, record.blue);
      if (record.versusFriend) {
        count(record, record.red);
        continue;
      }

      // Le joueur d'une draft reçue n'est pas vous.
      if (record.imported) continue;

      // Avec les conseils, la victoire ne mesure plus le niveau du joueur.
      if (record.assisted) continue;

      againstSite++;
      switch (record.winner) {
        case DraftWinner.blue:
          wins++;
        case DraftWinner.red:
          losses++;
        case DraftWinner.tie:
          ties++;
      }
    }

    final ranked = counts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);

        return byCount != 0 ? byCount : names[a.key]!.compareTo(names[b.key]!);
      });

    return DraftHistoryStats(
      total: records.length,
      againstSite: againstSite,
      wins: wins,
      ties: ties,
      losses: losses,
      assistedCount: assistedCount,
      importedCount: importedCount,
      mostPicked: [
        for (final entry in ranked.take(topCount))
          PickCount(
            championId: entry.key,
            name: names[entry.key]!,
            count: entry.value,
          ),
      ],
    );
  }
}
