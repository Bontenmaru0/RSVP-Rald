import 'dart:ui';

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: ColoredBox(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: const [
            Positioned.fill(child: _WeddingBackground()),
            Positioned.fill(child: _WeddingOverlay()),
            Positioned.fill(child: _WeddingNavigationRail()),
          ],
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
