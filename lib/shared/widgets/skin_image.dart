import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skanskin_app/core/config/app_config.dart';
import 'package:skanskin_app/core/theme/app_colors.dart';
import 'package:skanskin_app/core/theme/app_dimens.dart';
import 'package:skanskin_app/features/consultations/state/consultations_providers.dart';

/// Loads a medical image through the authenticated consultation endpoint.
/// The image is rendered from in-memory bytes and never enters the persistent
/// disk cache used for public profile images.
class SkinImage extends ConsumerWidget {
  const SkinImage({
    super.key,
    required this.consultationId,
    required this.hasImage,
    this.height,
    this.width,
    this.borderRadius = AppDimens.brXl,
    this.fit = BoxFit.cover,
  });

  final int consultationId;
  final bool hasImage;
  final double? height;
  final double? width;
  final BorderRadius borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget placeholder({bool error = false}) => Container(
      height: height,
      width: width,
      color: AppColors.surfaceSubtle,
      child: Center(
        child: Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppDimens.brControl,
          ),
          child: Icon(
            error ? Icons.broken_image_outlined : Icons.image_outlined,
            color: error ? AppColors.textSecondary : AppColors.primary,
            size: 24,
          ),
        ),
      ),
    );

    if (!hasImage) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: placeholder(error: true),
      );
    }

    final image = ref.watch(consultationImageProvider(consultationId));

    return ClipRRect(
      borderRadius: borderRadius,
      child: image.when(
        loading: () => placeholder(),
        error: (_, __) => placeholder(error: true),
        data: (bytes) => Image.memory(
          bytes,
          height: height,
          width: width,
          fit: fit,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}

/// MVC-style rounded avatar showing a real image when available, otherwise a
/// compact monogram on the same soft primary surface used by the web app.
class MonogramAvatar extends StatelessWidget {
  const MonogramAvatar({
    super.key,
    required this.monogram,
    this.imageUrl,
    this.size = 48,
    this.background = AppColors.primarySoft,
    this.foreground = AppColors.primary,
  });

  final String monogram;
  final String? imageUrl;
  final double size;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final resolved = (imageUrl == null || imageUrl!.isEmpty)
        ? ''
        : AppConfig.resolveMediaUrl(imageUrl!);

    final label = Center(
      child: Text(
        monogram,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );

    return Container(
      height: size,
      width: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppDimens.brControl,
      ),
      child: resolved.isEmpty
          ? label
          : CachedNetworkImage(
              imageUrl: resolved,
              fit: BoxFit.cover,
              placeholder: (_, __) => label,
              errorWidget: (_, __, ___) => label,
            ),
    );
  }
}
