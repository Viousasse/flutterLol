import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/champions/models/champion.dart';
import 'package:monapp/champions/models/champion_detail.dart';
import 'package:monapp/champions/models/champion_stats.dart';
import 'package:monapp/team/models/team_insight.dart';
import 'package:monapp/team/models/team_member.dart';
import 'package:monapp/team/services/crowd_control.dart';
import 'package:monapp/team/services/team_analyzer.dart';

const _noControl = 'Inflige des dégâts à la cible.';
const _stun = 'Étourdit la cible pendant 1,5 seconde.';

ChampionAbility _ability(String description) {
  return ChampionAbility(name: 'Sort', description: description, imageUrl: '');
}

TeamMember _member(
  String id, {
  required int attack,
  required int magic,
  int defense = 3,
  List<String> tags = const ['Fighter'],
  List<String> spellDescriptions = const [_noControl, _noControl, _noControl, _noControl],
}) {
  return TeamMember(
    champion: Champion(
      id: id,
      name: id,
      title: 'titre',
      blurb: '',
      imageUrl: '',
      tags: tags,
    ),
    detail: ChampionDetail(
      id: id,
      name: id,
      title: 'titre',
      lore: '',
      tags: tags,
      passive: _ability(_noControl),
      spells: spellDescriptions.map(_ability).toList(),
      stats: ChampionStats(
        health: 600,
        armor: 30,
        magicResist: 30,
        attackDamage: 60,
        attackSpeed: 0.65,
        moveSpeed: 340,
        attackRange: 175,
        attackRating: attack,
        defenseRating: defense,
        magicRating: magic,
        difficulty: 5,
      ),
    ),
  );
}

InsightKind _kindOf(TeamAnalysis analysis, String title) {
  return analysis.insights.firstWhere((i) => i.title == title).kind;
}

void main() {
  group('CrowdControl', () {
    test('reconnaît les verbes de contrôle dans une description', () {
      expect(CrowdControl.controls(_stun), isTrue);
      expect(CrowdControl.controls('Charme le premier ennemi touché.'), isTrue);
      expect(CrowdControl.controls('Projette un éclat de glace.'), isFalse);
      expect(CrowdControl.controls(_noControl), isFalse);
    });

    test('compte les sorts qui contrôlent, sans le passif', () {
      final member = _member(
        'Leona',
        attack: 4,
        magic: 3,
        spellDescriptions: [_stun, _noControl, _stun, _noControl],
      );

      expect(CrowdControl.spellCount(member.detail), 2);
    });
  });

  group('TeamAnalyzer', () {
    test('une équipe vide n a ni part de dégâts ni constat', () {
      final analysis = TeamAnalyzer.analyze(const []);

      expect(analysis.physicalShare, 0);
      expect(analysis.magicShare, 0);
      expect(analysis.insights, isEmpty);
    });

    test('répartit les dégâts entre physiques et magiques', () {
      final analysis = TeamAnalyzer.analyze([
        _member('A', attack: 8, magic: 2),
        _member('B', attack: 2, magic: 8),
      ]);

      expect(analysis.physicalShare, closeTo(0.5, 0.001));
      expect(analysis.magicShare, closeTo(0.5, 0.001));
    });

    test('invite à compléter l équipe avant de donner un avis', () {
      final analysis = TeamAnalyzer.analyze([
        _member('A', attack: 9, magic: 1),
        _member('B', attack: 9, magic: 1),
      ]);

      expect(analysis.insights, hasLength(1));
      expect(analysis.insights.single.kind, InsightKind.info);
    });

    test('signale le manque de dégâts magiques', () {
      final team = [
        for (final id in ['A', 'B', 'C', 'D', 'E'])
          _member(id, attack: 9, magic: 1),
      ];

      final analysis = TeamAnalyzer.analyze(team);

      expect(_kindOf(analysis, 'Peu de dégâts magiques'), InsightKind.warning);
    });

    test('signale le manque de dégâts physiques', () {
      final team = [
        for (final id in ['A', 'B', 'C', 'D', 'E'])
          _member(id, attack: 1, magic: 9),
      ];

      final analysis = TeamAnalyzer.analyze(team);

      expect(_kindOf(analysis, 'Peu de dégâts physiques'), InsightKind.warning);
    });

    test('compte la première ligne par le rôle Tank ou la défense', () {
      final analysis = TeamAnalyzer.analyze([
        _member('Tank', attack: 3, magic: 3, tags: ['Tank']),
        _member('Costaud', attack: 5, magic: 2, defense: 8),
        _member('Fragile', attack: 8, magic: 2),
      ]);

      expect(analysis.frontlineCount, 2);
      expect(_kindOf(analysis, 'Première ligne présente'), InsightKind.good);
    });

    test('signale l absence de première ligne', () {
      final analysis = TeamAnalyzer.analyze([
        _member('A', attack: 8, magic: 2),
        _member('B', attack: 3, magic: 8),
        _member('C', attack: 8, magic: 2),
      ]);

      expect(_kindOf(analysis, 'Pas de première ligne'), InsightKind.warning);
    });

    test('mesure le contrôle de l équipe', () {
      const control = [_stun, _stun, _noControl, _noControl];
      final controlled = TeamAnalyzer.analyze([
        _member('A', attack: 5, magic: 5, spellDescriptions: control),
        _member('B', attack: 5, magic: 5, spellDescriptions: control),
        _member('C', attack: 5, magic: 5),
      ]);
      final uncontrolled = TeamAnalyzer.analyze([
        _member('A', attack: 5, magic: 5),
        _member('B', attack: 5, magic: 5),
        _member('C', attack: 5, magic: 5),
      ]);

      expect(controlled.controlSpellCount, 4);
      expect(_kindOf(controlled, 'Contrôle suffisant'), InsightKind.good);
      expect(_kindOf(uncontrolled, 'Peu de contrôle'), InsightKind.warning);
    });

    test('ajoute une précision tant que l équipe n est pas complète', () {
      final incomplete = TeamAnalyzer.analyze([
        _member('A', attack: 5, magic: 5, tags: ['Tank']),
        _member('B', attack: 5, magic: 5),
        _member('C', attack: 5, magic: 5),
        _member('D', attack: 5, magic: 5),
      ]);
      final complete = TeamAnalyzer.analyze([
        _member('A', attack: 5, magic: 5, tags: ['Tank']),
        _member('B', attack: 5, magic: 5),
        _member('C', attack: 5, magic: 5),
        _member('D', attack: 5, magic: 5),
        _member('E', attack: 5, magic: 5),
      ]);

      expect(incomplete.insights.last.kind, InsightKind.info);
      expect(complete.insights.any((i) => i.kind == InsightKind.info), isFalse);
    });
  });
}
