# Data Model: Objets favoris

## Ensemble d'identifiants favoris

| Propriété | Détail |
|-----------|--------|
| Type en mémoire | `Set<String>` dans un `ValueNotifier` |
| Type stocké | liste de chaînes (`setStringList`), sans doublon |
| Identifiant d'un champion | `Champion.id` (ex. `Ahri`) |
| Identifiant d'un objet | `Item.id` (ex. `3031`) |

### Clés `shared_preferences`

| Clé | Contenu |
|-----|---------|
| `favorite_items` | identifiants des objets favoris |
| `favorite_champions` | identifiants des champions favoris |

Les deux jeux sont indépendants : modifier l'un ne touche jamais l'autre.

## Règles

- **Unicité** : un identifiant n'est présent qu'une fois.
- **Bascule** : si l'identifiant est présent, il est retiré ; sinon il est ajouté. Un nouvel ensemble est publié à chaque bascule (une notification par bascule).
- **Chargement** : une seule lecture du disque, partagée entre les appelants ; en cas d'échec de lecture, l'ensemble reste vide et une lecture ultérieure est possible.
- **Écriture** : après publication de l'ensemble en mémoire ; sérialisée par une file ; une erreur est ignorée.
- **Affichage** : l'onglet « Objets » filtre la liste des objets chargés sur les identifiants favoris ; un identifiant sans objet correspondant n'est pas affiché mais reste stocké.

## États de l'onglet « Objets »

```text
chargement ──ok──> (liste vide) ──> message « Aucun objet favori pour le moment »
     │               └─ (au moins un) ──> grille de cartes
     └─ erreur ──> message de la panne + « Réessayer » ──> chargement
```
