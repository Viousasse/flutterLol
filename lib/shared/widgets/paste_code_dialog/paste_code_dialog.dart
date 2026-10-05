import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

/// Une boîte où l'on colle un code reçu d'un ami.
///
/// Elle reste ouverte tant que le texte n'est pas compris : se tromper de
/// copier-coller ne doit pas obliger à rouvrir la boîte.
class PasteCodeDialog<T> extends StatefulWidget {
  final String title;
  final String hint;
  final T? Function(String text) parse;
  final String invalidMessage;

  const PasteCodeDialog._({
    required this.title,
    required this.hint,
    required this.parse,
    required this.invalidMessage,
  });

  /// Ouvre la boîte et renvoie ce que [parse] a lu, ou `null` si l'on annule.
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required String hint,
    required T? Function(String text) parse,
    required String invalidMessage,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => PasteCodeDialog<T>._(
        title: title,
        hint: hint,
        parse: parse,
        invalidMessage: invalidMessage,
      ),
    );
  }

  @override
  State<PasteCodeDialog<T>> createState() => _PasteCodeDialogState<T>();
}

class _PasteCodeDialogState<T> extends State<PasteCodeDialog<T>> {
  final controller = TextEditingController();
  bool isInvalid = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> paste() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text;
      if (text == null || !mounted) return;
      setState(() {
        controller.text = text;
        isInvalid = false;
      });
    } catch (_) {
      // Presse-papiers indisponible : on laisse la personne coller à la main.
    }
  }

  void submit() {
    final result = widget.parse(controller.text);
    if (result == null) {
      setState(() => isInvalid = true);

      return;
    }

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(widget.title, style: AppTheme.serif(size: 20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            minLines: 3,
            maxLines: 6,
            keyboardType: TextInputType.multiline,
            onChanged: (_) {
              if (isInvalid) setState(() => isInvalid = false);
            },
            decoration: InputDecoration(
              hintText: widget.hint,
              labelText: 'Code à coller',
              errorText: isInvalid ? widget.invalidMessage : null,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: paste,
            icon: const Icon(Icons.content_paste, size: 18),
            label: const Text('Coller'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        TextButton(onPressed: submit, child: const Text('Importer')),
      ],
    );
  }
}
