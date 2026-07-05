import 'package:flutter/material.dart';

import 'home_content.dart';

class HomeAssetCache {
  HomeAssetCache._();

  static Future<void>? _warmUpFuture;

  static Future<void> warmUp(BuildContext context) {
    final existingFuture = _warmUpFuture;
    if (existingFuture != null) {
      return existingFuture;
    }

    final warmUpFuture = Future.wait<void>([
      precacheImage(const AssetImage(homeBackgroundAssetPath), context),
      precacheImage(AssetImage(churchLocationDetails.qrAssetPath), context),
      precacheImage(
        AssetImage(receptionLocationDetails.qrAssetPath),
        context,
      ),
      for (final imagePath in galleryImagePaths)
        precacheImage(AssetImage(imagePath), context),
    ]);

    _warmUpFuture = warmUpFuture;
    return warmUpFuture;
  }
}
