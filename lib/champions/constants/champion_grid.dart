import 'package:flutter/widgets.dart';

/// Grille des cartes de champions, commune à la liste et aux favoris.
///
/// Deux colonnes sur un téléphone, davantage sur un écran large : les cartes
/// gardent ainsi une taille raisonnable au lieu de s'étirer.
const championGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 220,
  crossAxisSpacing: 12,
  mainAxisSpacing: 12,
  childAspectRatio: 0.82,
);
