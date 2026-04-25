import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/widgets/app_cached_image.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/lesson_image.dart';
import '../bloc/lessons_list/lessons_list_bloc.dart';

/// Image upload section for the lesson form.
///
/// In **create mode** ([lessonId] is null):
/// - Selected images are queued locally as [File] objects.
/// - Previews are shown with a delete button.
/// - A pending count message is displayed.
/// - Images are uploaded during the save flow.
///
/// In **edit mode** ([lessonId] is provided):
/// - Existing images from the server are displayed.
/// - New images are uploaded immediately via the BLoC.
/// - Existing images can be deleted via the BLoC.
class ImageUploadSection extends StatefulWidget {
  const ImageUploadSection({
    super.key,
    this.lessonId,
    this.existingImages = const [],
    required this.onPendingImagesChanged,
  });

  /// The lesson ID. When non-null, the widget operates in edit mode.
  final String? lessonId;

  /// Existing images loaded from the server (edit mode).
  final List<LessonImage> existingImages;

  /// Callback invoked when the pending images list changes (create mode).
  final ValueChanged<List<File>> onPendingImagesChanged;

  @override
  State<ImageUploadSection> createState() => ImageUploadSectionState();
}

class ImageUploadSectionState extends State<ImageUploadSection> {
  final ImagePicker _picker = ImagePicker();

  /// Locally queued images for create mode.
  final List<File> _pendingImages = [];

  /// Server images for edit mode.
  late List<LessonImage> _serverImages;

  /// Whether an upload is in progress (edit mode).
  bool _isUploading = false;

  bool get _isEditMode => widget.lessonId != null;

  /// Exposes pending images for the parent form to use during save.
  List<File> get pendingImages => List.unmodifiable(_pendingImages);

  @override
  void initState() {
    super.initState();
    _serverImages = List.of(widget.existingImages);
  }

  @override
  void didUpdateWidget(covariant ImageUploadSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.existingImages != oldWidget.existingImages) {
      _serverImages = List.of(widget.existingImages);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LessonsListBloc, LessonsListState>(
      listener: _onBlocStateChanged,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPickerButton(),
          if (_isEditMode) ...[
            if (_serverImages.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildServerImagesGrid(),
            ],
          ] else ...[
            if (_pendingImages.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildPendingImagesGrid(),
              const SizedBox(height: AppSpacing.sm),
              _buildPendingCountText(),
            ],
          ],
        ],
      ),
    );
  }

  // ─── BLoC Listener ───

  void _onBlocStateChanged(BuildContext context, LessonsListState state) {
    if (state is LessonImagesUploading) {
      setState(() => _isUploading = true);
    } else if (state is LessonImagesUploadSuccess) {
      setState(() {
        _isUploading = false;
        _serverImages.addAll(state.images);
      });
      AppToast.success(context, 'Đã tải ảnh lên thành công');
    } else if (state is LessonImagesUploadFailure) {
      setState(() => _isUploading = false);
      AppToast.error(context, 'Không thể tải ảnh lên');
    } else if (state is LessonImageDeleteSuccess) {
      setState(() {
        _serverImages.removeWhere((img) => img.id == state.imageId);
      });
      AppToast.success(context, 'Đã xóa ảnh');
    } else if (state is LessonImageDeleteFailure) {
      AppToast.error(context, 'Không thể xóa ảnh');
    }
  }

  // ─── Picker Button ───

  Widget _buildPickerButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isUploading ? null : _pickImages,
        icon: _isUploading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(LucideIcons.imagePlus, size: 18),
        label: Text(_isUploading ? 'Đang tải...' : 'Chọn ảnh'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.buttonMedium,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.smMd,
            horizontal: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.borderRadiusSm,
          ),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  // ─── Pending Images Grid (Create Mode) ───

  Widget _buildPendingImagesGrid() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _pendingImages.asMap().entries.map((entry) {
        return _buildImageTile(
          child: Image.file(
            entry.value,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          onDelete: () => _removePendingImage(entry.key),
        );
      }).toList(),
    );
  }

  // ─── Server Images Grid (Edit Mode) ───

  Widget _buildServerImagesGrid() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _serverImages.map((image) {
        return _buildImageTile(
          child: AppCachedImage(
            imageUrl: image.fileUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorWidget: const Center(
              child: Icon(
                LucideIcons.imageOff,
                color: AppColors.mutedForeground,
              ),
            ),
          ),
          onDelete: () => _deleteServerImage(image),
        );
      }).toList(),
    );
  }

  // ─── Image Tile ───

  Widget _buildImageTile({
    required Widget child,
    required VoidCallback onDelete,
  }) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: AppBorders.borderRadiusSm,
              child: child,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: const BoxDecoration(
                  color: AppColors.destructive,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.x,
                  size: 14,
                  color: AppColors.destructiveForeground,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Pending Count Text ───

  Widget _buildPendingCountText() {
    return Text(
      '${_pendingImages.length} ảnh sẽ được tải lên khi lưu',
      style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground),
    );
  }

  // ─── Actions ───

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isEmpty) return;

    final files = pickedFiles.map((xFile) => File(xFile.path)).toList();

    if (_isEditMode) {
      // Edit mode: upload immediately via BLoC
      if (!mounted) return;
      context.read<LessonsListBloc>().add(
        LessonImagesUploadRequested(lessonId: widget.lessonId!, images: files),
      );
    } else {
      // Create mode: queue locally
      setState(() {
        _pendingImages.addAll(files);
      });
      widget.onPendingImagesChanged(_pendingImages);
    }
  }

  void _removePendingImage(int index) {
    setState(() {
      _pendingImages.removeAt(index);
    });
    widget.onPendingImagesChanged(_pendingImages);
  }

  void _deleteServerImage(LessonImage image) {
    context.read<LessonsListBloc>().add(
      LessonImageDeleteRequested(lessonId: widget.lessonId!, imageId: image.id),
    );
  }
}
