import '../../matchups/services/lane_profile.dart';
import '../../matchups/services/matchup_service.dart';
import '../../shared/widgets/champion_picker_sheet/champion_role_filter.dart';
import '../constants/team_roles.dart';

/// Construit le filtre par rôle de la feuille de choix d'un champion.
class RoleFilters {
  /// Où chaque champion se joue, d'après les parties analysées, ou `null` si
  /// elles ne se chargent pas : le filtre est un confort, son absence ne doit
  /// jamais empêcher de choisir un champion.
  static Future<LaneProfile?> loadProfile() async {
    try {
      return LaneProfile.fromDataset(await MatchupService.load());
    } catch (_) {
      return null;
    }
  }

  /// Le filtre pour [profile], démarrant sur le rôle d'index [roleIndex] (voir
  /// `teamRoles`) ou sur « Tous » sans lui. `null` sans profil : la feuille
  /// s'affiche alors sans puces.
  static ChampionRoleFilter? forProfile(
    LaneProfile? profile, {
    int? roleIndex,
  }) {
    if (profile == null) return null;

    return ChampionRoleFilter(
      roles: {
        for (var index = 0; index < teamRoles.length; index++)
          teamRoles[index]: teamRoleLanes[index],
      },
      fits: profile.fits,
      initialLane: roleIndex == null ? null : teamRoleLanes[roleIndex],
    );
  }
}
