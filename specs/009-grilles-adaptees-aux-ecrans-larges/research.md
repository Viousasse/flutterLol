# Research: Grilles adaptées aux écrans larges

## Décision 1 : largeur maximale de carte plutôt que nombre de colonnes fixe

- **Decision**: `SliverGridDelegateWithMaxCrossAxisExtent` pour les deux grilles (130 px pour les objets, 220 px pour les champions).
- **Rationale**: le commentaire de `lib/items/constants/item_grid.dart` dit que la grille « ajoute une colonne plutôt que d'étirer les cartes sur un écran large » ; les champions suivent le même principe (« deux colonnes sur un téléphone, davantage sur un écran large »). C'est ce que montre le diff du commit `ae4c0c2`, qui remplace `SliverGridDelegateWithFixedCrossAxisCount`.
- **Alternatives considered**: la trace du code ne mentionne que l'ancien comportement (nombre de colonnes fixe : 3 pour les objets, 2 pour les champions), pas d'autre alternative étudiée.

## Décision 2 : hauteur fixe pour les objets

- **Decision**: `mainAxisExtent = 100 + 50 × échelle de texte` pour les cartes d'objets (au lieu de `childAspectRatio: 0.66`).
- **Rationale**: commentaire du code : « avec un ratio, une carte devenait très haute dès que l'écran s'élargissait ». 100 px couvrent l'icône et les marges ; 50 px de texte de base couvrent le nom sur deux lignes et le prix et sont seuls multipliés par `MediaQuery.textScalerOf(context).scale(1)`, car seule la partie texte grandit avec la police de l'utilisateur.
- **Alternatives considered**: l'ancien ratio 0,66 avait été choisi « assez haut pour un nom sur deux lignes jusqu'à 360 px de large » (commentaire supprimé par le commit) ; il ne résiste pas à l'élargissement. Aucune autre alternative tracée.

## Décision 3 : ratio conservé pour les champions

- **Decision**: `childAspectRatio: 0.82` conservé, `maxCrossAxisExtent: 220`.
- **Rationale**: la carte de champion est une grande image dont la hauteur reste proportionnelle ; plafonner la largeur à 220 px borne aussi la hauteur. Pas de justification écrite dans le code au-delà du commentaire de la grille.
- **Alternatives considered**: non documentées.

## Décision 4 : un fichier de grille par fonctionnalité, partagé avec les favoris

- **Decision**: `championGridDelegate` (constante) et `itemGridDelegate(context)` (fonction, car elle lit `MediaQuery`) vivent dans `constants/` de leur fonctionnalité et sont importés par `lib/favorites/`.
- **Rationale**: le commentaire des deux fichiers précise que la grille est « commune à la liste et aux favoris » ; le diff supprime la grille dupliquée des deux onglets de favoris.
- **Alternatives considered**: non documentées.
