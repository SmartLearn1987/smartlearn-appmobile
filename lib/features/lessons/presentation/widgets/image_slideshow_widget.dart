import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../domain/entities/lesson_image.dart';

/// Widget hiển thị slideshow ảnh bài học với nút điều hướng trái/phải
/// và bộ đếm slide (ví dụ: "1/5").
class ImageSlideshowWidget extends StatefulWidget {
  const ImageSlideshowWidget({
    super.key,
    required this.images,
  });

  final List<LessonImage> images;

  @override
  State<ImageSlideshowWidget> createState() => _ImageSlideshowWidgetState();
}

class _ImageSlideshowWidgetState extends State<ImageSlideshowWidget> {
  int _currentIndex = 0;

  bool get _hasPrevious => _currentIndex > 0;
  bool get _hasNext => _currentIndex < widget.images.length - 1;

  void _goToPrevious() {
    if (_hasPrevious) {
      setState(() => _currentIndex--);
    }
  }

  void _goToNext() {
    if (_hasNext) {
      setState(() => _currentIndex++);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    final image = widget.images[_currentIndex];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorders.borderRadiusMd,
        border: Border.all(color: AppColors.border, width: AppBorders.widthThin),
      ),
      child: Column(
        children: [
          // Image display area
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppBorders.radiusMd),
              topRight: Radius.circular(AppBorders.radiusMd),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: AppCachedImage(
                imageUrl: image.fileUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Navigation bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous button
                IconButton(
                  onPressed: _hasPrevious ? _goToPrevious : null,
                  icon: const Icon(LucideIcons.chevronLeft, size: 20),
                  style: IconButton.styleFrom(
                    foregroundColor: _hasPrevious
                        ? AppColors.foreground
                        : AppColors.mutedForeground,
                  ),
                ),

                // Slide counter
                Text(
                  '${_currentIndex + 1}/${widget.images.length}',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.foreground,
                  ),
                ),

                // Next button
                IconButton(
                  onPressed: _hasNext ? _goToNext : null,
                  icon: const Icon(LucideIcons.chevronRight, size: 20),
                  style: IconButton.styleFrom(
                    foregroundColor: _hasNext
                        ? AppColors.foreground
                        : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),

          // Caption (if available)
          if (image.caption != null && image.caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.sm,
              ),
              child: Text(
                image.caption!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.mutedForeground,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
