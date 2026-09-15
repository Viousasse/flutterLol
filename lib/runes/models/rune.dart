import '../../data_dragon/data_dragon_service.dart';

class Rune {
  final int id;
  final String key;
  final String name;
  final String shortDesc;
  final String iconUrl;

  const Rune({
    required this.id,
    required this.key,
    required this.name,
    required this.shortDesc,
    required this.iconUrl,
  });

  factory Rune.fromJson(Map<String, dynamic> json) {
    return Rune(
      id: json['id'],
      key: json['key'],
      name: json['name'],
      shortDesc: _cleanText(json['shortDesc'] ?? ''),
      iconUrl: DataDragonService.perkIconUrl(json['icon']),
    );
  }

  static String _cleanText(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class RuneTree {
  final int id;
  final String key;
  final String name;
  final String iconUrl;
  final List<List<Rune>> slots;

  const RuneTree({
    required this.id,
    required this.key,
    required this.name,
    required this.iconUrl,
    required this.slots,
  });

  factory RuneTree.fromJson(Map<String, dynamic> json) {
    final slots = (json['slots'] as List).map((slot) {
      return (slot['runes'] as List)
          .map((rune) => Rune.fromJson(rune))
          .toList();
    }).toList();

    return RuneTree(
      id: json['id'],
      key: json['key'],
      name: json['name'],
      iconUrl: DataDragonService.perkIconUrl(json['icon']),
      slots: slots,
    );
  }
}
