import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// Longueur maximale d'un nom : au-delà, il ne tient plus au-dessus d'une
/// colonne de la draft ni dans les étiquettes du bilan.
const playerNameMaxLength = 12;

/// Vérifie un nom de joueur et renvoie le message d'erreur, ou `null` s'il est
/// valable. Deux joueurs ne peuvent pas porter le même nom : le bilan ne
/// saurait plus lequel a gagné.
String? validatePlayerName(String raw, {required String otherName}) {
  final name = raw.trim();
  if (name.isEmpty) return 'Saisissez un nom.';
  if (name.toLowerCase() == otherName.trim().toLowerCase()) {
    return 'Ce nom est déjà pris par l’autre joueur.';
  }

  return null;
}

/// Demande le nom d'un joueur. Renvoie le nom saisi, ou `null` si on annule.
class PlayerNameDialog extends StatefulWidget {
  final String currentName;
  final String otherName;

  const PlayerNameDialog({
    super.key,
    required this.currentName,
    required this.otherName,
  });

  static Future<String?> show(
    BuildContext context, {
    required String currentName,
    required String otherName,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) =>
          PlayerNameDialog(currentName: currentName, otherName: otherName),
    );
  }

  @override
  State<PlayerNameDialog> createState() => _PlayerNameDialogState();
}

class _PlayerNameDialogState extends State<PlayerNameDialog> {
  late final controller = TextEditingController(text: widget.currentName);
  String? error;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void submit() {
    final problem = validatePlayerName(
      controller.text,
      otherName: widget.otherName,
    );
    if (problem != null) {
      setState(() => error = problem);

      return;
    }
    Navigator.pop(context, controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Nom du joueur', style: AppTheme.serif(size: 20)),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: playerNameMaxLength,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => submit(),
        decoration: InputDecoration(labelText: 'Nom', errorText: error),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(onPressed: submit, child: const Text('Valider')),
      ],
    );
  }
}
