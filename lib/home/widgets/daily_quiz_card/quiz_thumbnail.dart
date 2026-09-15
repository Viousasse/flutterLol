import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../shared/widgets/remote_image/remote_image.dart';

import '../../../champions/models/champion.dart';

/// L'icône du champion à deviner, floutée tant que la question n'a pas de
/// réponse pour ne pas la révéler avant coup.
class QuizThumbnail extends StatelessWidget {
  final Champion champion;
  final bool revealed;

  const QuizThumbnail({
    super.key,
    required this.champion,
    required this.revealed,
  });

  @override
  Widget build(BuildContext context) {
    final image = RemoteImage(url: champion.imageUrl);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 56,
        height: 56,
        child: revealed
            ? image
            : ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
                child: image,
              ),
      ),
    );
  }
}
