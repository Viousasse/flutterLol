import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Copie [text] dans le presse-papiers et le dit à l'utilisateur.
///
/// Sur certaines plateformes la copie peut être refusée : on le dit aussi,
/// pour qu'on ne colle pas un ancien contenu en croyant avoir copié.
Future<void> copyToClipboard(
  BuildContext context,
  String text, {
  String message = 'Copié dans le presse-papiers',
}) async {
  final messenger = ScaffoldMessenger.of(context);

  try {
    await Clipboard.setData(ClipboardData(text: text));
    messenger.showSnackBar(SnackBar(content: Text(message)));
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Copie impossible sur cet appareil')),
    );
  }
}
