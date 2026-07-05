import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/home_content.dart';
import '../teaser_video_card.dart';

Future<void> showGalleryModal(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Gallery',
    barrierColor: Colors.black.withValues(alpha: 0.32),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return const GalleryModal();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      final slide = Tween<Offset>(
        begin: const Offset(-0.22, 0),
        end: Offset.zero,
      ).animate(curved);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1.0).animate(curved),
          child: SlideTransition(
            position: slide,
            child: child,
          ),
        ),
      );
    },
  );
}

class GalleryModal extends StatelessWidget {
  const GalleryModal({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GalleryViewer(
      images: galleryImagePaths,
      celebrantTitle: "Gerald and Mervielynn's Gallery",
      titleStyle: textTheme.headlineSmall?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class GalleryViewer extends StatefulWidget {
  const GalleryViewer({
    super.key,
    required this.images,
    required this.celebrantTitle,
    required this.titleStyle,
  });

  final List<String> images;
  final String celebrantTitle;
  final TextStyle? titleStyle;

  @override
  State<GalleryViewer> createState() => _GalleryViewerState();
}

class _GalleryViewerState extends State<GalleryViewer> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final mediaSize = MediaQuery.sizeOf(context);
    final isCompact = mediaSize.height < 700 || mediaSize.width < 380;
    final rootPadding = EdgeInsets.all(isCompact ? 16 : 20);
    final topGap = isCompact ? 10.0 : 14.0;
    final betweenImageAndStrip = isCompact ? 10.0 : 14.0;
    final galleryCount = widget.images.length + 1;

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'lib/assets/wedding-imgs/default-app-bg.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
          ),
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Image.asset(
              'lib/assets/wedding-imgs/default-app-bg.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.low,
            ),
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.48),
          ),
          Positioned.fill(
            child: GalleryScatterLayer(images: widget.images),
          ),
          SafeArea(
            child: Padding(
              padding: rootPadding,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.celebrantTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: widget.titleStyle,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        color: Colors.white,
                      ),
                    ],
                  ),
                  SizedBox(height: topGap),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 760),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: colorScheme.primary
                                          .withValues(alpha: 0.38),
                                      width: 1.4,
                                    ),
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      PageView.builder(
                                        controller: _pageController,
                                        itemCount: galleryCount,
                                        onPageChanged: (index) {
                                          setState(() => _currentIndex = index);
                                        },
                                        itemBuilder: (context, index) {
                                          if (index == 0) {
                                            return Padding(
                                              padding: EdgeInsets.all(
                                                isCompact ? 10 : 12,
                                              ),
                                              child: const TeaserVideoCard(
                                                assetPath:
                                                    'lib/assets/wedding-imgs/teaser-video.mp4',
                                              ),
                                            );
                                          }

                                          return Padding(
                                            padding: EdgeInsets.all(
                                              isCompact ? 10 : 12,
                                            ),
                                            child: ZoomableGalleryImage(
                                              imagePath: widget.images[index - 1],
                                            ),
                                          );
                                        },
                                      ),
                                      Positioned(
                                        top: 14,
                                        right: 14,
                                        child: GalleryCounter(
                                          currentIndex: _currentIndex + 1,
                                          total: galleryCount,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: betweenImageAndStrip),
                        GalleryPreviewStrip(
                          images: widget.images,
                          includeTeaser: true,
                          currentIndex: _currentIndex,
                          onTapPreview: (index) {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOutCubic,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  if (!isCompact) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Swipe left or right to browse, pinch to zoom, and the counter keeps your place.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.84),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GalleryScatterLayer extends StatelessWidget {
  const GalleryScatterLayer({super.key, required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final maxHeight = constraints.maxHeight;

          return Stack(
            children: [
              for (var i = 0; i < images.length; i++)
                _buildPhoto(
                  imagePath: images[i],
                  index: i,
                  maxWidth: maxWidth,
                  maxHeight: maxHeight,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPhoto({
    required String imagePath,
    required int index,
    required double maxWidth,
    required double maxHeight,
  }) {
    final sizeSeed = (index % 5) / 4.0;
    final width = 70 + (sizeSeed * 54);
    final height = width * 1.12;
    final availableWidth = math.max(0.0, maxWidth - width - 12);
    final availableHeight = math.max(0.0, maxHeight - height - 12);
    final xBase = (math.sin(index * 1.4) + 1) / 2;
    final yBase = (math.cos(index * 1.1) + 1) / 2;
    final left = availableWidth * xBase;
    final top = availableHeight * yBase;
    final rotation = math.sin(index * 0.85) * 0.24;
    final opacity = 0.10 + ((index % 4) * 0.025);

    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: rotation,
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.16),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.low,
            ),
          ),
        ),
      ),
    );
  }
}

class GalleryPreviewStrip extends StatelessWidget {
  const GalleryPreviewStrip({
    super.key,
    required this.images,
    required this.includeTeaser,
    required this.currentIndex,
    required this.onTapPreview,
  });

  final List<String> images;
  final bool includeTeaser;
  final int currentIndex;
  final ValueChanged<int> onTapPreview;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length + (includeTeaser ? 1 : 0),
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isActive = index == currentIndex;
          final isTeaser = includeTeaser && index == 0;
          final imageIndex = includeTeaser ? index - 1 : index;

          return GestureDetector(
            onTap: () => onTapPreview(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(vertical: 2),
              width: 68,
              height: 88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white.withValues(alpha: 0.14),
                  width: isActive ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (isTeaser)
                        Container(
                          color: Colors.black,
                          child: const Center(
                            child: Icon(
                              Icons.play_circle_fill,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                        )
                      else
                        Image.asset(
                          images[imageIndex],
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.low,
                        ),
                      if (isTeaser)
                        Positioned(
                          left: 6,
                          right: 6,
                          bottom: 6,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Text(
                                'Teaser',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (isActive)
                        Container(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.12),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ZoomableGalleryImage extends StatelessWidget {
  const ZoomableGalleryImage({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            panEnabled: true,
            boundaryMargin: const EdgeInsets.all(48),
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        );
      },
    );
  }
}

class GalleryCounter extends StatelessWidget {
  const GalleryCounter({
    super.key,
    required this.currentIndex,
    required this.total,
  });

  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          '$currentIndex out of $total',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
