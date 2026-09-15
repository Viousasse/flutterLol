/// Échec de récupération des données Riot, porteur d'un message déjà rédigé
/// pour l'utilisateur : l'écran appelant l'affiche tel quel avec un bouton
/// « Réessayer » plutôt que de rester bloqué sur son indicateur de chargement.
class DataDragonException implements Exception {
  final String message;

  const DataDragonException(this.message);

  @override
  String toString() => 'DataDragonException: $message';
}
