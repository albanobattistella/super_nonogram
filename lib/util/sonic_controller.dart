import 'package:flutter/services.dart';
import 'package:super_nonogram/data/stows.dart';

/// Handles haptic and sound feedback.
// TODO(adil192): Add sound feedback
abstract class SonicController {
  static void notifyTileChange() {
    if (!stows.useHapticFeedback.value) return;
    HapticFeedback.mediumImpact(); // HapticFeedbackConstants.KEYBOARD_TAP
  }

  static void notifyLongPress() {
    if (!stows.useHapticFeedback.value) return;
    HapticFeedback.vibrate(); // HapticFeedbackConstants.LONG_PRESS
  }

  static void notifyHapticSettingChanged() {
    if (!stows.useHapticFeedback.value) return;
    HapticFeedback.vibrate(); // HapticFeedbackConstants.LONG_PRESS
  }
}
