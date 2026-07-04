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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Gallery',
                        style: textTheme.headlineSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.34),
                          ),
                          color: Colors.black.withValues(alpha: 0.22),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 54,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Gallery coming soon',
                              textAlign: TextAlign.center,
                              style: textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'This is a full-screen modal for wedding photos, highlights, and swipe content later.',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.88),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
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
