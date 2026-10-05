# Quickstart : valider la recherche et la comparaison des champions

## Lancer l'application

```bash
flutter pub get
flutter run -d chrome        # ou un appareil mobile
```

Une connexion réseau est nécessaire au premier lancement (Data Dragon) ; ensuite la copie hors-ligne prend le relais.

## Scénarios à la main

1. **Comparer deux champions** : onglet Outils → « Comparer ». Appuyer sur « Choisir le premier champion », choisir Ahri, puis « Choisir le second champion », choisir Garen. Attendu : onze lignes au plus (huit sans objet), valeurs de niveau 1, barres face à face, carte « En duel » en bas. Garen ne peut pas être choisi deux fois (il est absent de la liste du premier côté).
2. **Niveau** : déplacer le curseur sur 18. Attendu : points de vie, dégâts, armure et résistance magique augmentent ; portée, vitesse de déplacement et difficulté ne changent pas.
3. **Objets** : sous Ahri, appuyer sur « + », choisir un objet de puissance. Attendu : une ligne « Puissance » apparaît ; appuyer sur l'objet le retire et la ligne disparaît. Avec six objets, la case « + » disparaît.
4. **Build enregistrée** : sans build, « Charger une build » affiche un message invitant à en créer une. Après avoir enregistré une build (voir `specs/008-constructeur-de-builds`), « Charger une build » → la choisir : ses objets remplacent ceux du champion.
5. **Duel et données insuffisantes** : comparer deux champions qui ne se rencontrent pas dans les données : la carte indique « Pas assez de parties Master+ … ».
6. **Depuis la fiche** : ouvrir un champion, appuyer sur « Comparer avec un autre champion ». Attendu : le champion est déjà à gauche.
7. **Recherche globale** : accueil → loupe. Taper « ah » : Ahri apparaît avant les noms qui contiennent « ah ». Taper « chogath » : Cho'Gath est trouvé. Appuyer sur un résultat : fiche du champion ou détail de l'objet.
8. **Liste des champions** : onglet Champions, taper « zoe », choisir un rôle, une région ; essayer les quatre tris (A-Z, Plus facile, Plus dur, Victoires) ; le compteur « x sur y » suit.
9. **Hors-ligne** : couper le réseau, ouvrir Comparer sans copie locale : un message et « Réessayer » apparaissent.

## Tests automatisés

```bash
flutter test test/compare test/search \
  test/champions/services/champion_filter_test.dart \
  test/shared/text/search_text_test.dart \
  test/shared/widgets/expandable_text_test.dart \
  test/shared/widgets/champion_picker_sheet_test.dart \
  test/matchups/matchup_service_test.dart
flutter analyze lib/compare lib/search lib/champions lib/shared/text
```

Correspondance exigence → test :

| Exigence | Test |
|----------|------|
| FR-002, FR-003, FR-005 | `test/compare/combat_stats_calculator_test.dart` |
| FR-004 | `test/compare/combat_stats_calculator_test.dart` (objets, vitesses, critique) |
| FR-006, FR-007, FR-008 | `test/compare/comparison_builder_test.dart` |
| FR-009, FR-010 | `test/matchups/matchup_service_test.dart` (`headToHead`) ; seuil de 100 parties : pas de test dédié |
| FR-001 (filtre de rôle de la feuille) | `test/shared/widgets/champion_picker_sheet_test.dart` |
| FR-014 | `test/search/global_search_test.dart` |
| FR-015 | `test/shared/text/search_text_test.dart`, `test/search/global_search_test.dart` |
| FR-016, FR-017 | `test/champions/services/champion_filter_test.dart` |
| FR-018 | `test/shared/widgets/expandable_text_test.dart` |
| FR-011, FR-012, FR-013, FR-019, FR-020 | vérification à la main (scénarios ci-dessus) ; pas de test automatisé |
