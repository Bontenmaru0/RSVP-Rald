import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';

class RsvpSupabaseBootstrap {
  RsvpSupabaseBootstrap._();

  static Future<bool>? _initFuture;
  static bool _isInitialized = false;

  static Future<bool> ensureInitialized() {
    final existingFuture = _initFuture;
    if (existingFuture != null) {
      return existingFuture.then((initialized) {
        if (!initialized) {
          _initFuture = null;
        }
        return initialized;
      });
    }

    final initFuture = _initialize();
    _initFuture = initFuture.then((initialized) {
      if (!initialized) {
        _initFuture = null;
      }
      return initialized;
    });
    return _initFuture!;
  }

  static Future<bool> _initialize() async {
    try {
      if (_isInitialized) {
        return true;
      }

      await dotenv.load(
        fileName: 'assets/config/supabase.env',
        isOptional: true,
      );
      final config = SupabaseConfig.fromEnvironment();
      if (!config.isConfigured) {
        debugPrint('RSVP Supabase config is incomplete.');
        return false;
      }

      await Supabase.initialize(
        url: config.url,
        anonKey: config.anonKey,
      );
      _isInitialized = true;
      return true;
    } catch (error, stackTrace) {
      debugPrint('RSVP Supabase initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }
}
