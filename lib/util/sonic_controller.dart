import 'package:flutter/services.dart';

/// Handles haptic and sound feedback.
// TODO(adil192): Add sound feedback
abstract class SonicController {
  static void notifyTileChange() {
    HapticFeedback.mediumImpact(); // HapticFeedbackConstants.KEYBOARD_TAP
  }

  static void notifyLongPress() {
    HapticFeedback.vibrate(); // HapticFeedbackConstants.LONG_PRESS
  }
}
