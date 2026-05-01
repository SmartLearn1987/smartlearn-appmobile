import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../constants/api_constants.dart';
import '../theme/app_colors.dart';

/// Widget dùng chung để hiển thị ảnh từ network với cache.
///
/// Tự động thêm base URL nếu [imageUrl] là path tương đối.
/// Hiển thị placeholder loading và error fallback.
class AppCachedImage extends StatelessWidget {
  const AppCachedImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.errorWidget,
    super.key,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    final url = ApiConstants.fullImageUrl(imageUrl);

    Widget image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => SizedBox(
        width: width,
        height: height,
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
      errorWidget: (context, url, error) => errorWidget ?? _defaultError(),
    );

    if (shape == BoxShape.circle) {
      return ClipOval(child: image);
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }

  Widget _defaultError() {
    return Container(
      width: width,
      height: height,
      color: AppColors.muted,
      child: Center(
        child: Icon(
          LucideIcons.imageOff,
          size: 32,
          color: AppColors.mutedForeground,
        ),
      ),
    );
  }
}
