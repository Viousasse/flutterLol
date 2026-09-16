import 'dart:convert';
import 'dart:io';

/// Régénère `lib/regions/constants/champion_regions.dart` depuis les données
/// officielles :
///
///   - la liste des champions et leurs identifiants : Data Dragon ;
///   - la région de chaque champion : l'API du site Univers de Riot
///     (`universe-meeps.leagueoflegends.com`), celle qui alimente les pages
///     région de universe.leagueoflegends.com.
///
/// À relancer après une sortie de champion :
///
///     dart run tool/generate_champion_regions.dart
const _universe =
    'https://universe-meeps.leagueoflegends.com/v1/fr_fr/search/index.json';
const _versions = 'https://ddragon.leagueoflegends.com/api/versions.json';
const _output = 'lib/regions/constants/champion_regions.dart';

/// Slugs de l'Univers qui ne sont pas simplement l'identifiant Data Dragon
/// en minuscules.
const _slugAliases = {'renataglasc': 'Renata'};

/// Faction de l'Univers -> valeur de `RegionId`.
const _regionIds = {
  'demacia': 'demacia',
  'noxus': 'noxus',
  'ionia': 'ionia',
  'freljord': 'freljord',
  'piltover': 'piltover',
  'zaun': 'zaun',
  'shurima': 'shurima',
  'mount-targon': 'targon',
  'bilgewater': 'bilgewater',
  'shadow-isles': 'shadowIsles',
  'ixtal': 'ixtal',
  'bandle-city': 'bandleCity',
  'void': 'theVoid',
  'unaffiliated': 'runeterra',
};

const _regionTitles = {
  'demacia': 'Demacia',
  'noxus': 'Noxus',
  'ionia': 'Ionie',
  'freljord': 'Freljord',
  'piltover': 'Piltover',
  'zaun': 'Zaun',
  'shurima': 'Shurima',
  'targon': 'Targon',
  'bilgewater': 'Bilgewater',
  'shadowIsles': 'Îles Obscures',
  'ixtal': 'Ixtal',
  'bandleCity': 'Bandle',
  'theVoid': 'Néant',
  'runeterra': 'Sans attache (aucune nation dans l\'univers officiel)',
};

Future<void> main() async {
  final client = HttpClient();

  try {
    final versions = await _getJson(client, _versions) as List;
    final version = versions.first as String;
    final champions = await _getJson(
      client,
      'https://ddragon.leagueoflegends.com/cdn/$version/data/fr_FR/champion.json',
    );
    final ids = (champions['data'] as Map).keys.cast<String>().toList()..sort();
    final idBySlug = {
      for (final id in ids) id.toLowerCase(): id,
      ..._slugAliases,
    };

    final universe = await _getJson(client, _universe);
    final factionByChampion = <String, String>{};
    for (final entry in universe['champions'] as List) {
      final slug = entry['slug'] as String;
      final faction = entry['associated-faction-slug'] as String?;
      final id = idBySlug[slug];
      if (id == null || faction == null || faction.isEmpty) continue;

      final regionId = _regionIds[faction];
      if (regionId == null) {
        stderr.writeln('Faction inconnue « $faction » pour $id, ignorée.');
        continue;
      }
      factionByChampion[id] = regionId;
    }

    final missing = ids.where((id) => !factionByChampion.containsKey(id));
    final file = File(_output);
    file.writeAsStringSync(_render(factionByChampion, version));

    stdout.writeln(
      '${factionByChampion.length}/${ids.length} champions attribués '
      '(Data Dragon $version).',
    );
    if (missing.isNotEmpty) {
      stdout.writeln('Sans région dans l\'Univers : ${missing.join(', ')}');
    }
  } finally {
    client.close();
  }
}

Future<dynamic> _getJson(HttpClient client, String url) async {
  final request = await client.getUrl(Uri.parse(url));
  final response = await request.close();
  if (response.statusCode != 200) {
    throw HttpException('HTTP ${response.statusCode}', uri: Uri.parse(url));
  }
  return jsonDecode(await response.transform(utf8.decoder).join());
}

String _render(Map<String, String> factionByChampion, String version) {
  final buffer = StringBuffer()
    ..writeln("import '../models/lore_region.dart';")
    ..writeln()
    ..writeln('/// Région officielle de chaque champion.')
    ..writeln('///')
    ..writeln(
      '/// FICHIER GÉNÉRÉ par `tool/generate_champion_regions.dart` depuis',
    )
    ..writeln("/// l'API du site Univers de Riot (Data Dragon $version).")
    ..writeln('/// Ne pas éditer à la main : relancer le script.')
    ..writeln('///')
    ..writeln(
      "/// Un champion absent d'ici est sorti après la dernière génération ;",
    )
    ..writeln('/// il apparaît sous « Non répertoriés » sur la carte.')
    ..writeln('const championRegions = <String, RegionId>{');

  for (final regionId in _regionTitles.keys) {
    final members =
        factionByChampion.entries
            .where((entry) => entry.value == regionId)
            .map((entry) => entry.key)
            .toList()
          ..sort();
    if (members.isEmpty) continue;

    buffer.writeln('  // ${_regionTitles[regionId]}');
    for (final id in members) {
      buffer.writeln("  '$id': RegionId.$regionId,");
    }
    buffer.writeln();
  }

  final text = buffer.toString().trimRight();
  return '$text\n};\n';
}
