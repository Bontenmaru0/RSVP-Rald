import 'package:flutter/material.dart';

abstract class TeaserVideoSession {
  String get viewType;
  bool get isReady;
  bool get isPlaying;
  bool get isMuted;
  Future<void> get ready;

  Widget buildSurface();
  void play();
  void pause();
  void toggleMute();
  void detach();
}
