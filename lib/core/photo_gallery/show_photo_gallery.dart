import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../constants/api_constants.dart';

/// Một ảnh trong viewer toàn màn (network hoặc file local).
sealed class PhotoGalleryItem {
  const PhotoGalleryItem();

  ImageProvider<Object> toImageProvider() => switch (this) {
    PhotoGalleryNetworkUrl(:final urlOrPath) => CachedNetworkImageProvider(
      ApiConstants.fullImageUrl(urlOrPath.trim()),
    ),
    PhotoGalleryLocalFile(:final file) => FileImage(file),
  };
}

/// URL hoặc path tương đối (được ghép base qua [ApiConstants.fullImageUrl]).
final class PhotoGalleryNetworkUrl extends PhotoGalleryItem {
  const PhotoGalleryNetworkUrl(this.urlOrPath);
  final String urlOrPath;
}

/// File cục bộ (ví dụ ảnh bìa vừa chọn trong form).
final class PhotoGalleryLocalFile extends PhotoGalleryItem {
  const PhotoGalleryLocalFile(this.file);
  final File file;
}

/// Mở gallery toàn màn: pinch zoom và vuốt ngang đổi ảnh.
///
/// [captions]: tùy chọn; `captions[i]` áp cho `items[i]`.
Future<void> showPhotoGallery(
  BuildContext context, {
  required List<PhotoGalleryItem> items,
  int initialIndex = 0,
  List<String?>? captions,
}) {
  if (items.isEmpty) return Future.value();
  final start = initialIndex.clamp(0, items.length - 1);

  return Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => _PhotoGalleryScaffold(
        items: items,
        initialIndex: start,
        captions: captions != null && captions.length == items.length
            ? captions
            : null,
      ),
    ),
  );
}

/// Tiện ích: chỉ danh sách URL; bỏ qua chuỗi rỗng; map lại [initialIndex] và [captions].
Future<void> showNetworkPhotoGallery(
  BuildContext context, {
  required List<String> imageUrls,
  int initialIndex = 0,
  List<String?>? captions,
}) {
  final paired = <({String url, String? caption})>[];
  for (var i = 0; i < imageUrls.length; i++) {
    final u = imageUrls[i].trim();
    if (u.isEmpty) continue;
    final cap = captions != null && i < captions.length ? captions[i] : null;
    paired.add((url: u, caption: cap));
  }
  if (paired.isEmpty) return Future.value();

  var galleryStart = 0;
  if (initialIndex >= 0 && initialIndex < imageUrls.length) {
    var g = 0;
    for (var i = 0; i < imageUrls.length; i++) {
      if (imageUrls[i].trim().isEmpty) continue;
      if (i == initialIndex) {
        galleryStart = g;
        break;
      }
      g++;
    }
  }

  return showPhotoGallery(
    context,
    items: [for (final p in paired) PhotoGalleryNetworkUrl(p.url)],
    initialIndex: galleryStart.clamp(0, paired.length - 1),
    captions: [for (final p in paired) p.caption],
  );
}

class _PhotoGalleryScaffold extends StatefulWidget {
  const _PhotoGalleryScaffold({
    required this.items,
    required this.initialIndex,
    this.captions,
  });

  final List<PhotoGalleryItem> items;
  final int initialIndex;
  final List<String?>? captions;

  @override
  State<_PhotoGalleryScaffold> createState() => _PhotoGalleryScaffoldState();
}

class _PhotoGalleryScaffoldState extends State<_PhotoGalleryScaffold> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cap = widget.captions;
    final caption = cap != null && _currentIndex < cap.length
        ? cap[_currentIndex]
        : null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                pageController: _pageController,
                itemCount: widget.items.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                builder: (context, index) {
                  final provider = widget.items[index].toImageProvider();
                  return PhotoViewGalleryPageOptions(
                    imageProvider: provider,
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 4,
                    initialScale: PhotoViewComputedScale.contained,
                    errorBuilder: (_, error, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          '$error',
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, event) => Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      value:
                          event != null &&
                              event.expectedTotalBytes != null &&
                              event.expectedTotalBytes! > 0
                          ? event.cumulativeBytesLoaded /
                                event.expectedTotalBytes!
                          : null,
                      color: Colors.white54,
                    ),
                  ),
                ),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
              ),
              PositionedDirectional(
                top: 8,
                end: 8,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.x,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if ((caption != null && caption.isNotEmpty) ||
                  widget.items.length > 1)
                PositionedDirectional(
                  start: 0,
                  end: 0,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.items.length > 1)
                          Text(
                            '${_currentIndex + 1} / ${widget.items.length}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        if (widget.items.length > 1 &&
                            caption != null &&
                            caption.isNotEmpty)
                          const SizedBox(height: 8),
                        if (caption != null && caption.isNotEmpty)
                          Text(
                            caption,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
