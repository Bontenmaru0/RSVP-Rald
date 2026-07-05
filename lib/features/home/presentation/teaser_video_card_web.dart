import 'dart:async';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

class TeaserVideoCard extends StatefulWidget {
  const TeaserVideoCard({
    super.key,
    required this.assetPath,
  });

  final String assetPath;

  @override
  State<TeaserVideoCard> createState() => _TeaserVideoCardState();
}

class _TeaserVideoCardState extends State<TeaserVideoCard> {
  late final html.VideoElement _videoElement;
  late final String _viewType;
  Timer? _controlsHideTimer;
  bool _isMuted = true;
  bool _isReady = false;
  bool _showControls = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _viewType = 'teaser-video-${DateTime.now().microsecondsSinceEpoch}';
    final assetUrl = ui_web.assetManager.getAssetUrl(widget.assetPath);

    _videoElement = html.VideoElement()
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

    _videoElement.onLoadedMetadata.listen((_) {
      if (!mounted) {
        return;
      }
      setState(() => _isReady = true);
    });

    _videoElement.onError.listen((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorText = 'Teaser video could not load.';
      });
    });

    // Register the platform view once.
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _videoElement,
    );
  }

  @override
  void dispose() {
    _controlsHideTimer?.cancel();
    _videoElement.pause();
    _videoElement.removeAttribute('src');
    _videoElement.load();
    super.dispose();
  }

  void _scheduleControlsHide() {
    _controlsHideTimer?.cancel();
    if (_videoElement.paused) {
      return;
    }

    _controlsHideTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showControls = false;
      });
    });
  }

  void _revealControls() {
    setState(() {
      _showControls = true;
    });
    if (!_videoElement.paused) {
      _scheduleControlsHide();
    }
  }

  Future<void> _togglePlay() async {
    if (!_isReady || _errorText != null) {
      return;
    }

    try {
      if (_videoElement.paused) {
        await _videoElement.play();
        _scheduleControlsHide();
      } else {
        _videoElement.pause();
        _controlsHideTimer?.cancel();
        _showControls = true;
      }
      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorText = 'Teaser video could not start playback.';
        });
      }
    }
  }

  void _toggleMute() {
    if (!_isReady || _errorText != null) {
      return;
    }

    setState(() {
      _isMuted = !_isMuted;
      _videoElement.muted = _isMuted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: MouseRegion(
        onEnter: (_) => _revealControls(),
        onHover: (_) => _revealControls(),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _revealControls,
          child: Stack(
            fit: StackFit.expand,
            children: [
          Container(
            color: Colors.black.withValues(alpha: 0.72),
          ),
          if (_errorText != null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_circle_fill_rounded,
                    size: 72,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _errorText!,
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          if (_errorText == null)
            Positioned.fill(
              child: HtmlElementView(viewType: _viewType),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.06),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.28),
                  ],
                ),
              ),
            ),
          ),
          IgnorePointer(
            ignoring: !_showControls,
            child: AnimatedOpacity(
              opacity: _showControls ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: Center(
                child: Material(
                  color: Colors.black.withValues(alpha: 0.28),
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: _togglePlay,
                    iconSize: 40,
                    color: Colors.white,
                    icon: Icon(
                      _isReady && !_videoElement.paused
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: IgnorePointer(
              ignoring: !_showControls,
              child: AnimatedOpacity(
                opacity: _showControls ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.30),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          _isReady ? 'Teaser video' : 'Loading teaser',
                          style: textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Material(
                      color: Colors.black.withValues(alpha: 0.30),
                      borderRadius: BorderRadius.circular(999),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: _toggleMute,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isMuted
                                    ? Icons.volume_off_rounded
                                    : Icons.volume_up_rounded,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isMuted ? 'Muted' : 'Sound on',
                                style: textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}
