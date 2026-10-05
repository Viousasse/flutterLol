# Contrat : notes de patch

## `PatchNotes` — `lib/patch_notes/models/patch_notes.dart`

```dart
class PatchNotes {
  final String label;   // « 26.19 »
  final String url;     // page officielle des notes
  const PatchNotes({required this.label, required this.url});

  /// `null` si [version] n'a pas la forme « saison.patch[.correctif] » avec deux entiers.
  static PatchNotes? fromVersion(String version);
}
```

## `PatchNotesCard` — `lib/home/widgets/patch_notes_card/patch_notes_card.dart`

```dart
class PatchNotesCard extends StatelessWidget {
  final PatchNotes notes;
  const PatchNotesCard({super.key, required this.notes});
}
```

Un appui ouvre `notes.url` en application externe ; en cas d'échec, une barre éphémère affiche « Impossible d'ouvrir les notes de patch. ». Sémantique : bouton, libellé « Lire les notes du patch <label> ».

## Source de la version — `lib/data_dragon/data_dragon_service.dart`

`static Future<String> latestVersion()` (existant) : la plus récente des versions de `api/versions.json`, futur mis en cache.
