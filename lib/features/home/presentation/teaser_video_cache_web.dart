import 'dart:async';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import 'teaser_video_session.dart';

class TeaserVideoCache {
  TeaserVideoCache._();

  static final Map<String, TeaserVideoSession> _entries =
      <String, TeaserVideoSession>{};

  static TeaserVideoSession sessionFor(String assetPath) {
    final existing = _entries[assetPath];
    if (existing != null) {
      return existing;
    }

    final session = _TeaserVideoSession(assetPath);
    _entries[assetPath] = session;
    return session;
  }
}

class _TeaserVideoSession implements TeaserVideoSession {
  _TeaserVideoSession(String assetPath)
      : viewType = 'teaser-video-${assetPath.hashCode}' {
    final assetUrl = ui_web.assetManager.getAssetUrl(assetPath);

    videoElement = html.VideoElement()
      ..src = assetUrl
      ..controls = false
      ..autoplay = false
      ..loop = true
      ..muted = true
      ..setAttribute('playsinline', 'true')
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover';

    videoElement.onLoadedMetadata.listen((_) {
      if (_readyCompleter.isCompleted) {
        return;
      }
      _readyCompleter.complete();
    });

    videoElement.onError.listen((_) {
      if (_readyCompleter.isCompleted) {
        return;
      }
      errorText = 'Teaser video could not load.';
      _readyCompleter.completeError(Exception(errorText!));
    });

    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) => videoElement,
    );

    if (isReady && !_readyCompleter.isCompleted) {
      _readyCompleter.complete();
    }
  }

  final String viewType;
  late final html.VideoElement videoElement;
  final Completer<void> _readyCompleter = Completer<void>();
  String? errorText;

  bool get isReady =>
      videoElement.readyState >= 1;

  @override
  bool get isPlaying => !videoElement.paused;

  @override
  bool get isMuted => videoElement.muted;

  @override
  Future<void> get ready => _readyCompleter.future;

  @override
  Widget buildSurface() {
    return HtmlElementView(viewType: viewType);
  }

  @override
  void play() {
    videoElement.play();
  }

  @override
  void pause() {
    videoElement.pause();
  }

  @override
  void toggleMute() {
    videoElement.muted = !videoElement.muted;
  }

  @override
  void detach() {
    videoElement.pause();
  }
}
