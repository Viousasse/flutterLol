# Quickstart : valider le constructeur de builds

## Lancer l'application

```bash
flutter run -d chrome   # ou un appareil mobile
```

Un accès réseau est utile au premier lancement (catalogue d'objets et champions Data Dragon).

## Scénarios manuels

1. **Accès** : onglet Outils, carte « Mes builds » ; onglet Objets, bouton « Builds ». Les deux ouvrent la liste.
2. **Liste vide** : sans build, un message invite à en composer une ; « Nouvelle build » est présent.
3. **Créer** : « Nouvelle build », nommer, choisir un champion (puces de rôle visibles si les données de voies sont chargées), remplir deux à six emplacements. Le prix total et les bonus cumulés se mettent à jour. « Enregistrer la build » est désactivé tant qu'aucun objet n'est choisi.
4. **Nom** : laisser vide, enregistrer : la build s'appelle « Ma build ». Le champ s'arrête à 40 caractères.
5. **Relancer** : fermer puis rouvrir l'application : les builds sont là, mêmes objets, même champion.
6. **Modifier** : ouvrir une build ancienne, remplacer un objet, enregistrer : elle passe en tête, sans doublon.
7. **Supprimer** : poubelle, confirmation « Supprimer cette build ? » ; « Annuler » ne supprime rien, « Supprimer la build » supprime.
8. **Partager** : bouton de partage : message « Résumé de la build copié ». Coller dans un éditeur : titre, objets numérotés, total, ligne « Code : LOLB1.… ».
9. **Importer (valide)** : « Importer une build », « Coller » (ou saisir) le message complet : confirmation « Build « nom » importée », la build apparaît en tête.
10. **Importer (invalide)** : coller un texte quelconque ou un code coupé : la boîte reste ouverte avec « Ce texte ne contient pas de code de build valide. » ; l'erreur disparaît en tapant.
11. **Depuis une fiche champion** : ouvrir un champion avec objets conseillés, « Créer une build avec ces objets » : l'éditeur est prérempli, rien n'est enregistré avant validation.
12. **Hors-ligne** : sans réseau et sans cache, la liste affiche un message et « Réessayer ».

## Tests automatisés

```bash
flutter test test/builds test/shared/widgets/paste_code_dialog_test.dart
flutter analyze lib/builds lib/shared/services lib/shared/widgets/paste_code_dialog
```

Correspondance : FR-002 `build_stats_test.dart` ; FR-004 et FR-015 `build_store_test.dart` ; FR-005, FR-013 et FR-014 `builds_page_test.dart` ; FR-009 `build_share_text_test.dart` ; FR-010 à FR-012 `build_share_code_test.dart` et `build_import_test.dart` ; FR-013 `paste_code_dialog_test.dart`. FR-001, FR-003, FR-006 à FR-008 et FR-016 sont validés à la main (scénarios 3, 4, 1, 11, 3) : l'éditeur n'a pas de test de widget.
