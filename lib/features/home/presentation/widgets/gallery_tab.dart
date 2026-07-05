import 'dart:ui';

import 'package:flutter/material.dart';

import 'gallery_modal.dart';

class GalleryTab extends StatefulWidget {
  const GalleryTab({super.key});

  @override
  State<GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends State<GalleryTab> {
  static const double _tabWidth = 54;
  static const double _tabHeight = 120;

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    if (velocity > 120) {
      showGalleryModal(context);
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
          onTap: () => showGalleryModal(context),
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
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.primary.withValues(alpha: 0.45),
                        width: 1.1,
                      ),
                      right: BorderSide(
                        color: colorScheme.primary.withValues(alpha: 0.45),
                        width: 1.1,
                      ),
                      bottom: BorderSide(
                        color: colorScheme.primary.withValues(alpha: 0.45),
                        width: 1.1,
                      ),
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
