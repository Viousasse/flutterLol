import 'package:flutter/widgets.dart';

/// Largeur maximale d'une carte d'objet : au-delà, la grille ajoute une
/// colonne plutôt que d'étirer les cartes sur un écran large.
const _maxCardWidth = 130.0;

/// Hauteur d'une carte à taille de texte normale : icône, nom sur deux lignes
/// et prix. Seule la partie texte grandit avec la taille de police choisie par
/// l'utilisateur.
const _fixedHeight = 100.0;
const _textHeight = 50.0;

const _spacing = 12.0;

/// Grille des cartes d'objets, commune à l'onglet Objets et aux favoris.
///
/// La hauteur est fixe plutôt que proportionnelle à la largeur : avec un ratio,
/// une carte devenait très haute dès que l'écran s'élargissait.
SliverGridDelegate itemGridDelegate(BuildContext context) {
  final textScale = MediaQuery.textScalerOf(context).scale(1);

  return SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: _maxCardWidth,
    crossAxisSpacing: _spacing,
    mainAxisSpacing: _spacing,
    mainAxisExtent: _fixedHeight + _textHeight * textScale,
  );
}
