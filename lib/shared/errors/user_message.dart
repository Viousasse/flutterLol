import '../../data_dragon/data_dragon_exception.dart';

/// Message affichable pour une panne de chargement.
///
/// Une [DataDragonException] sait déjà quoi dire ; tout le reste — format de
/// données inattendu, bug de parsing — tombe sur une formule générique, pour
/// qu'aucune erreur ne puisse laisser un écran sans issue.
String userMessageFor(Object error) {
  if (error is DataDragonException) return error.message;

  return 'Chargement impossible pour le moment.';
}
