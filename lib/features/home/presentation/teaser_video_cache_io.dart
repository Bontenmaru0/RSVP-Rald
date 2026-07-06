import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'teaser_video_session.dart';

class TeaserVideoCache {
  TeaserVideoCache._();

  static final Map<String, Future<_TeaserVideoSession>> _controllers =
      <String, Future<_TeaserVideoSession>>{};

  static Future<_TeaserVideoSession> sessionFor(String assetPath) {
    final existing = _controllers[assetPath];
    if (existing != null) {
      return existing;
    }

    final sessionFuture = _createSession(assetPath);
    _controllers[assetPath] = sessionFuture;
    return sessionFuture;
  }

  static Future<_TeaserVideoSession> _createSession(String assetPath) async {
    final controller = VideoPlayerController.asset(assetPath)
      ..setLooping(true)
      ..setVolume(0);

    await controller.initialize();
    return _TeaserVideoSession(
      controller,
      'teaser-video-${assetPath.hashCode}',
    );
  }
}

class _TeaserVideoSession implements TeaserVideoSession {
  _TeaserVideoSession(this._controller, this._viewType);

  final VideoPlayerController _controller;
  final String _viewType;

  @override
  String get viewType => _viewType;

  @override
  bool get isReady => _controller.value.isInitialized;

  @override
  bool get isPlaying => _controller.value.isPlaying;

  @override
  bool get isMuted => _controller.value.volume == 0;

  @override
  Future<void> get ready => Future<void>.value();

  @override
  Widget buildSurface() {
    return VideoPlayer(_controller);
  }

  @override
  void play() => _controller.play();

  @override
  void pause() => _controller.pause();

  @override
  void toggleMute() {
    _controller.setVolume(isMuted ? 1 : 0);
  }

  @override
  void detach() {
    _controller.pause();
  }
}
