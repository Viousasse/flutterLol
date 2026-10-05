import '../models/team_insight.dart';
import '../models/team_member.dart';
import 'crowd_control.dart';

class TeamAnalyzer {
  /// Une équipe complète compte cinq champions.
  static const fullTeamSize = 5;

  /// En dessous, un verdict sur l'équilibre ne repose sur rien : on invite à
  /// compléter l'équipe plutôt que d'alerter à tort.
  static const minMembersForVerdict = 3;

  /// Part minimale de chaque type de dégâts avant de signaler un manque.
  static const minDamageShare = 0.2;

  /// Une jauge de défense de Riot à partir de laquelle un champion tient la
  /// première ligne, même sans le rôle Tank.
  static const frontlineDefense = 7;

  /// Sorts de contrôle attendus pour que l'équipe puisse bloquer une cible.
  static const minControlSpells = 3;

  static TeamAnalysis analyze(List<TeamMember> members) {
    var attack = 0;
    var magic = 0;
    var frontline = 0;
    var control = 0;

    for (final member in members) {
      final stats = member.detail.stats;
      attack += stats.attackRating;
      magic += stats.magicRating;
      control += CrowdControl.spellCount(member.detail);

      final isTank = member.champion.tags.contains('Tank');
      if (isTank || stats.defenseRating >= frontlineDefense) frontline++;
    }

    final damageTotal = attack + magic;
    final physicalShare = damageTotal == 0 ? 0.0 : attack / damageTotal;
    final magicShare = damageTotal == 0 ? 0.0 : magic / damageTotal;

    return TeamAnalysis(
      physicalShare: physicalShare,
      magicShare: magicShare,
      frontlineCount: frontline,
      controlSpellCount: control,
      memberCount: members.length,
      insights: _insights(
        memberCount: members.length,
        physicalShare: physicalShare,
        magicShare: magicShare,
        frontline: frontline,
        control: control,
      ),
    );
  }

  static List<TeamInsight> _insights({
    required int memberCount,
    required double physicalShare,
    required double magicShare,
    required int frontline,
    required int control,
  }) {
    if (memberCount == 0) return const [];

    if (memberCount < minMembersForVerdict) {
      return const [
        TeamInsight(
          kind: InsightKind.info,
          title: 'Équipe incomplète',
          message:
              'Ajoutez au moins trois champions pour obtenir un avis sur '
              "l'équilibre de l'équipe.",
        ),
      ];
    }

    final missing = fullTeamSize - memberCount;

    return [
      _damageInsight(physicalShare, magicShare),
      _frontlineInsight(frontline),
      _controlInsight(control),
      if (missing > 0)
        TeamInsight(
          kind: InsightKind.info,
          title: 'Équipe incomplète',
          message:
              'Il manque $missing champion${missing > 1 ? 's' : ''} : le bilan '
              'peut encore changer.',
        ),
    ];
  }

  static TeamInsight _damageInsight(double physical, double magic) {
    if (magic < minDamageShare) {
      return TeamInsight(
        kind: InsightKind.warning,
        title: 'Peu de dégâts magiques',
        message:
            "Seulement ${_percent(magic)} % de dégâts magiques : l'équipe "
            "adverse peut empiler l'armure.",
      );
    }

    if (physical < minDamageShare) {
      return TeamInsight(
        kind: InsightKind.warning,
        title: 'Peu de dégâts physiques',
        message:
            'Seulement ${_percent(physical)} % de dégâts physiques : '
            "l'équipe adverse peut empiler la résistance magique.",
      );
    }

    return TeamInsight(
      kind: InsightKind.good,
      title: 'Dégâts équilibrés',
      message:
          '${_percent(physical)} % physiques, ${_percent(magic)} % magiques : '
          'difficile à contrer avec un seul type de défense.',
    );
  }

  static TeamInsight _frontlineInsight(int frontline) {
    if (frontline == 0) {
      return const TeamInsight(
        kind: InsightKind.warning,
        title: 'Pas de première ligne',
        message:
            "Aucun tank ni champion très résistant : l'équipe aura du mal à "
            'encaisser et à protéger ses dégâts.',
      );
    }

    return TeamInsight(
      kind: InsightKind.good,
      title: 'Première ligne présente',
      message: frontline == 1
          ? "Un champion peut encaisser pour l'équipe."
          : "$frontline champions peuvent encaisser pour l'équipe.",
    );
  }

  static TeamInsight _controlInsight(int control) {
    const estimate = "estimation d'après les descriptions des sorts";

    if (control < minControlSpells) {
      return TeamInsight(
        kind: InsightKind.warning,
        title: 'Peu de contrôle',
        message:
            '$control sort${control > 1 ? 's' : ''} de contrôle repéré'
            "${control > 1 ? 's' : ''} : difficile de bloquer une cible "
            '($estimate).',
      );
    }

    return TeamInsight(
      kind: InsightKind.good,
      title: 'Contrôle suffisant',
      message: '$control sorts de contrôle repérés ($estimate).',
    );
  }

  static int _percent(double share) => (share * 100).round();
}
