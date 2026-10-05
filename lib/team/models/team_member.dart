import '../../champions/models/champion.dart';
import '../../champions/models/champion_detail.dart';

/// Un champion de l'équipe, avec sa fiche détaillée : l'analyse a besoin de ses
/// jauges et de la description de ses sorts, que la liste ne donne pas.
class TeamMember {
  final Champion champion;
  final ChampionDetail detail;

  const TeamMember({required this.champion, required this.detail});
}
