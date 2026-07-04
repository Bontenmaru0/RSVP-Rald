import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

void _openGalleryModal(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Gallery',
    barrierColor: Colors.black.withValues(alpha: 0.32),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return const _GalleryModal();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: ColoredBox(
        color: Colors.black,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity!.abs() > 120 &&
                details.primaryVelocity! > 0) {
              _openGalleryModal(context);
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: const [
              Positioned.fill(child: _WeddingBackground()),
              Positioned.fill(child: _WeddingOverlay()),
              Positioned.fill(child: _GalleryTab()),
              Positioned.fill(child: _WeddingNavigationRail()),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeddingBackground extends StatelessWidget {
  const _WeddingBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'lib/assets/wedding-imgs/default-app-bg.png',
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
        ),
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Image.asset(
            'lib/assets/wedding-imgs/default-app-bg.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
          ),
        ),
        Center(
          child: AspectRatio(
            aspectRatio: 853 / 1844,
            child: Image.asset(
              'lib/assets/wedding-imgs/default-app-bg.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ],
    );
  }
}

class _WeddingOverlay extends StatelessWidget {
  const _WeddingOverlay();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.18),
            Colors.black.withValues(alpha: 0.08),
            Colors.black.withValues(alpha: 0.30),
          ],
        ),
      ),
    );
  }
}

class _WeddingNavigationRail extends StatelessWidget {
  const _WeddingNavigationRail();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 700;

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: EdgeInsets.only(
            right: isMobile ? 12 : 24,
            bottom: 24,
          ),
          child: _GlassRail(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _RailIconButton(
                  icon: Icons.church,
                  label: 'Church',
                  colorScheme: colorScheme,
                  onPressed: () {},
                ),
                const SizedBox(height: 14),
                _RailIconButton(
                  icon: Icons.wine_bar,
                  label: 'Reception',
                  colorScheme: colorScheme,
                  onPressed: () {},
                ),
                const SizedBox(height: 14),
                _RailIconButton(
                  icon: Icons.message,
                  label: 'RSVP',
                  colorScheme: colorScheme,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryTab extends StatefulWidget {
  const _GalleryTab();

  @override
  State<_GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends State<_GalleryTab> {
  static const double _tabWidth = 54;
  static const double _tabHeight = 120;

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    if (velocity > 120) {
      _openGalleryModal(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _openGalleryModal(context),
          onHorizontalDragEnd: _handleDragEnd,
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(22),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  width: _tabWidth,
                  height: _tabHeight,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(22),
                    ),
                    color: Colors.black.withValues(alpha: 0.20),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.45),
                      width: 1.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.26),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 10),
                      RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          'Gallery',
                          style: textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryModal extends StatelessWidget {
  const _GalleryModal();

  static const List<String> _galleryImages = [
    'lib/assets/wedding-imgs/1.jpg',
    'lib/assets/wedding-imgs/2.jpg',
    'lib/assets/wedding-imgs/3.jpg',
    'lib/assets/wedding-imgs/4.jpg',
    'lib/assets/wedding-imgs/5.jpg',
    'lib/assets/wedding-imgs/6.jpg',
    'lib/assets/wedding-imgs/7.jpg',
    'lib/assets/wedding-imgs/8.jpg',
    'lib/assets/wedding-imgs/9.jpg',
    'lib/assets/wedding-imgs/10.jpg',
    'lib/assets/wedding-imgs/11.jpg',
    'lib/assets/wedding-imgs/12.jpg',
    'lib/assets/wedding-imgs/13.jpg',
    'lib/assets/wedding-imgs/14.jpg',
    'lib/assets/wedding-imgs/a 1.jpg',
    'lib/assets/wedding-imgs/A 2.jpg',
    'lib/assets/wedding-imgs/A 3.jpg',
    'lib/assets/wedding-imgs/A 4.jpg',
    'lib/assets/wedding-imgs/A 5.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return _GalleryViewer(
      images: _galleryImages,
      celebrantTitle: "Gerald and Mervielynn's Gallery",
      titleStyle: textTheme.headlineSmall?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _GalleryViewer extends StatefulWidget {
  const _GalleryViewer({
    required this.images,
    required this.celebrantTitle,
    required this.titleStyle,
  });

  final List<String> images;
  final String celebrantTitle;
  final TextStyle? titleStyle;

  @override
  State<_GalleryViewer> createState() => _GalleryViewerState();
}

class _GalleryViewerState extends State<_GalleryViewer> {
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
            child: _GalleryScatterLayer(images: widget.images),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        widget.celebrantTitle,
                        style: widget.titleStyle,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
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
                                        itemCount: widget.images.length,
                                        onPageChanged: (index) {
                                          setState(() => _currentIndex = index);
                                        },
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: _ZoomableGalleryImage(
                                              imagePath: widget.images[index],
                                            ),
                                          );
                                        },
                                      ),
                                      Positioned(
                                        top: 14,
                                        right: 14,
                                        child: _GalleryCounter(
                                          currentIndex: _currentIndex + 1,
                                          total: widget.images.length,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _GalleryPreviewStrip(
                          images: widget.images,
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
                  const SizedBox(height: 16),
                  Text(
                    'Swipe left or right to browse, pinch to zoom, and the counter keeps your place.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.84),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryScatterLayer extends StatelessWidget {
  const _GalleryScatterLayer({required this.images});

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

class _GalleryPreviewStrip extends StatelessWidget {
  const _GalleryPreviewStrip({
    required this.images,
    required this.currentIndex,
    required this.onTapPreview,
  });

  final List<String> images;
  final int currentIndex;
  final ValueChanged<int> onTapPreview;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isActive = index == currentIndex;

          return GestureDetector(
            onTap: () => onTapPreview(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 66,
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
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    images[index],
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.low,
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
          );
        },
      ),
    );
  }
}

class _ZoomableGalleryImage extends StatelessWidget {
  const _ZoomableGalleryImage({required this.imagePath});

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

class _GalleryCounter extends StatelessWidget {
  const _GalleryCounter({
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

class _GlassRail extends StatelessWidget {
  const _GlassRail({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _RailIconButton extends StatelessWidget {
  const _RailIconButton({
    required this.icon,
    required this.label,
    required this.colorScheme,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          splashFactory: InkRipple.splashFactory,
          child: Ink(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary.withValues(alpha: 0.18),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.55),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 26,
              color: colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
