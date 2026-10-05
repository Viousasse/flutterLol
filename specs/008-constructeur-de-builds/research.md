# Research: Constructeur de builds, partage et import par code

Décisions tirées des commentaires du code et des tests. Là où aucune trace d'alternative n'existe, il est écrit.

## Magasin de builds sur le modèle des favoris

- **Decision**: `BuildStore` expose un `ValueNotifier<List<Build>>` statique, comme les favoris ; une build enregistrée apparaît dans la liste sans rechargement.
- **Rationale**: commentaire de `build_store.dart` (« même forme que les favoris »), cohérent avec le principe V (état simple et local).
- **Alternatives considered**: aucune trace.

## Nouvelle liste : modifiée en tête, remplacement par identifiant

- **Decision**: `save` retire toute build de même `id` puis place la nouvelle en tête.
- **Rationale**: une build modifiée ne crée pas de doublon et la plus récemment travaillée est la première de la liste (commentaire de `save`).
- **Alternatives considered**: aucune trace.

## Entrée stockée illisible ignorée

- **Decision**: `Build.tryFromJson` renvoie `null` et le magasin écarte l'entrée (JSON invalide compris) ; les objets au-delà de six sont tronqués à la lecture.
- **Rationale**: « une seule entrée corrompue ne doit pas faire perdre toutes les autres » (commentaire du modèle) ; tests `build_store_test.dart`.
- **Alternatives considered**: aucune trace.

## Écritures sérialisées

- **Decision**: `_persist` enchaîne les écritures dans `_writeQueue` et avale les échecs de la file (`catchError`).
- **Rationale**: ne pas doubler les écritures et ne pas bloquer les suivantes après une panne (commentaire de `_persist`).
- **Alternatives considered**: aucune trace.

## Stockage indisponible : démarrer vide et retenter

- **Decision**: en cas d'échec de `SharedPreferences`, `_load` laisse la liste vide et remet `_loading` à `null`.
- **Rationale**: « plutôt que de planter, et le prochain appel pourra retenter » (commentaire).
- **Alternatives considered**: aucune trace.

## Seules les statistiques chiffrées comptent

- **Decision**: `BuildStats` additionne douze clés Data Dragon dans un ordre de lecture fixe ; les passifs et actifs ne sont pas comptés ; les fractions sont affichées en pourcentage.
- **Rationale**: commentaires de `build_stats.dart` (« les seules statistiques que portent réellement les objets de la Faille ») ; une somme de texte libre ne serait pas fiable.
- **Alternatives considered**: aucune trace.

## Prix = coût total de chaque objet

- **Decision**: `totalGold` additionne `Item.gold`, composants compris.
- **Rationale**: commentaire de `totalGold` (« prix d'achat cumulé »).
- **Alternatives considered**: aucune trace.

## Code de partage versionné, base64url sans remplissage

- **Decision**: préfixe `LOLB1.` + JSON compact (`n`, `c`, `i`) en base64url sans `=` ; mécanisme extrait dans `ShareCode` pour être partagé avec les drafts (`LOLD1.`).
- **Rationale**: le préfixe change quand le format casse, pas quand un champ s'ajoute (lecteurs tolérants) ; un code sans `=` ni `+` `/` survit mieux aux messageries. Test « n'est pas rempli de = ».
- **Alternatives considered**: aucune trace dans le code ou les messages de commit.

## Code noyé dans un message, décodeur qui passe au suivant

- **Decision**: `ShareCode.decode` cherche tous les codes du texte et renvoie le premier lisible.
- **Rationale**: « le code est le plus souvent collé au milieu d'un message entier » (commentaire) ; un code tronqué ou abîmé est ignoré.
- **Alternatives considered**: lire le texte tel quel (écarté par le même commentaire).

## Nom limité à 60 à l'import, 40 dans l'éditeur

- **Decision**: l'import refuse un nom vide ou de plus de `maxNameLength = 60` ; l'éditeur limite la saisie à 40 (`maxLength: 40`).
- **Rationale**: « au-delà, un nom collé n'est plus un nom : on refuse le code plutôt que de le tronquer en silence » (commentaire). L'écart 40/60 n'est pas expliqué ; il est consigné comme limite connue dans `spec.md`.
- **Alternatives considered**: tronquer en silence (écarté par le commentaire).

## Nouvel identifiant à chaque lecture, `_freshId`

- **Decision**: `BuildShareCode.decode` ne lit pas d'identifiant ; il en génère un, en bouclant tant qu'il égale le précédent.
- **Rationale**: l'ami garde une copie indépendante ; l'horloge peut rendre deux fois la même microseconde (commentaire), test « chaque lecture donne un nouvel identifiant ».
- **Alternatives considered**: aucune trace.

## Boîte d'import qui reste ouverte

- **Decision**: `PasteCodeDialog` garde la boîte ouverte et affiche l'erreur tant que `parse` renvoie `null` ; l'erreur disparaît à la frappe.
- **Rationale**: permet de corriger le collage sans tout rouvrir (tests `paste_code_dialog_test.dart` et `builds_page_test.dart`) ; la décision de la rendre générique vient du partage avec l'historique des drafts. Aucun commentaire ne détaille d'autre raison.
- **Alternatives considered**: aucune trace.

## Filtre de rôle dans le choix du champion

- **Decision**: l'éditeur charge `RoleFilters.loadProfile()` en tâche de fond et passe `RoleFilters.forProfile(laneProfile)` à `ChampionPickerSheet` ; sans données, le filtre est absent et le choix reste possible.
- **Rationale**: réutilise le filtre de rôle des autres écrans (équipe, points forts) ; l'absence de données ne doit pas bloquer la création d'une build.
- **Alternatives considered**: aucune trace.

## Copie dans le presse-papiers plutôt que feuille de partage

- **Decision**: le partage passe par `copyToClipboard`, qui annonce aussi l'échec de copie.
- **Rationale**: commentaire de `clipboard_copy.dart` (ne pas coller un ancien contenu en croyant avoir copié). Pas de trace d'un essai de feuille de partage système.
- **Alternatives considered**: aucune trace.
