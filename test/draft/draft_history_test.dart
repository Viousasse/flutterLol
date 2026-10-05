import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/draft/models/draft_record.dart';
import 'package:monapp/draft/models/draft_report.dart';
import 'package:monapp/draft/models/draft_state.dart';
import 'package:monapp/draft/services/draft_history_stats.dart';
import 'package:monapp/draft/services/draft_history_store.dart';
import 'package:monapp/draft/services/draft_share_text.dart';
import 'package:monapp/team/constants/team_roles.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'draft_support.dart';

DraftRecord _record({
  String id = 'a',
  bool versusFriend = false,
  DraftWinner winner = DraftWinner.blue,
  List<String>? blue,
  List<String>? red,
  List<String> blueBans = const [],
  List<String> redBans = const [],
  String verdict = 'Verdict.',
  DateTime? playedAt,
}) {
  final blueIds = blue ?? [for (var i = 0; i < teamRoles.length; i++) 'B$i'];
  final redIds = red ?? [for (var i = 0; i < teamRoles.length; i++) 'R$i'];

  return DraftRecord(
    id: id,
    playedAt: playedAt ?? DateTime(2026, 10, 5, 15, 42),
    versusFriend: versusFriend,
    blueName: versusFriend ? 'Léa' : 'Vous',
    redName: versusFriend ? 'Tom' : 'Le site',
    blue: blueIds,
    red: redIds,
    blueBans: blueBans,
    redBans: redBans,
    championNames: {
      for (final id in [...blueIds, ...redIds, ...blueBans, ...redBans])
        if (id.isNotEmpty) id: 'Nom $id',
    },
    winner: winner,
    blueScore: 3.5,
    redScore: 1.5,
    verdict: verdict,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DraftRecord', () {
    test('se relit tel qu il a été écrit', () {
      final original = _record(
        versusFriend: true,
        blueBans: ['X1', 'X2'],
        redBans: ['Y1'],
      );

      final copy = DraftRecord.tryFromJson(
        jsonDecode(jsonEncode(original.toJson())),
      )!;

      expect(copy.id, original.id);
      expect(copy.playedAt, original.playedAt);
      expect(copy.versusFriend, isTrue);
      expect(copy.blueName, 'Léa');
      expect(copy.blue, original.blue);
      expect(copy.redBans, ['Y1']);
      expect(copy.nameOf('B0'), 'Nom B0');
      expect(copy.winner, DraftWinner.blue);
      expect(copy.blueScore, 3.5);
    });

    test('une entrée illisible est écartée au lieu de planter', () {
      expect(DraftRecord.tryFromJson('pas une table'), isNull);
      expect(DraftRecord.tryFromJson({'id': 'a'}), isNull);

      final broken = _record().toJson()..['blue'] = ['seulement un'];
      expect(DraftRecord.tryFromJson(broken), isNull);

      final unknownWinner = _record().toJson()..['winner'] = 'personne';
      expect(DraftRecord.tryFromJson(unknownWinner), isNull);
    });

    test('un nom inconnu retombe sur l identifiant', () {
      expect(_record().nameOf('Inconnu'), 'Inconnu');
    });

    test('garde la draft et son bilan', () {
      var state = DraftState.empty(withBans: true);
      while (state.isBanPhase) {
        state = state.ban(state.nextSide!, champion('Ban${state.banCount}'));
      }
      for (var role = 0; role < teamRoles.length; role++) {
        state = state.pick(DraftSide.blue, role, champion('Blue$role'));
        state = state.pick(DraftSide.red, role, champion('Red$role'));
      }
      const report = DraftReport(
        criteria: [],
        blueScore: 4,
        redScore: 1,
        winner: DraftWinner.blue,
        verdict: 'Bleu gagne.',
        strengths: [],
        improvements: [],
      );

      final record = DraftRecord.from(
        id: 'z',
        playedAt: DateTime(2026, 1, 1),
        state: state,
        report: report,
        versusFriend: false,
        blueName: 'Vous',
        redName: 'Le site',
      );

      expect(record.blue, [for (var i = 0; i < 5; i++) 'Blue$i']);
      expect(record.red.first, 'Red0');
      expect(record.blueBans, hasLength(5));
      expect(record.nameOf('Ban0'), 'Ban0');
      expect(record.winner, DraftWinner.blue);
      expect(record.verdict, 'Bleu gagne.');
    });
  });

  group('DraftHistoryStore', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      DraftHistoryStore.records.value = const [];
      await DraftHistoryStore.clear();
    });

    test('ajoute, remplace et supprime des drafts', () async {
      await DraftHistoryStore.add(_record(id: 'a'));
      await DraftHistoryStore.add(_record(id: 'b'));
      expect(DraftHistoryStore.records.value.map((r) => r.id), ['b', 'a']);

      // Rejouer le même identifiant remplace la draft sans la dupliquer.
      await DraftHistoryStore.add(_record(id: 'a', verdict: 'Nouveau'));
      expect(DraftHistoryStore.records.value.map((r) => r.id), ['a', 'b']);
      expect(DraftHistoryStore.records.value.first.verdict, 'Nouveau');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('draft_history'), hasLength(2));

      await DraftHistoryStore.delete('a');
      expect(DraftHistoryStore.records.value.map((r) => r.id), ['b']);
      expect(prefs.getStringList('draft_history'), hasLength(1));

      await DraftHistoryStore.clear();
      expect(DraftHistoryStore.records.value, isEmpty);
      expect(prefs.getStringList('draft_history'), isEmpty);
    });

    test('oublie les plus anciennes au-delà de la limite', () async {
      for (var index = 0; index < DraftHistoryStore.maxRecords + 5; index++) {
        await DraftHistoryStore.add(_record(id: '$index'));
      }

      final ids = DraftHistoryStore.records.value.map((r) => r.id).toList();
      expect(ids, hasLength(DraftHistoryStore.maxRecords));
      // La plus récente est en tête, la plus ancienne conservée en queue.
      expect(ids.first, '${DraftHistoryStore.maxRecords + 4}');
      expect(ids.last, '5');
    });
  });

  group('DraftHistoryStats', () {
    test('un historique vide ne donne aucun taux', () {
      final stats = DraftHistoryStats.of(const []);

      expect(stats.total, 0);
      expect(stats.winRate, isNull);
      expect(stats.mostPicked, isEmpty);
    });

    test('compte les victoires, égalités et défaites contre le site', () {
      final stats = DraftHistoryStats.of([
        _record(id: '1', winner: DraftWinner.blue),
        _record(id: '2', winner: DraftWinner.blue),
        _record(id: '3', winner: DraftWinner.red),
        _record(id: '4', winner: DraftWinner.tie),
      ]);

      expect(stats.total, 4);
      expect(stats.againstSite, 4);
      expect(stats.wins, 2);
      expect(stats.losses, 1);
      expect(stats.ties, 1);
      expect(stats.winRate, 0.5);
    });

    test('une draft à deux compte dans le total mais pas dans le taux', () {
      final stats = DraftHistoryStats.of([
        _record(id: '1', winner: DraftWinner.blue),
        _record(id: '2', versusFriend: true, winner: DraftWinner.red),
      ]);

      expect(stats.total, 2);
      expect(stats.againstSite, 1);
      expect(stats.winRate, 1);
      expect(stats.losses, 0);
    });

    test('classe les champions les plus choisis', () {
      final ahri = ['Ahri', 'Garen', 'Lux', 'Jinx', 'Thresh'];
      final stats = DraftHistoryStats.of([
        _record(id: '1', blue: ahri),
        _record(id: '2', blue: ahri),
        _record(id: '3', blue: ['Ahri', 'Zed', 'Lux', 'Jinx', 'Thresh']),
      ]);

      expect(stats.mostPicked.first.championId, 'Ahri');
      expect(stats.mostPicked.first.count, 3);
      expect(stats.mostPicked.length, DraftHistoryStats.topCount);
    });

    test('contre le site, seuls les choix du joueur comptent', () {
      final stats = DraftHistoryStats.of([_record()]);

      final ids = stats.mostPicked.map((pick) => pick.championId);
      expect(ids, everyElement(startsWith('B')));
    });

    test('à deux, les choix des deux joueurs comptent', () {
      // Zed n'est choisi que par le camp rouge, mais deux fois : il doit
      // passer devant les champions du bleu choisis une seule fois.
      final stats = DraftHistoryStats.of([
        _record(
          versusFriend: true,
          blue: ['A', 'B', 'C', 'D', 'E'],
          red: ['Zed', 'R1', 'R2', 'R3', 'R4'],
        ),
        _record(
          id: 'b',
          versusFriend: true,
          blue: ['F', 'G', 'H', 'I', 'J'],
          red: ['Zed', 'S1', 'S2', 'S3', 'S4'],
        ),
      ]);

      expect(stats.mostPicked.first.championId, 'Zed');
      expect(stats.mostPicked.first.count, 2);
    });

    test('ignore un rôle resté vide', () {
      final stats = DraftHistoryStats.of([
        _record(blue: ['Ahri', '', '', '', '']),
      ]);

      expect(stats.mostPicked.map((p) => p.championId), isNot(contains('')));
    });
  });

  group('DraftShareText', () {
    test('résume les équipes, les bannis et le verdict', () {
      final text = DraftShareText.of(
        _record(
          versusFriend: true,
          blueBans: ['X1', 'X2'],
          verdict: 'La draft de Léa est meilleure.',
        ),
      );

      expect(text, contains('Léa contre Tom'));
      expect(text, contains('${teamRoles.first} : Nom B0'));
      expect(text, contains('Bannis : Nom X1, Nom X2'));
      expect(text, contains('Score : 3,5 contre 1,5'));
      expect(text, contains('Meilleure draft : Léa'));
      expect(text, contains('La draft de Léa est meilleure.'));
    });

    test('n écrit pas de ligne « Bannis » sans bannissements', () {
      expect(DraftShareText.of(_record()), isNot(contains('Bannis')));
    });

    test('dit quand les deux drafts se valent', () {
      final text = DraftShareText.of(_record(winner: DraftWinner.tie));

      expect(text, contains('Les deux drafts se valent.'));
    });

    test('marque un rôle vide d un tiret', () {
      final text = DraftShareText.of(_record(blue: ['Ahri', '', '', '', '']));

      expect(text, contains('${teamRoles[1]} : —'));
    });
  });
}
