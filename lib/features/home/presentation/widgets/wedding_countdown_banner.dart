import 'dart:async';
import 'dart:math' as math;

import 'dart:ui';

import 'package:flutter/material.dart';

class WeddingCountdownBanner extends StatefulWidget {
  const WeddingCountdownBanner({super.key});

  @override
  State<WeddingCountdownBanner> createState() => _WeddingCountdownBannerState();
}

class _WeddingCountdownBannerState extends State<WeddingCountdownBanner> {
  static final DateTime _weddingMoment = DateTime(2026, 8, 8, 13, 0);
  late final Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  bool get _isWeddingDay {
    return _now.year == _weddingMoment.year &&
        _now.month == _weddingMoment.month &&
        _now.day == _weddingMoment.day &&
        !_now.isBefore(_weddingMoment);
  }

  bool get _isAfterWeddingDay {
    return _now.isAfter(DateTime(
      _weddingMoment.year,
      _weddingMoment.month,
      _weddingMoment.day,
    ).add(const Duration(days: 1)));
  }

  String _formatCountdown() {
    if (_isAfterWeddingDay) {
      return 'Happily married';
    }

    if (_isWeddingDay) {
      return 'Today is the day';
    }

    final difference = _weddingMoment.difference(_now);
    if (difference.inDays >= 7) {
      final weeks = difference.inDays ~/ 7;
      return '$weeks week${weeks == 1 ? '' : 's'} to go';
    }

    if (difference.inDays >= 1) {
      final days = difference.inDays;
      return '$days day${days == 1 ? '' : 's'} to go';
    }

    if (difference.inHours >= 1) {
      final hours = difference.inHours;
      return '$hours hour${hours == 1 ? '' : 's'} to go';
    }

    if (difference.inMinutes >= 1) {
      final minutes = difference.inMinutes;
      return '$minutes minute${minutes == 1 ? '' : 's'} to go';
    }

    final seconds = math.max(1, difference.inSeconds);
    return '$seconds second${seconds == 1 ? '' : 's'} to go';
  }

  String _subLabel() {
    if (_isAfterWeddingDay) {
      return 'The celebration is now part of the memories.';
    }

    if (_isWeddingDay) {
      return 'Gerald and Mervielynn are getting married today.';
    }

    return 'Gerald and Mervielynn · August 8, 2026 · 1:00 PM';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final bannerWidth = math.max(0.0, math.min(size.width - 32, 420.0));

    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: bannerWidth),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary.withValues(alpha: 0.18),
                          Colors.black.withValues(alpha: 0.22),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.35),
                        width: 1.1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.24),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Wedding Countdown',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary.withValues(alpha: 0.95),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.12),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            _formatCountdown(),
                            key: ValueKey<String>(_formatCountdown()),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _subLabel(),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.76),
                            fontWeight: FontWeight.w500,
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
      ),
    );
  }
}



