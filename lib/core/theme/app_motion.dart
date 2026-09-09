import 'package:flutter/widgets.dart';

/// Central motion language for SkanSkin.
///
/// Durations and curves live here so every micro-interaction shares the same
/// timing, and so reduced-motion can be honoured from one place. Motion is kept
/// fast and purposeful — feedback, not decoration.
class AppMotion {
  AppMotion._();

  /// Immediate tactile feedback (press-in, small state flips).
  static const Duration fast = Duration(milliseconds: 120);

  /// Standard UI transition (press-out, colour/size changes).
  static const Duration base = Duration(milliseconds: 200);

  /// Content entrances and page transitions.
  static const Duration medium = Duration(milliseconds: 280);

  /// Larger, more deliberate reveals (success confirmation).
  static const Duration slow = Duration(milliseconds: 420);

  /// Decelerating curve for most incoming motion.
  static const Curve standard = Curves.easeOutCubic;

  /// Softly emphasised decelerate for entrances and transitions.
  static const Curve emphasized = Cubic(0.05, 0.7, 0.1, 1.0);

  /// Gentle overshoot for confirmation pops. Kept mild so it reads as
  /// confident, not playful.
  static const Curve pop = Cubic(0.2, 0.9, 0.3, 1.2);

  /// Whether the platform/user has requested reduced motion.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  /// Returns [duration] normally, or [Duration.zero] under reduced motion so
  /// animated widgets settle instantly without a separate code path.
  static Duration timed(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;
}
