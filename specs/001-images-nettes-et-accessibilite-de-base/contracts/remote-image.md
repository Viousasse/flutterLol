# Contrat : `RemoteImage` et `ShimmerBox`

Interface publique consommée par toutes les fonctionnalités qui affichent une image réseau.

## `RemoteImage` (`lib/shared/widgets/remote_image/remote_image.dart`)

```dart
class RemoteImage extends StatelessWidget {
  const RemoteImage({
    super.key,
    required String url,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Alignment alignment = Alignment.center,   // partie conservée quand l'image est rognée
    String? semanticLabel,                     // null : image ignorée des lecteurs d'écran
    Widget? errorWidget,                       // remplace le rectangle de surface en cas d'échec
  });
}
```

Comportement garanti :

- mobile : `CachedNetworkImage` avec cache disque et fondu de 150 ms ; web : `Image.network` avec `WebHtmlElementStrategy.fallback` ;
- chargement : `ShimmerBox(width, height)` ; échec : `errorWidget` ou rectangle `AppColors.surface` ;
- `semanticLabel == null` : `ExcludeSemantics` ; sinon `Semantics(image: true, label: semanticLabel)`.

## `ShimmerBox` (`lib/shared/widgets/shimmer_box/shimmer_box.dart`)

```dart
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({super.key, double? width, double? height});
}
```

Rectangle qui oscille en boucle (1 100 ms, aller-retour) entre `AppColors.surface` et un mélange de 9 % de `AppColors.textPrimary`. Libère son contrôleur dans `dispose`.

## `Champion.portraitUrl` (`lib/champions/models/champion.dart`)

```dart
String get portraitUrl; // illustration verticale (apparence de base), pour les grandes cartes
```

## Sémantique du badge favori

`ChampionCardFavoriteBadge({required bool isFavorite, required VoidCallback onTap})` (`lib/champions/widgets/champion_card/champion_card_favorite_badge.dart`) : bouton nommé « Retirer des favoris » si `isFavorite`, « Ajouter aux favoris » sinon.
