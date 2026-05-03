import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/photo_gallery/show_photo_gallery.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../domain/entities/lesson_image.dart';

/// Slideshow ảnh bài học: vuốt ngang đổi ảnh, nút trái/phải và bộ đếm "1/n".
class ImageSlideshowWidget extends StatefulWidget {
  const ImageSlideshowWidget({super.key, required this.images});

  final List<LessonImage> images;

  @override
  State<ImageSlideshowWidget> createState() => _ImageSlideshowWidgetState();
}

class _ImageSlideshowWidgetState extends State<ImageSlideshowWidget> {
  late final PageController _pageController;
  int _currentIndex = 0;

  bool get _hasPrevious => _currentIndex > 0;
  bool get _hasNext => _currentIndex < widget.images.length - 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void didUpdateWidget(covariant ImageSlideshowWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.images.isEmpty) return;
    if (_currentIndex >= widget.images.length) {
      final i = widget.images.length - 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _currentIndex = i);
        _pageController.jumpToPage(i);
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPrevious() {
    if (!_hasPrevious) return;
    _pageController.animateToPage(
      _currentIndex - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _goToNext() {
    if (!_hasNext) return;
    _pageController.animateToPage(
      _currentIndex + 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    final image = widget.images[_currentIndex];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorders.borderRadiusMd,
        border: Border.all(
          color: AppColors.border,
          width: AppBorders.widthThin,
        ),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppBorders.radiusMd),
              topRight: Radius.circular(AppBorders.radiusMd),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                physics: widget.images.length > 1
                    ? const PageScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  final img = widget.images[index];
                  return Material(
                    color: AppColors.card,
                    child: InkWell(
                      onTap: () {
                        showNetworkPhotoGallery(
                          context,
                          imageUrls: widget.images
                              .map((i) => i.fileUrl)
                              .toList(),
                          initialIndex: index,
                          captions: widget.images
                              .map((i) => i.caption)
                              .toList(),
                        );
                      },
                      child: AppCachedImage(
                        imageUrl: img.fileUrl,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _hasPrevious ? _goToPrevious : null,
                  icon: const Icon(LucideIcons.chevronLeft, size: 20),
                  style: IconButton.styleFrom(
                    foregroundColor: _hasPrevious
                        ? AppColors.foreground
                        : AppColors.mutedForeground,
                  ),
                ),
                Text(
                  '${_currentIndex + 1}/${widget.images.length}',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
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
