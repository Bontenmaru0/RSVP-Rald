import 'dart:async';

import 'package:flutter/material.dart';

import 'teaser_video_cache.dart';

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
  TeaserVideoSession? _session;
  Timer? _controlsHideTimer;
  bool _isMuted = true;
  bool _showControls = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    TeaserVideoCache.sessionFor(widget.assetPath).then((session) {
      if (!mounted) {
        return;
      }
      setState(() {
        _session = session;
        _isMuted = session.isMuted;
      });
    }).catchError((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorText = 'Teaser video could not load.';
      });
    });
  }

  @override
  void dispose() {
    _controlsHideTimer?.cancel();
    _session?.detach();
    super.dispose();
  }

  void _scheduleControlsHide() {
    _controlsHideTimer?.cancel();
    final session = _session;
    if (session == null || !session.isPlaying) {
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
    if (mounted) {
      setState(() {
        _showControls = true;
      });
    }
    final session = _session;
    if (session != null && session.isPlaying) {
      _scheduleControlsHide();
    }
  }

  void _togglePlay() {
    final session = _session;
    if (session == null || !session.isReady || _errorText != null) {
      return;
    }

    if (session.isPlaying) {
      session.pause();
      _controlsHideTimer?.cancel();
      setState(() {
        _showControls = true;
      });
    } else {
      session.play();
      setState(() {
        _showControls = true;
      });
      _scheduleControlsHide();
    }
  }

  void _toggleMute() {
    final session = _session;
    if (session == null || !session.isReady || _errorText != null) {
      return;
    }

    setState(() {
      session.toggleMute();
      _isMuted = session.isMuted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final session = _session;
    final isReady = session?.isReady ?? false;

    if (_errorText != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Center(
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
      );
    }

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
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.82),
                      Colors.black.withValues(alpha: 0.40),
                      Colors.black.withValues(alpha: 0.82),
                    ],
                  ),
                ),
              ),
              if (isReady && session != null)
                Center(child: session.buildSurface())
              else
                Center(
                  child: Icon(
                    Icons.play_circle_fill_rounded,
                    size: 92,
                    color: colorScheme.primary.withValues(alpha: 0.90),
                  ),
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
                          session?.isPlaying == true
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
                              isReady ? 'Teaser video' : 'Loading teaser',
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
