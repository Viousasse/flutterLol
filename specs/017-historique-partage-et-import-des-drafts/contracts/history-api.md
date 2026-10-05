# Contrat : interfaces de l'historique

## DraftHistoryStore (`lib/draft/services/draft_history_store.dart`)

```dart
class DraftHistoryStore {
  static const maxRecords = 50;
  static final ValueNotifier<List<DraftRecord>> records;
  static Future<void> ensureLoaded();
  static String newId();
  static Future<void> add(DraftRecord record);   // en tête, remplace le même id
  static Future<void> delete(String id);
  static Future<void> clear();
  @visibleForTesting static void reset();
}
```

Consommateurs : `DraftPage` (ajout), `DraftHistoryPage`, `DraftShareCode` (identifiants), tests.

## DraftHistoryStats

```dart
class PickCount { final String championId; final String name; final int count; }
class DraftHistoryStats {
  static const topCount = 5;
  final int total, againstSite, wins, ties, losses, assistedCount, importedCount;
  final List<PickCount> mostPicked;
  double? get winRate;
  factory DraftHistoryStats.of(List<DraftRecord> records);
}
```

## Pages et widgets

```dart
DraftHistoryPage({Future<List<Champion>> Function() loadChampions = ChampionService.fetchAll});
DraftRecordPage({required DraftRecord record, Map<String,String> imageUrls = const {}});
DraftPage({..., DraftRecord? replayOf});        // rejeu : mêmes bans, mode et noms repris
DraftHistoryTile({required record, required imageUrls, required onShare, required onDelete, VoidCallback? onTap});
DraftStatsCard({required DraftHistoryStats stats, required Map<String,String> imageUrls});
String formatDraftDate(DateTime date);          // « 5 oct. 2026, 15 h 42 »
String draftOutcomeLabel(DraftRecord record);   // « Vous l'emportez », « Le site l'emporte », « Victoire de X », « Égalité »
```

## Utilitaires partagés

```dart
// lib/shared/widgets/paste_code_dialog/paste_code_dialog.dart
PasteCodeDialog.show<T>(BuildContext context, {
  required String title, required String hint,
  required T? Function(String text) parse, required String invalidMessage,
}) -> Future<T?>;      // null si annulé ; reste ouverte tant que parse renvoie null

// lib/shared/services/clipboard_copy/clipboard_copy.dart
Future<void> copyToClipboard(BuildContext context, String text,
    {String message = 'Copié dans le presse-papiers'});
```
