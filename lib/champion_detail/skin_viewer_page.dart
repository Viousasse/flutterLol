import 'package:flutter/material.dart';

import '../champions/models/champion_skin.dart';
import '../shared/widgets/remote_image/remote_image.dart';
import '../theme/app_theme.dart';

/// Les apparences d'un champion en plein écran : on glisse ou on appuie sur les
/// flèches pour passer de l'une à l'autre, on pince pour zoomer.
class SkinViewerPage extends StatefulWidget {
  final List<ChampionSkin> skins;
  final int initialIndex;

  const SkinViewerPage({
    super.key,
    required this.skins,
    required this.initialIndex,
  });

  @override
  State<SkinViewerPage> createState() => _SkinViewerPageState();
}

class _SkinViewerPageState extends State<SkinViewerPage> {
  static const _slide = Duration(milliseconds: 250);

  late final PageController controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int currentIndex = widget.initialIndex;

  bool get _hasPrevious => currentIndex > 0;
  bool get _hasNext => currentIndex < widget.skins.length - 1;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _go(int offset) {
    controller.animateToPage(
      currentIndex + offset,
      duration: _slide,
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final skin = widget.skins[currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          '${currentIndex + 1} / ${widget.skins.length}',
          style: AppTheme.mono(size: 12, color: Colors.white70),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: controller,
            itemCount: widget.skins.length,
            onPageChanged: (index) => setState(() => currentIndex = index),
            itemBuilder: (context, index) => InteractiveViewer(
              maxScale: 4,
              child: Center(
                child: RemoteImage(
                  url: widget.skins[index].splashUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          if (_hasPrevious)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: 'Apparence précédente',
                onPressed: () => _go(-1),
                icon: const Icon(Icons.chevron_left, size: 32, color: Colors.white),
              ),
            ),
          if (_hasNext)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: 'Apparence suivante',
                onPressed: () => _go(1),
                icon: const Icon(Icons.chevron_right, size: 32, color: Colors.white),
              ),
            ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 28,
            child: Text(
              skin.name,
              textAlign: TextAlign.center,
              style: AppTheme.serif(size: 22, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
