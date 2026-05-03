import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/content_block.dart';

// ─── Internal editor block (type + controller) ───────────────────────────────

class _RichBlock {
  _RichBlock({required this.type, required this.controller});

  String type;
  final TextEditingController controller;

  factory _RichBlock.fromContentBlock(ContentBlock block) => _RichBlock(
    type: block.type,
    controller: TextEditingController(text: block.content),
  );

  ContentBlock toContentBlock() =>
      ContentBlock(type: type, content: controller.text);
}

const _blockTypes = <String, String>{
  'paragraph': 'Đoạn văn',
  'heading': 'Tiêu đề',
  'list_item': 'Danh sách',
  'numbered_item': 'Đánh số',
};

const _blockIcons = <String, IconData>{
  'paragraph': LucideIcons.alignLeft,
  'heading': LucideIcons.type,
  'list_item': LucideIcons.list,
  'numbered_item': LucideIcons.listOrdered,
};

// ──────────────────────────────────────────────────────────────────────────────

/// Soạn khối nội dung — chỉ lưu [ContentBlock.type] và [ContentBlock.content].
class RichContentEditor extends StatefulWidget {
  const RichContentEditor({
    super.key,
    this.initialBlocks = const [],
    this.onChanged,
  });

  final List<ContentBlock> initialBlocks;
  final ValueChanged<List<ContentBlock>>? onChanged;

  @override
  State<RichContentEditor> createState() => RichContentEditorState();
}

class RichContentEditorState extends State<RichContentEditor> {
  late final List<_RichBlock> _blocks;
  int _focusedIdx = -1;

  /// Loại khối hiển thị khi có dòng đang focus — dùng khi "Thêm đoạn".
  String _blockType = 'paragraph';

  @override
  void initState() {
    super.initState();
    _blocks = widget.initialBlocks.isEmpty
        ? [_RichBlock(type: 'paragraph', controller: TextEditingController())]
        : widget.initialBlocks.map(_RichBlock.fromContentBlock).toList();
  }

  @override
  void dispose() {
    for (final b in _blocks) {
      b.controller.dispose();
    }
    super.dispose();
  }

  List<ContentBlock> get blocks =>
      _blocks.map((b) => b.toContentBlock()).toList();

  void _notify() => widget.onChanged?.call(blocks);

  void _onFocus(int idx) {
    setState(() {
      _focusedIdx = idx;
      _blockType = _blocks[idx].type;
    });
  }

  void _onBlur() => setState(() => _focusedIdx = -1);

  void _applyBlockType(String v) {
    if (_focusedIdx == -1) return;
    setState(() {
      _blockType = v;
      _blocks[_focusedIdx].type = v;
    });
    _notify();
  }

  void _addBlock() {
    setState(() {
      _blocks.add(
        _RichBlock(type: _blockType, controller: TextEditingController()),
      );
      _focusedIdx = _blocks.length - 1;
    });
    _notify();
  }

  void _removeBlock(int idx) {
    setState(() {
      _blocks[idx].controller.dispose();
      _blocks.removeAt(idx);
      if (_focusedIdx >= _blocks.length) {
        _focusedIdx = _blocks.isEmpty ? -1 : _blocks.length - 1;
      }
    });
    _notify();
  }

  TextStyle _textStyleFor(String type) {
    return switch (type) {
      'heading' => AppTypography.labelLarge.copyWith(
        color: AppColors.foreground,
        fontWeight: FontWeight.w700,
      ),
      _ => AppTypography.bodyMedium.copyWith(color: AppColors.foreground),
    };
  }

  String _prefixFor(String type, int numberedOrdinal) {
    if (type == 'list_item') return '•';
    if (type == 'numbered_item' && numberedOrdinal > 0) {
      return '$numberedOrdinal.';
    }
    return '';
  }

  String _hintFor(String type) => switch (type) {
    'heading' => 'Nhập tiêu đề...',
    'list_item' => 'Nhập mục danh sách...',
    'numbered_item' => 'Nhập mục đánh số...',
    _ => 'Nhập nội dung...',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorders.borderRadiusSm,
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_buildToolbar(), _buildBlockList()],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      color: AppColors.muted.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smMd,
        vertical: AppSpacing.sm,
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Loại:',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          ..._blockTypes.entries.map(
            (e) => _BlockTypeButton(
              icon: _blockIcons[e.key]!,
              label: e.value,
              isSelected: _focusedIdx >= 0 && _blockType == e.key,
              onTap: _focusedIdx >= 0 ? () => _applyBlockType(e.key) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockList() {
    var numberedOrdinal = 0;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.smMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_blocks.isEmpty)
            _buildEmptyState()
          else
            ..._blocks.asMap().entries.map((e) {
              final block = e.value;
              if (block.type == 'numbered_item') {
                numberedOrdinal++;
              } else {
                numberedOrdinal = 0;
              }
              return _buildBlockRow(e.key, block, numberedOrdinal);
            }),
          const SizedBox(height: AppSpacing.smMd),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          const Icon(
            LucideIcons.fileEdit,
            size: 32,
            color: AppColors.mutedForeground,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Nhấn "+ Thêm đoạn mới" để bắt đầu nhập nội dung...',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBlockRow(int idx, _RichBlock block, int numberedOrdinal) {
    final isFocused = _focusedIdx == idx;
    final prefix = _prefixFor(block.type, numberedOrdinal);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isFocused
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.transparent,
          borderRadius: AppBorders.borderRadiusSm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Focus(
                onFocusChange: (hasFocus) {
                  if (hasFocus) {
                    _onFocus(idx);
                  } else {
                    _onBlur();
                  }
                },
                child: TextFormField(
                  key: ValueKey('${idx}_${block.type}_${block.controller}'),
                  controller: block.controller,
                  maxLines: block.type == 'heading' ? 1 : null,
                  minLines: 1,
                  onChanged: (_) => _notify(),
                  style: _textStyleFor(block.type),
                  decoration: InputDecoration(
                    suffix: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _iconBtn(
                          LucideIcons.x,
                          () => _removeBlock(idx),
                          color: AppColors.destructive,
                        ),
                      ],
                    ),
                    prefix: prefix.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(
                              right: AppSpacing.xs,
                            ),
                            child: Text(
                              prefix,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : null,
                    hintText: _hintFor(block.type),
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.mutedForeground.withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                    isDense: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback? onPressed, {Color? color}) {
    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 14),
        color: color ?? AppColors.mutedForeground,
        disabledColor: AppColors.border,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildAddButton() {
    return OutlinedButton.icon(
      onPressed: _addBlock,
      icon: const Icon(LucideIcons.plus, size: 16),
      label: const Text('Thêm đoạn mới'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTypography.buttonMedium,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.smMd),
        shape: RoundedRectangleBorder(borderRadius: AppBorders.borderRadiusSm),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
    );
  }
}

class _BlockTypeButton extends StatelessWidget {
  const _BlockTypeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: AppBorders.borderRadiusSm,
            border: Border.all(
              color: enabled
                  ? AppColors.border
                  : AppColors.border.withValues(alpha: 0.35),
            ),
          ),
          child: Icon(
            icon,
            size: 14,
            color: !enabled
                ? AppColors.mutedForeground.withValues(alpha: 0.35)
                : isSelected
                ? AppColors.primaryForeground
                : AppColors.mutedForeground,
          ),
        ),
      ),
    );
  }
}
