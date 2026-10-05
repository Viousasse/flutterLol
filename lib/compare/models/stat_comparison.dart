enum ComparisonWinner { left, right, tie }

/// Une caractéristique de deux champions mise face à face.
class StatComparison {
  final String label;
  final double left;
  final double right;

  /// Nombre de décimales affichées : la vitesse d'attaque en demande deux, les
  /// points de vie aucune.
  final int decimals;

  const StatComparison({
    required this.label,
    required this.left,
    required this.right,
    this.decimals = 0,
  });

  ComparisonWinner get winner {
    if (left == right) return ComparisonWinner.tie;

    return left > right ? ComparisonWinner.left : ComparisonWinner.right;
  }

  /// Part de la barre de gauche, entre 0 et 1, relative au plus grand des deux :
  /// la plus forte valeur remplit sa barre, l'autre se lit en proportion.
  double get leftFraction => _fraction(left);

  double get rightFraction => _fraction(right);

  double _fraction(double value) {
    final largest = left > right ? left : right;
    if (largest <= 0) return 0;

    return value / largest;
  }
}
