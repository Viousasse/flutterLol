import 'package:monapp/champions/models/champion.dart';
import 'package:monapp/champions/models/champion_detail.dart';
import 'package:monapp/champions/models/champion_stats.dart';
import 'package:monapp/matchups/models/matchup.dart';
import 'package:monapp/team/models/team_member.dart';

const noControlSpell = 'Inflige des dégâts à la cible.';
const stunSpell = 'Étourdit la cible pendant une seconde.';

Champion champion(
  String id, {
  int attack = 5,
  int defense = 3,
  int magic = 5,
  List<String> tags = const ['Fighter'],
}) {
  return Champion(
    id: id,
    name: id,
    title: 'titre',
    blurb: '',
    imageUrl: '',
    tags: tags,
    attackRating: attack,
    defenseRating: defense,
    magicRating: magic,
  );
}

/// Un champion et sa fiche, avec `stunSpells` sorts de contrôle sur quatre.
TeamMember member(
  String id, {
  int attack = 5,
  int defense = 3,
  int magic = 5,
  List<String> tags = const ['Fighter'],
  int stunSpells = 0,
}) {
  final spells = [
    for (var index = 0; index < 4; index++)
      ChampionAbility(
        name: 'Sort',
        description: index < stunSpells ? stunSpell : noControlSpell,
        imageUrl: '',
      ),
  ];

  return TeamMember(
    champion: champion(
      id,
      attack: attack,
      defense: defense,
      magic: magic,
      tags: tags,
    ),
    detail: ChampionDetail(
      id: id,
      name: id,
      title: 'titre',
      lore: '',
      tags: tags,
      passive: ChampionAbility(
        name: 'Passif',
        description: noControlSpell,
        imageUrl: '',
      ),
      spells: spells,
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

Matchup duel(
  String champion,
  String opponent, {
  required String lane,
  required int games,
  required int wins,
}) {
  return Matchup(
    championId: champion,
    opponentId: opponent,
    lane: lane,
    games: games,
    wins: wins,
  );
}

MatchupDataset dataset(List<Matchup> matchups) {
  return MatchupDataset(patch: '16.18', matches: 100, matchups: matchups);
}
