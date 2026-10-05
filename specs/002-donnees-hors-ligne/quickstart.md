# Quickstart : Données hors ligne

## Validation à la main

1. Lancer l'application avec du réseau (`flutter run -d chrome`) et ouvrir les onglets champions, objets, runes (fiche d'un champion) pour remplir les copies.
2. Ouvrir la fiche de 2 ou 3 champions.
3. Couper le réseau (mode hors connexion des outils du navigateur, mode avion) et relancer l'application. **Attendu** : la liste des champions, les objets et la fiche des champions déjà ouverts s'affichent avec les données précédentes.
4. Ouvrir la fiche d'un champion jamais consulté. **Attendu** : un message et un bouton « Réessayer », sans plantage ni chargement sans fin. Rétablir le réseau et appuyer sur « Réessayer » : la fiche s'affiche.
5. Ouvrir plus de 12 fiches différentes en ligne, couper le réseau. **Attendu** : les 12 plus récentes s'ouvrent, la plus ancienne non.
6. Effacer les données du site (premier lancement simulé), couper le réseau, ouvrir l'onglet de la carte. **Attendu** : le message de la panne et « Réessayer » ; après rétablissement du réseau, « Réessayer » affiche la carte.
7. Pour la copie corrompue : modifier à la main la valeur `ddragon_offline_champions` du stockage local, couper le réseau. **Attendu** : message d'erreur lisible, pas d'erreur technique.

## Tests automatisés

```bash
flutter test test/data_dragon/data_dragon_service_test.dart
flutter test test/champions/services/champion_service_offline_test.dart
flutter test test/map/map_page_retry_test.dart
flutter analyze lib/data_dragon lib/champions/services lib/map/map_page.dart
```

Correspondance exigences et tests :

| Exigence | Test |
|----------|------|
| FR-001, US1 | `resert la derniere copie quand Riot est injoignable`, `la version est resservie hors ligne, et un echec se retente` |
| FR-002, FR-003 | `un corps illisible n ecrase pas la derniere bonne copie`, `un JSON de mauvaise forme n ecrase pas la bonne copie` |
| FR-004, FR-005 | `sans copie enregistree, la panne remonte avec un message`, `une copie corrompue remonte une DataDragonException` |
| FR-006 | `offlineKeepLast efface les copies les plus anciennes`, `la fiche d un champion deja vu reste lisible hors ligne`, `une fiche jamais vue echoue avec un message, sans planter` |
| FR-009 | `la version est resservie hors ligne, et un echec se retente` |
| FR-010 | `échec puis succès : Réessayer relance le chargement` |
| FR-012 | `sans offlineKey, rien n est conserve ni resservi` |
| FR-007, FR-008, FR-011 | vérifiés à la main (étapes 3 à 6) ; pas de test automatisé |
