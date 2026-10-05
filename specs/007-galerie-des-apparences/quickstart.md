# Quickstart : valider la galerie des apparences

## Lancer l'application

```bash
flutter pub get
flutter run -d chrome        # ou un appareil mobile
```

## Scénarios à la main

1. **Galerie** : onglet Champions → Ahri → faire défiler jusqu'à « Apparences (n) ». Attendu : une rangée horizontale de vignettes verticales avec leurs noms ; la première s'appelle « Apparence classique » ; aucune variante de couleur.
2. **Plein écran** : appuyer sur une vignette. Attendu : fond noir, illustration en grand, titre « k / n », nom en bas.
3. **Navigation** : glisser vers la gauche et la droite ; utiliser les flèches. Attendu : sur la première apparence pas de flèche gauche, sur la dernière pas de flèche droite ; le titre et le nom suivent.
4. **Zoom** : pincer (mobile) ou utiliser la molette/pavé tactile (web). Attendu : zoom jusqu'à ×4.
5. **Champion à une seule apparence** (s'il en existe dans les données) : la section n'apparaît pas.
6. **Lien mort** : bloquer le domaine des images : le visuel de remplacement discret remplace l'illustration.

## Tests automatisés

```bash
flutter test test/champions/models/champion_skin_test.dart
flutter analyze lib/champions/models lib/champion_detail
```

| Exigence | Vérification |
|----------|--------------|
| FR-001, FR-010 | `champion_skin_test.dart` (`écarte les variantes de couleur`, `tolère l absence de liste`) |
| FR-002 | `champion_skin_test.dart` (`nomme l apparence d origine en français`) |
| FR-008 | `champion_skin_test.dart` (`construit les adresses des illustrations`) |
| FR-003 à FR-007, FR-009 | à la main (scénarios 1 à 4) ; pas de test de widget |
