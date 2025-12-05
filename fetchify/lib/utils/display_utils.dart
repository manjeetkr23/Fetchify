import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DisplayUtils {
  static bool _highRefreshRateEnabled = false;

  /// Initialize high refresh rate support
  static Future<void> initializeHighRefreshRate() async {
    if (kIsWeb) return;

    try {
      final binding = WidgetsBinding.instance;

      if (binding.platformDispatcher.views.isNotEmpty) {
        final view = binding.platformDispatcher.views.first;
        final refreshRate = view.display.refreshRate;

        debugPrint(
          "Fetchify: Display refresh rate detected: ${refreshRate}Hz",
        );

        if (refreshRate > 60) {
          _highRefreshRateEnabled = true;
          debugPrint(
            "Fetchify: High refresh rate display detected and enabled",
          );

          // Enable ProMotion on iOS and high refresh rate on Android
          await _enablePlatformOptimizations();
        } else {
          debugPrint("Fetchify: Standard 60Hz display detected");
        }
      }
    } catch (e) {
      debugPrint("Fetchify: Could not detect display refresh rate: $e");
    }
  }

  /// Enable platform-specific optimizations for high refresh rate
  static Future<void> _enablePlatformOptimizations() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // iOS ProMotion optimization
        await SystemChannels.platform.invokeMethod(
          'HapticFeedback.selectionClick',
        );
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        // Android high refresh rate optimization
        await SystemChannels.platform.invokeMethod(
          'SystemChrome.setApplicationSwitcherDescription',
          {
            'label': 'Fetchify',
            'primaryColor': 0xFF6366F1, // App primary color
          },
        );
      }
    } catch (e) {
      debugPrint("Fetchify: Platform optimization failed: $e");
    }
  }

  /// Get the current display refresh rate
  static double getCurrentRefreshRate() {
    try {
      final binding = WidgetsBinding.instance;
      if (binding.platformDispatcher.views.isNotEmpty) {
        return binding.platformDispatcher.views.first.display.refreshRate;
      }
    } catch (e) {
      debugPrint("Fetchify: Could not get refresh rate: $e");
    }
    return 60.0; // Default to 60Hz
  }

  /// Check if high refresh rate is available and enabled
  static bool get isHighRefreshRateEnabled => _highRefreshRateEnabled;

  /// Get optimal animation duration based on refresh rate
  static Duration getOptimalAnimationDuration({
    Duration standard = const Duration(milliseconds: 300),
  }) {
    if (_highRefreshRateEnabled) {
      // Faster animations for high refresh rate displays
      return Duration(milliseconds: (standard.inMilliseconds * 0.8).round());
    }
    return standard;
  }

  /// Get optimal animation curve for current display
  static Curve getOptimalAnimationCurve() {
    if (_highRefreshRateEnabled) {
      return Curves
          .easeInOutCubicEmphasized; // Smoother curve for high refresh rate
    }
    return Curves.easeInOut; // Standard curve for 60Hz
  }
}
