import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'matchup_tally.dart';

/// Calcule les matchups champion contre champion à partir de vraies parties
/// classées, via l'API officielle de Riot, et écrit le résultat dans
/// `assets/data/champion_matchups.json`.
///
/// Méthode : on prend des joueurs du classement Master, on lit leurs dernières
/// parties classées en solo/duo (match-v5), et pour chaque voie on met face à
/// face le champion de l'équipe bleue et celui de l'équipe rouge. Le fichier
/// produit compte, pour chaque paire dans chaque voie, le nombre de parties et
/// de victoires. C'est exactement ce que font les sites de statistiques, à une
/// échelle plus modeste : le nombre de parties est conservé pour que l'app
/// puisse taire les chiffres qui reposent sur trop peu de données.
///
///     RIOT_API_KEY=RGAPI-... dart run tool/generate_matchups.dart --matches 400
///
/// Une clé de développement autorise 100 requêtes par 2 minutes : 400 parties
/// prennent une dizaine de minutes.
///
/// Options pour un long calcul :
///
/// * `--output <fichier>` écrit ailleurs que dans les données de l'app, pour ne
///   rien remplacer avant la fin ;
/// * `--resume` reprend là où une exécution interrompue s'est arrêtée : la
///   progression est enregistrée toutes les [_checkpointEvery] parties ;
/// * `--merge-with <fichier>` additionne les résultats d'un fichier existant,
///   par exemple les données actuelles de l'app, au moment d'écrire le fichier
///   final ;
/// * `--decay <0..1>` fait vieillir ce fichier existant avant de l'additionner
///   (0.5 divise son poids par deux) ; 1 par défaut, sans effet ;
/// * `--min-patch X.Y` ignore les parties d'un patch antérieur (comparaison
///   numérique : 16.9 précède 16.10).
///
/// Voir `tool/README.md` pour le guide complet.
const _defaultOutput = 'assets/data/champion_matchups.json';
const _checkpointEvery = 100;
const _soloQueue = 420;
const _lanes = ['TOP', 'JUNGLE', 'MIDDLE', 'BOTTOM', 'UTILITY'];

/// match-v5 n'ecrit pas toujours les noms comme Data Dragon ; l'app cherche les
/// champions par identifiant Data Dragon, donc on aligne ici.
const _nameAliases = {'FiddleSticks': 'Fiddlesticks'};

String _championId(Map<String, dynamic> participant) {
  final name = participant['championName'] as String;
  return _nameAliases[name] ?? name;
}

Future<void> main(List<String> args) async {
  final apiKey = Platform.environment['RIOT_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    stderr.writeln("RIOT_API_KEY manquante dans l'environnement.");
    exit(2);
  }

  final targetMatches = _intArg(args, '--matches', 400);
  final platform = _stringArg(args, '--platform', 'euw1');
  final region = _regionOf(platform);
  final output = _stringArg(args, '--output', _defaultOutput);
  final resume = args.contains('--resume');
  final mergeWith = _stringArg(args, '--merge-with', '');
  final decay = _doubleArg(args, '--decay', 1);
  final minPatch = _stringArg(args, '--min-patch', '');
  if (decay < 0 || decay > 1) {
    stderr.writeln('--decay doit être compris entre 0 et 1.');
    exit(2);
  }
  if (minPatch.isNotEmpty && parsePatch(minPatch) == null) {
    stderr.writeln('--min-patch attend un patch comme 16.19.');
    exit(2);
  }

  final riot = _RiotClient(apiKey);
  try {
    stdout.writeln('Classement Master $platform…');
    final league = await riot.get(
      'https://$platform.api.riotgames.com/lol/league/v4/masterleagues/by-queue/RANKED_SOLO_5x5',
    );
    final puuids =
        (league['entries'] as List)
            .map((entry) => entry['puuid'] as String?)
            .whereType<String>()
            .toList()
          ..shuffle(Random(7));
    stdout.writeln('${puuids.length} joueurs.');

    final matchIds = <String>{};
    for (final puuid in puuids) {
      if (matchIds.length >= targetMatches) break;
      final ids = await riot.get(
        'https://$region.api.riotgames.com/lol/match/v5/matches/by-puuid/$puuid/ids?queue=$_soloQueue&type=ranked&start=0&count=30',
      );
      matchIds.addAll((ids as List).cast<String>());
      stdout.write('\r${matchIds.length} identifiants de parties…   ');
    }
    stdout.writeln();

    final progress = resume ? _Progress.load(output) : _Progress();
    final tally = progress.tally;
    final patches = progress.patches;
    final doneIds = progress.matchIds;
    if (resume) {
      stdout.writeln('Reprise : ${doneIds.length} parties déjà traitées.');
    }

    for (final matchId in matchIds) {
      if (doneIds.length >= targetMatches) break;
      if (doneIds.contains(matchId)) continue;

      final Map<String, dynamic> match;
      try {
        match = await riot.get(
          'https://$region.api.riotgames.com/lol/match/v5/matches/$matchId',
        ) as Map<String, dynamic>;
      } on HttpException catch (error) {
        // Une partie supprimée ou devenue inaccessible ne doit pas arrêter un
        // calcul de plusieurs heures. Toute autre réponse (clé refusée ou
        // expirée) l'arrête, mais la progression est d'abord sauvegardée.
        if (error.message.startsWith('HTTP 404')) {
          doneIds.add(matchId);
          continue;
        }
        progress.save(output);
        rethrow;
      }

      doneIds.add(matchId);
      final info = match['info'] as Map<String, dynamic>;
      if (info['queueId'] != _soloQueue) continue;

      final patch = (info['gameVersion'] as String)
          .split('.')
          .take(2)
          .join('.');
      // Déjà marquée traitée plus haut : une reprise ne la relira pas.
      if (minPatch.isNotEmpty && isBeforePatch(patch, minPatch)) continue;
      patches[patch] = (patches[patch] ?? 0) + 1;

      if (_recordMatch(info, tally)) progress.used++;
      stdout.write('\r${progress.used} parties exploitées…   ');

      if (doneIds.length % _checkpointEvery == 0) progress.save(output);
    }
    stdout.writeln();
    progress.save(output);

    var used = progress.used;
    var patch = patches.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;

    var allPatches = Map<String, int>.of(patches);
    if (mergeWith.isNotEmpty) {
      final existing = _readExisting(mergeWith);
      // Les vieilles parties pèsent moins que les récentes : on fait vieillir
      // l'existant avant de l'additionner.
      final aged = decayTally(existing.tally, decay);
      final agedMatches = decayCount(existing.matches, decay);
      mergeTally(tally, aged);
      used += agedMatches;
      mergePatches(allPatches, decayPatches(existing.patches, decay));
      patch = patchRange(existing.patch, patch);
      stdout.writeln(
        'Fusion avec $mergeWith : +$agedMatches parties '
        '(${existing.matches} × $decay, patch ${existing.patch}).',
      );
    }

    File(output)
        .writeAsStringSync(_render(tally, used, patch, platform, allPatches));
    stdout.writeln(
      '${tally.length ~/ 2} paires distinctes sur $used parties '
      '(patch $patch) → $output',
    );
  } finally {
    riot.close();
  }
}

/// Met face à face, voie par voie, le champion bleu et le champion rouge.
/// Renvoie faux si la partie est inexploitable (voies incomplètes).
bool _recordMatch(Map<String, dynamic> info, Map<String, Tally> tally) {
  final participants = (info['participants'] as List)
      .cast<Map<String, dynamic>>();
  var recorded = false;

  for (final lane in _lanes) {
    final inLane = participants
        .where((p) => p['teamPosition'] == lane)
        .toList();
    if (inLane.length != 2 || inLane[0]['teamId'] == inLane[1]['teamId']) {
      continue;
    }

    for (final me in inLane) {
      final other = inLane.firstWhere((p) => p != me);
      final key = '${_championId(me)}|${_championId(other)}|$lane';
      final entry = tally.putIfAbsent(key, Tally.new);
      entry.games++;
      if (me['win'] == true) entry.wins++;
    }
    recorded = true;
  }

  return recorded;
}

String _render(
  Map<String, Tally> tally,
  int matches,
  String patch,
  String platform,
  Map<String, int> patches,
) {
  final matchups = tally.entries.map((entry) {
    final parts = entry.key.split('|');
    return {
      'champion': parts[0],
      'opponent': parts[1],
      'lane': parts[2],
      'games': entry.value.games,
      'wins': entry.value.wins,
    };
  }).toList()..sort((a, b) => (b['games'] as int).compareTo(a['games'] as int));

  return const JsonEncoder.withIndent('  ').convert({
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'patch': patch,
    'platform': platform,
    'rank': 'MASTER+',
    'matches': matches,
    // Informatif : parties par patch (pondérées par --decay), ignoré par l'app.
    'patches': {
      for (final key in patches.keys.toList()..sort(comparePatches))
        key: patches[key],
    },
    'matchups': matchups,
  });
}

/// Client minimal qui respecte la limite d'une clé de développement
/// (100 requêtes par 2 minutes) et honore les réponses 429.
class _RiotClient {
  final String apiKey;
  final HttpClient _client = HttpClient();
  final List<DateTime> _recent = [];

  _RiotClient(this.apiKey);

  Future<dynamic> get(String url) async {
    await _throttle();

    final request = await _client.getUrl(Uri.parse(url));
    request.headers.set('X-Riot-Token', apiKey);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode == 429) {
      final wait =
          int.tryParse(response.headers.value('retry-after') ?? '') ?? 10;
      stdout.write('\rLimite atteinte, pause de ${wait}s…   ');
      await Future<void>.delayed(Duration(seconds: wait + 1));
      return get(url);
    }
    if (response.statusCode != 200) {
      throw HttpException(
        'HTTP ${response.statusCode} : $body',
        uri: Uri.parse(url),
      );
    }

    return jsonDecode(body);
  }

  Future<void> _throttle() async {
    final now = DateTime.now();
    _recent.removeWhere(
      (t) => now.difference(t) > const Duration(seconds: 122),
    );
    if (_recent.length >= 95) {
      final wait = const Duration(seconds: 122) - now.difference(_recent.first);
      await Future<void>.delayed(wait);
    }
    _recent.add(DateTime.now());
  }

  void close() => _client.close();
}

String _regionOf(String platform) {
  const europe = {'euw1', 'eun1', 'tr1', 'ru', 'me1'};
  const americas = {'na1', 'br1', 'la1', 'la2'};
  if (europe.contains(platform)) return 'europe';
  if (americas.contains(platform)) return 'americas';
  if (platform == 'kr' || platform == 'jp1') return 'asia';
  return 'sea';
}

int _intArg(List<String> args, String name, int fallback) {
  final index = args.indexOf(name);
  if (index < 0 || index + 1 >= args.length) return fallback;
  return int.tryParse(args[index + 1]) ?? fallback;
}

double _doubleArg(List<String> args, String name, double fallback) {
  final index = args.indexOf(name);
  if (index < 0 || index + 1 >= args.length) return fallback;
  return double.tryParse(args[index + 1]) ?? fallback;
}

String _stringArg(List<String> args, String name, String fallback) {
  final index = args.indexOf(name);
  if (index < 0 || index + 1 >= args.length) return fallback;
  return args[index + 1];
}

/// Ce qu'il faut garder pour reprendre un calcul interrompu : les bilans déjà
/// comptés et les parties déjà traitées, pour ne pas les compter deux fois.
class _Progress {
  final Map<String, Tally> tally = {};
  final Set<String> matchIds = {};
  final Map<String, int> patches = {};
  int used = 0;

  _Progress();

  static String _path(String output) => '$output.progress.json';

  void save(String output) {
    final data = {
      'used': used,
      'patches': patches,
      'matchIds': matchIds.toList(),
      'tally': {
        for (final entry in tally.entries)
          entry.key: [entry.value.games, entry.value.wins],
      },
    };
    // Écrit dans un fichier voisin puis renomme : une coupure en pleine
    // écriture ne doit jamais laisser une sauvegarde à moitié écrite.
    final temporary = File('${_path(output)}.tmp')
      ..writeAsStringSync(jsonEncode(data));
    temporary.renameSync(_path(output));
  }

  factory _Progress.load(String output) {
    final file = File(_path(output));
    final progress = _Progress();
    if (!file.existsSync()) return progress;

    final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    progress.used = data['used'] as int;
    progress.patches.addAll((data['patches'] as Map).cast<String, int>());
    progress.matchIds.addAll((data['matchIds'] as List).cast<String>());
    for (final entry in (data['tally'] as Map).entries) {
      final values = (entry.value as List).cast<int>();
      progress.tally[entry.key as String] = Tally()
        ..games = values[0]
        ..wins = values[1];
    }

    return progress;
  }
}

class _Existing {
  final Map<String, Tally> tally;
  final int matches;
  final String patch;
  final Map<String, int> patches;

  const _Existing(this.tally, this.matches, this.patch, this.patches);
}

/// Relit un fichier de matchups déjà généré pour l'additionner au nouveau.
_Existing _readExisting(String path) {
  final data =
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  final tally = <String, Tally>{};

  for (final raw in (data['matchups'] as List).cast<Map<String, dynamic>>()) {
    final key = '${raw['champion']}|${raw['opponent']}|${raw['lane']}';
    tally[key] = Tally()
      ..games = raw['games'] as int
      ..wins = raw['wins'] as int;
  }

  final patches = <String, int>{
    for (final entry in ((data['patches'] as Map?) ?? const {}).entries)
      entry.key as String: entry.value as int,
  };

  return _Existing(
    tally,
    data['matches'] as int? ?? 0,
    data['patch'] as String? ?? '?',
    patches,
  );
}
