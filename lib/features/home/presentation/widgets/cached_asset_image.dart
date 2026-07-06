import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../data/home_asset_cache.dart';

class CachedAssetImage extends StatelessWidget {
  const CachedAssetImage({
    super.key,
    required this.assetPath,
    required this.fit,
    required this.filterQuality,
  });

  final String assetPath;
  final BoxFit fit;
  final FilterQuality filterQuality;

  @override
  Widget build(BuildContext context) {
    final Uint8List? bytes = HomeAssetCache.assetBytes(assetPath);
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: fit,
        filterQuality: filterQuality,
      );
    }

    return Image.asset(
      assetPath,
      fit: fit,
      filterQuality: filterQuality,
    );
  }
}
