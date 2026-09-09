import 'package:flutter/material.dart';
import 'package:skanskin_app/core/theme/app_colors.dart';
import 'package:skanskin_app/core/theme/app_dimens.dart';
import 'package:skanskin_app/shared/widgets/app_card.dart';

/// A placeholder block with a soft shimmer sweep that respects reduced-motion
/// settings (falling back to a calm static tint).
class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.height = 14,
    this.width,
    this.borderRadius = AppDimens.brMd,
  });

  final double height;
  final double? width;
  final BorderRadius borderRadius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _animationsDisabled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animationsDisabled =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (_animationsDisabled) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final block = Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: AppColors.skeletonBase,
        borderRadius: widget.borderRadius,
      ),
    );

    if (_animationsDisabled) return block;

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                AppColors.skeletonBase,
                AppColors.skeletonHighlight,
                AppColors.skeletonBase,
              ],
              stops: const [0.35, 0.5, 0.65],
              transform: _SweepTransform(_controller.value * 2 - 1),
            ).createShader(bounds),
            child: child,
          );
        },
        child: block,
      ),
    );
  }
}

/// Slides a gradient horizontally across its bounds; the highlight band is
/// off-screen at both extremes so the repeat loop resets invisibly.
class _SweepTransform extends GradientTransform {
  const _SweepTransform(this.slidePercent);

  final double slidePercent;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}

/// Placeholder card shown while the consultations list loads, matching the
/// shape of a real consultation row.
class ConsultationCardSkeleton extends StatelessWidget {
  const ConsultationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      showShadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Skeleton(height: 40, width: 40, borderRadius: AppDimens.brFull),
              SizedBox(width: AppDimens.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(height: 14, width: 120),
                    SizedBox(height: 8),
                    Skeleton(height: 12, width: 80),
                  ],
                ),
              ),
              Skeleton(height: 20, width: 68, borderRadius: AppDimens.brFull),
            ],
          ),
          SizedBox(height: AppDimens.s16),
          Skeleton(height: 12, width: double.infinity),
          SizedBox(height: 8),
          Skeleton(height: 12, width: 200),
        ],
      ),
    );
  }
}
