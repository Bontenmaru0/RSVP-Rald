import 'dart:async';

import 'package:flutter/material.dart';

import '../data/home_asset_cache.dart';
import 'widgets/gallery_modal.dart';
import 'widgets/gallery_tab.dart';
import 'widgets/wedding_background.dart';
import 'widgets/wedding_navigation_rail.dart';
import 'widgets/wedding_overlay.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _didWarmUpAssets = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didWarmUpAssets) {
      return;
    }
    _didWarmUpAssets = true;
    unawaited(HomeAssetCache.warmUp(context));
  }

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
            final velocity = details.primaryVelocity;
            if (velocity != null && velocity.abs() > 120 && velocity > 0) {
              showGalleryModal(context);
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: const [
              Positioned.fill(child: WeddingBackground()),
              Positioned.fill(child: WeddingOverlay()),
              Positioned.fill(child: GalleryTab()),
              Positioned.fill(child: WeddingNavigationRail()),
            ],
          ),
        ),
      ),
    );
  }
}
