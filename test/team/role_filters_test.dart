import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/matchups/models/matchup.dart';
import 'package:monapp/matchups/services/lane_profile.dart';
import 'package:monapp/team/constants/team_roles.dart';
import 'package:monapp/team/services/role_filters.dart';

LaneProfile profile() {
  return LaneProfile.fromDataset(
    const MatchupDataset(
      patch: '14.1',
      matches: 100,
      matchups: [
        Matchup(
          championId: 'Garen',
          opponentId: 'Darius',
          lane: 'TOP',
          games: 50,
          wins: 25,
        ),
      ],
    ),
  );
}

void main() {
  group('RoleFilters.forProfile', () {
    test('sans profil, il n\'y a pas de filtre', () {
      expect(RoleFilters.forProfile(null), isNull);
      expect(RoleFilters.forProfile(null, roleIndex: 2), isNull);
    });

    test('propose les cinq rôles dans l\'ordre de l\'équipe', () {
      final filter = RoleFilters.forProfile(profile())!;

      expect(filter.roles.keys.toList(), teamRoles);
      expect(filter.roles.values.toList(), teamRoleLanes);
    });

    test('la case touchée donne la voie de départ', () {
      for (var index = 0; index < teamRoles.length; index++) {
        final filter = RoleFilters.forProfile(profile(), roleIndex: index)!;

        expect(filter.initialLane, teamRoleLanes[index]);
      }
    });

    test('sans rôle de départ, tous les champions sont affichés', () {
      expect(RoleFilters.forProfile(profile())!.initialLane, isNull);
    });

    test('reflète où chaque champion se joue', () {
      final filter = RoleFilters.forProfile(profile())!;

      expect(filter.fits('Garen', 'TOP'), isTrue);
      expect(filter.fits('Garen', 'JUNGLE'), isFalse);
      expect(filter.fits('Inconnu', 'TOP'), isFalse);
    });
  });
}
