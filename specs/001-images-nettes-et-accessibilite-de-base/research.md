# Research: Images nettes et accessibilité de base

## Illustration verticale plutôt qu'icône carrée

- **Decision**: les cartes utilisent `Champion.portraitUrl`, l'URL `…/cdn/img/champion/loading/<id>_0.jpg` de Data Dragon, au lieu de `imageUrl` (icône carrée versionnée).
- **Rationale**: le commentaire de `champion.dart` le dit : l'icône carrée de 120 px devient floue dès qu'on l'étire. Cette illustration est verticale et en haute définition, faite pour les grandes cartes. Elle correspond à la demande « de meilleurs photo, ils sont pixelisés ». Elle est aussi inscrite dans la constitution (principe III : choisir la source selon la taille d'affichage).
- **Alternatives considered**: aucune alternative n'est tracée dans le code ou les commits (`ab817a6`). L'icône reste utilisée pour les petits affichages (listes de builds, matchups, etc.).

## Ancrage en haut du cadrage

- **Decision**: `RemoteImage` reçoit un paramètre `alignment` ; la carte et l'emplacement de comparaison passent `Alignment.topCenter`.
- **Rationale**: le commentaire de `remote_image.dart` : « Partie de l'image conservée quand elle est rognée pour remplir son cadre ». Une illustration verticale rognée au centre coupe le visage ; la demande « tout le monde n'est pas bien placé » est résolue en gardant le haut.
- **Alternatives considered**: un réglage par champion n'existe pas et rien dans les traces ne l'envisage.

## Un seul composant, deux chargeurs

- **Decision**: `RemoteImage` utilise `Image.network` sur le web et `CachedNetworkImage` ailleurs.
- **Rationale**: texte repris du commentaire du composant : le cache disque n'a pas de sens sur le web, et le décodage de `cached_network_image` y lève une assertion qui laissait toutes les images en erreur. `Image.network` sait en plus retomber sur un élément `<img>` quand le serveur n'envoie pas de CORS (`WebHtmlElementStrategy.fallback`). Cette partie date des commits précédents (`f785a28`, `dec996a`) ; `a1c29ba` n'a fait que la refactoriser en une seule variable `image`.
- **Alternatives considered**: `cached_network_image` partout, abandonné à cause de l'assertion web.

## Fond qui pulse plutôt que case vide

- **Decision**: `ShimmerBox`, avec une oscillation de 1 100 ms entre la couleur de surface et un mélange à 9 % de la couleur du texte principal ; en cas d'échec, simple rectangle de surface.
- **Rationale**: le commentaire de `remote_image.dart` : « une case vide et immobile donne l'impression d'une image cassée quand le réseau est lent ». Le mélange à 9 % garde un mouvement discret dans les deux modes parce qu'il lit `AppColors`.
- **Alternatives considered**: l'ancien fond fixe `_Backdrop` (supprimé dans `a1c29ba`). Le choix des 1 100 ms et des 9 % n'est pas justifié par une mesure : valeurs de goût.

## Description des images optionnelle

- **Decision**: `semanticLabel` optionnel ; sans lui, l'image est enveloppée dans `ExcludeSemantics`, avec lui dans `Semantics(image: true, label: …)`.
- **Rationale**: commentaire du code : sans description l'image est ignorée, « le bon choix pour une illustration purement décorative ». La grande majorité des appels ne fournissent pas de description.
- **Alternatives considered**: imposer une description à chaque appel, non retenu (aucune trace de raison).

## Sémantique des contrôles à icône seule

- **Decision**: `Semantics(button: true, label: …, excludeSemantics: true, onTap: …)` autour du badge favori et de chaque onglet, en doublant l'`onTap` du détecteur de gestes.
- **Rationale**: commentaire du badge : une icône seule n'a pas de nom, un lecteur d'écran annonce « bouton » sans dire ce qu'il fait ni son état. `excludeSemantics` évite d'annoncer l'icône en plus du libellé.
- **Alternatives considered**: aucune tracée.

## Contraste 4,5:1

- **Decision**: éclaircir le texte discret (opacité 0,35 vers 0,5 dans `a1c29ba`).
- **Rationale**: commentaire de `a1c29ba` : à 0,5 d'opacité le texte atteint 4,5:1 sur le fond sombre, exigé par le RGAA ; à 0,35 il restait vers 3:1. Depuis, `bfc1352` et le mode clair ont remplacé ces constantes par deux palettes, et `test/theme/contrast_test.dart` garantit le seuil pour les deux.
- **Alternatives considered**: aucune tracée.
