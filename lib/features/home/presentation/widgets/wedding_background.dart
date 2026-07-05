import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/home_content.dart';

class WeddingBackground extends StatelessWidget {
  const WeddingBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          homeBackgroundAssetPath,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
        ),
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Image.asset(
            homeBackgroundAssetPath,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
          ),
        ),
        Center(
          child: AspectRatio(
            aspectRatio: 853 / 1844,
            child: Image.asset(
              homeBackgroundAssetPath,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ],
    );
  }
}
