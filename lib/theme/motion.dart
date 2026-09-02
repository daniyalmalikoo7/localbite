import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Motion helpers that honour the platform "reduce motion" setting.
///
/// Reduced motion means *gentler*, not *absent*: a state change still needs to
/// be legible, so durations collapse toward zero while the end state stays the
/// same. Every animated widget in the app routes its duration through here.
extension MotionQuery on BuildContext {
  bool get prefersReducedMotion =>
      MediaQuery.maybeDisableAnimationsOf(this) ?? false;

  /// Returns [duration], or [Duration.zero] when the user has asked for
  /// reduced motion.
  Duration motion(Duration duration) =>
      prefersReducedMotion ? Duration.zero : duration;

  Duration get motionFast => motion(AppDuration.fast);
  Duration get motionNormal => motion(AppDuration.normal);
}
