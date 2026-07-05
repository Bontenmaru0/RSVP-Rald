import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/home_content.dart';
import 'location_modal.dart';

class WeddingNavigationRail extends StatelessWidget {
  const WeddingNavigationRail({super.key});

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
                  label: 'Church Location',
                  colorScheme: colorScheme,
                  onPressed: () => showLocationModal(
                    context,
                    details: churchLocationDetails,
                  ),
                ),
                const SizedBox(height: 14),
                _RailIconButton(
                  icon: Icons.wine_bar,
                  label: 'Reception Location',
                  colorScheme: colorScheme,
                  onPressed: () => showLocationModal(
                    context,
                    details: receptionLocationDetails,
                  ),
                ),
                const SizedBox(height: 14),
                _RailIconButton(
                  icon: Icons.message,
                  label: "Respond to our invitation",
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
