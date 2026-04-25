import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/content_block.dart';

/// Block-based rich content editor for lesson content.
///
/// Supports four block types: paragraph, heading, list_item, numbered_item.
/// Each block has a type selector, text field, delete button, and reorder
/// buttons. An "Thêm khối" (Add block) button at the bottom allows adding
/// new blocks.
///
/// Accepts an optional [initialBlocks] list for edit mode and notifies
/// the parent of changes via [onChanged].
class RichContentEditor extends StatefulWidget {
  const RichContentEditor({
    super.key,
    this.initialBlocks = const [],
    this.onChanged,
  });

  /// Initial content blocks to populate the editor (for edit mode).
  final List<ContentBlock> initialBlocks;

  /// Called whenever the list of content blocks changes.
  final ValueChanged<List<ContentBlock>>? onChanged;

  @override
  State<RichContentEditor> createState() => RichContentEditorState();
}

class RichContentEditorState extends State<RichContentEditor> {
  late final List<_EditableBlock> _blocks;

  /// Supported block types with Vietnamese labels.
  static const _blockTypes = <String, String>{
    'paragraph': 'Đoạn văn',
    'heading': 'Tiêu đề',
    'list_item': 'Danh sách',
    'numbered_item': 'Đánh số',
  };

  /// Icons for each block type.
  static const _blockIcons = <String, IconData>{
    'paragraph': LucideIcons.alignLeft,
    'heading': LucideIcons.heading,
    'list_item': LucideIcons.list,
    'numbered_item': LucideIcons.listOrdered,
  };

  @override
  void initState() {
    super.initState();
    _blocks = widget.initialBlocks
        .map(
          (block) => _EditableBlock(
            type: block.type,
            controller: TextEditingController(text: block.content),
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    for (final block in _blocks) {
      block.controller.dispose();
    }
    super.dispose();
  }

  /// Returns the current list of [ContentBlock] entities.
  List<ContentBlock> get blocks => _blocks
      .map(
        (b) => ContentBlock(type: b.type, content: b.controller.text),
      )
      .toList();

  void _notifyChanged() {
    widget.onChanged?.call(blocks);
  }

  void _addBlock() {
    setState(() {
      _blocks.add(
        _EditableBlock(
          type: 'paragraph',
          controller: TextEditingController(),
        ),
      );
    });
    _notifyChanged();
  }

  void _removeBlock(int index) {
    setState(() {
      _blocks[index].controller.dispose();
      _blocks.removeAt(index);
    });
    _notifyChanged();
  }

  void _changeBlockType(int index, String newType) {
    setState(() {
      _blocks[index].type = newType;
    });
    _notifyChanged();
  }

  void _moveBlockUp(int index) {
    if (index <= 0) return;
    setState(() {
      final block = _blocks.removeAt(index);
      _blocks.insert(index - 1, block);
    });
    _notifyChanged();
  }

  void _moveBlockDown(int index) {
    if (index >= _blocks.length - 1) return;
    setState(() {
      final block = _blocks.removeAt(index);
      _blocks.insert(index + 1, block);
    });
    _notifyChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_blocks.isEmpty)
          _buildEmptyState()
        else
          ..._blocks.asMap().entries.map(
                (entry) => _buildBlockItem(entry.key, entry.value),
              ),
        const SizedBox(height: AppSpacing.smMd),
        _buildAddButton(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.mdLg),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: AppBorders.borderRadiusSm,
        border: Border.all(
          color: AppColors.border,
          width: AppBorders.widthThin,
        ),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.fileEdit,
            size: 32,
            color: AppColors.mutedForeground,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Chưa có khối nội dung nào. Nhấn "Thêm khối" để bắt đầu.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBlockItem(int index, _EditableBlock block) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppBorders.borderRadiusSm,
          border: Border.all(
            color: AppColors.border,
            width: AppBorders.widthThin,
          ),
        ),
        child: Column(
          children: [
            _buildBlockHeader(index, block),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.smMd,
                0,
                AppSpacing.smMd,
                AppSpacing.smMd,
              ),
              child: _buildBlockTextField(block),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockHeader(int index, _EditableBlock block) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.smMd,
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Block type selector
          Expanded(child: _buildTypeSelector(index, block)),
          // Reorder buttons
          _buildReorderButton(
            icon: LucideIcons.chevronUp,
            onPressed: index > 0 ? () => _moveBlockUp(index) : null,
            tooltip: 'Di chuyển lên',
          ),
          _buildReorderButton(
            icon: LucideIcons.chevronDown,
            onPressed:
                index < _blocks.length - 1 ? () => _moveBlockDown(index) : null,
            tooltip: 'Di chuyển xuống',
          ),
          // Delete button
          _buildReorderButton(
            icon: LucideIcons.trash2,
            onPressed: () => _removeBlock(index),
            tooltip: 'Xóa khối',
            color: AppColors.destructive,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(int index, _EditableBlock block) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: AppBorders.borderRadiusSm,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: block.type,
          isDense: true,
          isExpanded: true,
          icon: const Icon(
            LucideIcons.chevronDown,
            size: 16,
            color: AppColors.mutedForeground,
          ),
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.foreground,
          ),
          dropdownColor: AppColors.card,
          borderRadius: AppBorders.borderRadiusSm,
          items: _blockTypes.entries
              .map(
                (entry) => DropdownMenuItem<String>(
                  value: entry.key,
                  child: Row(
                    children: [
                      Icon(
                        _blockIcons[entry.key],
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(entry.value),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              _changeBlockType(index, value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildBlockTextField(_EditableBlock block) {
    final isHeading = block.type == 'heading';
    return TextFormField(
      controller: block.controller,
      maxLines: isHeading ? 1 : 3,
      minLines: isHeading ? 1 : 2,
      onChanged: (_) => _notifyChanged(),
      style: (isHeading ? AppTypography.labelLarge : AppTypography.bodyMedium)
          .copyWith(color: AppColors.foreground),
      decoration: InputDecoration(
        hintText: _hintForType(block.type),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.mutedForeground,
        ),
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.smMd,
        ),
        isDense: true,
        border: _inputBorder(AppColors.input),
        enabledBorder: _inputBorder(AppColors.input),
        focusedBorder:
            _inputBorder(AppColors.primary, width: AppBorders.widthMedium),
      ),
    );
  }

  String _hintForType(String type) {
    switch (type) {
      case 'heading':
        return 'Nhập tiêu đề...';
      case 'list_item':
        return 'Nhập mục danh sách...';
      case 'numbered_item':
        return 'Nhập mục đánh số...';
      case 'paragraph':
      default:
        return 'Nhập nội dung đoạn văn...';
    }
  }

  Widget _buildReorderButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    Color? color,
  }) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        color: color ?? AppColors.mutedForeground,
        disabledColor: AppColors.border,
        padding: EdgeInsets.zero,
        splashRadius: 16,
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _addBlock,
        icon: const Icon(LucideIcons.plus, size: 16),
        label: const Text('Thêm khối'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.buttonMedium,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.smMd),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.borderRadiusSm,
          ),
          side: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: AppBorders.widthThin,
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color color,
      {double width = AppBorders.widthThin}) {
    return OutlineInputBorder(
      borderRadius: AppBorders.borderRadiusSm,
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

/// Internal mutable model for an editable content block.
class _EditableBlock {
  _EditableBlock({
    required this.type,
    required this.controller,
  });

  String type;
  final TextEditingController controller;
}
