import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home_content.dart';

class HomeAssetCache {
  HomeAssetCache._();

  static Future<void>? _warmUpFuture;
  static final Map<String, Uint8List> _assetBytes = <String, Uint8List>{};

  static Future<void> warmUp(BuildContext context) {
    final existingFuture = _warmUpFuture;
    if (existingFuture != null) {
      return existingFuture;
    }

    final warmUpFuture = Future.wait<void>([
      precacheImage(const AssetImage(homeBackgroundAssetPath), context),
      _loadGalleryImageBytes(homeBackgroundAssetPath),
      precacheImage(AssetImage(churchLocationDetails.qrAssetPath), context),
      _loadGalleryImageBytes(churchLocationDetails.qrAssetPath),
      precacheImage(
        AssetImage(receptionLocationDetails.qrAssetPath),
        context,
      ),
      _loadGalleryImageBytes(receptionLocationDetails.qrAssetPath),
      for (final imagePath in galleryImagePaths) _loadGalleryImageBytes(imagePath),
    ]);

    _warmUpFuture = warmUpFuture;
    return warmUpFuture;
  }

  static Uint8List? galleryImageBytes(String imagePath) {
    return _assetBytes[imagePath];
  }

  static Uint8List? assetBytes(String assetPath) {
    return _assetBytes[assetPath];
  }

  static Future<void> _loadGalleryImageBytes(String imagePath) async {
    if (_assetBytes.containsKey(imagePath)) {
      return;
    }

    final data = await rootBundle.load(imagePath);
    _assetBytes[imagePath] = data.buffer.asUint8List();
  }
}
