import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'teaser_video_card.dart';

void _openGalleryModal(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Gallery',
    barrierColor: Colors.black.withValues(alpha: 0.32),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return const _GalleryModal();
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

void _openLocationModal(
  BuildContext context, {
  required _LocationDetails details,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: details.title,
    barrierColor: Colors.black.withValues(alpha: 0.34),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return _LocationModal(details: details);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      final slide = Tween<Offset>(
        begin: const Offset(0.18, 0),
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

const _churchLocationDetails = _LocationDetails(
  title: 'Church Location',
  subtitle: "Christ's Chosen Church",
  qrAssetPath: 'lib/assets/wedding-imgs/ChristsChosenChurch.png',
  mapUrl:
      'https://www.google.com/maps/place/Christ\'s+Chosen+Church+Philippines+Inc./@14.8662524,120.824729,17z/data=!3m1!4b1!4m6!3m5!1s0x33965317ba459c25:0xd87e2fdd5cf41dc8!8m2!3d14.8662524!4d120.824729!16s%2Fg%2F11lm4bf1zv?entry=ttu&g_ep=EgoyMDI2MDYyOS4wIKXMDSoASAFQAw%3D%3D',
  address: 'Maunlad Subdivision, Malinis, Malolos, 3000 Bulacan',
  mobileNumber: '09178829887',
);

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
                  label: 'Church Location',
                  colorScheme: colorScheme,
                  onPressed: () => _openLocationModal(
                    context,
                    details: _churchLocationDetails,
                  ),
                ),
                const SizedBox(height: 14),
                _RailIconButton(
                  icon: Icons.wine_bar,
                  label: 'Reception Location',
                  colorScheme: colorScheme,
                  onPressed: () {},
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

class _LocationDetails {
  const _LocationDetails({
    required this.title,
    required this.subtitle,
    required this.qrAssetPath,
    required this.mapUrl,
    required this.address,
    required this.mobileNumber,
  });

  final String title;
  final String subtitle;
  final String qrAssetPath;
  final String mapUrl;
  final String address;
  final String mobileNumber;
}

class _LocationModal extends StatelessWidget {
  const _LocationModal({required this.details});

  final _LocationDetails details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final mediaSize = MediaQuery.sizeOf(context);
    final isCompact = mediaSize.height < 740 || mediaSize.width < 390;

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
            color: Colors.black.withValues(alpha: 0.54),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(isCompact ? 16 : 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              details.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.headlineSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              details.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.82),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        color: Colors.white,
                      ),
                    ],
                  ),
                  SizedBox(height: isCompact ? 12 : 16),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 860),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: colorScheme.primary.withValues(alpha: 0.36),
                                width: 1.2,
                              ),
                            ),
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(isCompact ? 16 : 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final qrSize = constraints.maxWidth < 360
                                          ? constraints.maxWidth
                                          : 320.0;
                                      return Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              child: Container(
                                                width: qrSize,
                                                padding: const EdgeInsets.all(14),
                                                color: Colors.white,
                                                child: Image.asset(
                                                  details.qrAssetPath,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.qr_code_2,
                                                  color: colorScheme.primary,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'QR Code',
                                                  style: textTheme.titleSmall
                                                      ?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: isCompact ? 18 : 22),
                                  _LocationInfoTile(
                                    icon: Icons.link,
                                    label: 'Map Link',
                                    value: details.mapUrl,
                                  ),
                                  const SizedBox(height: 12),
                                  _LocationInfoTile(
                                    icon: Icons.location_on_outlined,
                                    label: 'Address',
                                    value: details.address,
                                  ),
                                  const SizedBox(height: 12),
                                  _LocationInfoTile(
                                    icon: Icons.phone_outlined,
                                    label: 'Mobile Number',
                                    value: details.mobileNumber,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'These details are sourced from Google.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontStyle: FontStyle.italic,
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

class _LocationInfoTile extends StatelessWidget {
  const _LocationInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: colorScheme.primary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                SelectableText(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
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
  bool _didPrecacheImages = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecacheImages) {
      return;
    }
    _didPrecacheImages = true;
    for (final imagePath in widget.images) {
      precacheImage(AssetImage(imagePath), context);
    }
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
            child: _GalleryScatterLayer(images: widget.images),
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
                                            child: _ZoomableGalleryImage(
                                              imagePath: widget.images[index - 1],
                                            ),
                                          );
                                        },
                                      ),
                                      Positioned(
                                        top: 14,
                                        right: 14,
                                        child: _GalleryCounter(
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
                        _GalleryPreviewStrip(
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
