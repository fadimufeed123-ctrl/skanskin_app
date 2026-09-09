import 'package:flutter/widgets.dart';

import '../../core/theme/app_motion.dart';

/// Wraps any interactive widget with a subtle press-in scale for tactile
/// feedback, without consuming the pointer.
///
/// It listens to raw pointer events ([Listener], non-consuming) so the child's
/// own tap/ink handling stays intact — this can safely wrap [InkWell]s,
/// buttons and list rows. The press releases if the pointer travels beyond a
/// small slop, so starting a scroll never leaves an item stuck pressed.
/// Under reduced motion it renders the child unchanged.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.pressedScale = 0.97,
    this.enabled = true,
  });

  final Widget child;

  /// Scale applied while pressed. Kept close to 1 so it reads as a press, not
  /// a bounce.
  final double pressedScale;

  final bool enabled;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  static const double _slop = 18;

  bool _pressed = false;
  Offset? _downPosition;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || AppMotion.reduced(context)) return widget.child;

    return Listener(
      behavior: HitTestBehavior.deferToChild,
      onPointerDown: (event) {
        _downPosition = event.position;
        _setPressed(true);
      },
      onPointerMove: (event) {
        if (_pressed &&
            _downPosition != null &&
            (event.position - _downPosition!).distance > _slop) {
          _setPressed(false);
        }
      },
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: _pressed ? AppMotion.fast : AppMotion.base,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
