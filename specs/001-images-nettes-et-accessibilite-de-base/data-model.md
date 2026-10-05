# Data Model: Images nettes et accessibilité de base

La fonctionnalité ne persiste aucune donnée applicative. Elle touche un modèle existant et un composant de présentation.

## Champion (`lib/champions/models/champion.dart`)

| Champ | Type | Rôle |
|-------|------|------|
| `id` | `String` | identifiant Data Dragon (ex. `Ahri`), sert à construire l'URL du portrait |
| `imageUrl` | `String` | icône carrée versionnée : `…/cdn/<version>/img/champion/<fichier>` ; petits affichages |
| `portraitUrl` | `String` (calculé) | `https://ddragon.leagueoflegends.com/cdn/img/champion/loading/<id>_0.jpg` ; illustration verticale, apparence de base ; grandes cartes |

**Validation** : aucune ; l'URL est construite sans vérification. Un champion inconnu de Riot donne un lien mort, géré par l'état d'échec de `RemoteImage`.

**Remarque** : `portraitUrl` ne dépend pas de la version du jeu (pas de segment `<version>`).

## État d'une image distante

| État | Affichage |
|------|-----------|
| Chargement | `ShimmerBox` de la taille demandée |
| Chargée | l'image ; fondu de 150 ms sur mobile |
| Échec | `errorWidget` de l'appelant, sinon rectangle de couleur `AppColors.surface` |

Transitions : chargement vers chargée ou chargement vers échec ; il n'y a pas de nouvelle tentative automatique.

## Sémantique exposée

| Élément | Rôle | Étiquette | État |
|---------|------|-----------|------|
| Badge favori | bouton | « Ajouter aux favoris » / « Retirer des favoris » | selon `isFavorite` |
| Onglet de navigation | bouton | libellé de la destination | `selected` |
| Image sans description | ignorée | — | — |
| Image avec description | image | `semanticLabel` | — |
