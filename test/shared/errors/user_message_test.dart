import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/data_dragon/data_dragon_exception.dart';
import 'package:monapp/shared/errors/user_message.dart';

void main() {
  test('reprend le message porté par une panne Data Dragon', () {
    const error = DataDragonException('Pas de connexion internet.');

    expect(userMessageFor(error), 'Pas de connexion internet.');
  });

  test('retombe sur un message générique pour toute autre erreur', () {
    expect(userMessageFor(TypeError()), 'Chargement impossible pour le moment.');
  });
}
