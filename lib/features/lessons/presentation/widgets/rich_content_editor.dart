import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/content_block.dart';

// ─── Internal rich block model (editor-only, not persisted) ──────────────────

class _RichBlock {
  _RichBlock({
    required this.type,
    required this.controller,
    this.fontSize = 16,
    this.fontFamily = 'default',
    this.color = const Color(0xFF222D3F),
    this.bold = false,
    this.italic = false,
  });

  String type;
  final TextEditingController controller;
  double fontSize;
  String fontFamily;
  Color color;
  bool bold;
  bool italic;

  factory _RichBlock.fromContentBlock(ContentBlock block) => _RichBlock(
    type: block.type,
    controller: TextEditingController(text: block.content),
    fontSize: block.fontSize ?? 16,
    fontFamily: block.fontFamily ?? 'default',
    color: block.color != null ? _hexToColor(block.color!) : const Color(0xFF222D3F),
    bold: block.bold ?? false,
    italic: block.italic ?? false,
  );
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Color _hexToColor(String hex) {
  final h = hex.replaceFirst('#', '');
  return Color(int.parse('FF$h', radix: 16));
}

String _colorToHex(Color color) =>
    '#${color.value.toRadixString(16).substring(2).toUpperCase()}';

// ─── Constants ───────────────────────────────────────────────────────────────

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

const _fontSizes = <double>[12, 14, 16, 18, 20, 24, 28, 32];

const _fontFamilies = <String, String>{
  'default': 'Mặc định',
  'serif': 'Serif',
  'mono': 'Mono',
  'sans': 'Sans',
};

const _colors = <Color>[
  Color(0xFF222D3F),
  Color(0xFF6A7181),
  Color(0xFFB91C1C),
  Color(0xFF1D4ED8),
  Color(0xFF15803D),
  Color(0xFF9333EA),
  Color(0xFFC2410C),
  Color(0xFF0E7490),
];

// ─── Widget ──────────────────────────────────────────────────────────────────

/// Block-based rich content editor matching the React RichTextEditor.
///
/// Features: block type selector, font size, font family, color swatches,
/// bold/italic toggles. Toolbar state syncs to the focused block.
///
/// Serializes to [ContentBlock] (type + content only) for API compatibility.
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

  // Toolbar state — mirrors focused block
  double _fontSize = 16;
  String _fontFamily = 'default';
  Color _color = const Color(0xFF222D3F);
  String _blockType = 'paragraph';
  bool _bold = false;
  bool _italic = false;

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

  /// Public getter — returns [ContentBlock] list for saving.
  List<ContentBlock> get blocks => _blocks
      .map((b) => ContentBlock(
            type: b.type,
            content: b.controller.text,
            fontSize: b.fontSize != 16 ? b.fontSize : null,
            fontFamily: b.fontFamily != 'default' ? b.fontFamily : null,
            color: _colorToHex(b.color) != '#222D3F' ? _colorToHex(b.color) : null,
            bold: b.bold ? true : null,
            italic: b.italic ? true : null,
          ))
      .toList();

  void _notify() => widget.onChanged?.call(blocks);

  // ── Focus sync ──

  void _onFocus(int idx) {
    setState(() {
      _focusedIdx = idx;
      final b = _blocks[idx];
      _fontSize = b.fontSize;
      _fontFamily = b.fontFamily;
      _color = b.color;
      _blockType = b.type;
      _bold = b.bold;
      _italic = b.italic;
    });
  }

  void _onBlur() => setState(() => _focusedIdx = -1);

  // ── Toolbar actions ──

  void _applyFontSize(double v) {
    if (_focusedIdx == -1) return;
    setState(() {
      _fontSize = v;
      _blocks[_focusedIdx].fontSize = v;
    });
  }

  void _applyFontFamily(String v) {
    if (_focusedIdx == -1) return;
    setState(() {
      _fontFamily = v;
      _blocks[_focusedIdx].fontFamily = v;
    });
  }

  void _applyColor(Color v) {
    if (_focusedIdx == -1) return;
    setState(() {
      _color = v;
      _blocks[_focusedIdx].color = v;
    });
  }

  void _applyBlockType(String v) {
    if (_focusedIdx == -1) return;
    setState(() {
      _blockType = v;
      _blocks[_focusedIdx].type = v;
    });
    _notify();
  }

  void _toggleBold() {
    if (_focusedIdx == -1) return;
    setState(() {
      _bold = !_bold;
      _blocks[_focusedIdx].bold = _bold;
    });
  }

  void _toggleItalic() {
    if (_focusedIdx == -1) return;
    setState(() {
      _italic = !_italic;
      _blocks[_focusedIdx].italic = _italic;
    });
  }

  // ── Block management ──

  void _addBlock() {
    setState(() {
      _blocks.add(
        _RichBlock(
          type: _blockType,
          controller: TextEditingController(),
          fontSize: _fontSize,
          fontFamily: _fontFamily,
          color: _color,
          bold: _bold,
          italic: _italic,
        ),
      );
      _focusedIdx = _blocks.length - 1;
    });
    _notify();
  }

  void _removeBlock(int idx) {
    setState(() {
      _blocks[idx].controller.dispose();
      _blocks.removeAt(idx);
      if (_focusedIdx >= _blocks.length) _focusedIdx = _blocks.length - 1;
    });
    _notify();
  }

  void _moveUp(int idx) {
    if (idx <= 0) return;
    setState(() {
      final b = _blocks.removeAt(idx);
      _blocks.insert(idx - 1, b);
      _focusedIdx = idx - 1;
    });
    _notify();
  }

  void _moveDown(int idx) {
    if (idx >= _blocks.length - 1) return;
    setState(() {
      final b = _blocks.removeAt(idx);
      _blocks.insert(idx + 1, b);
      _focusedIdx = idx + 1;
    });
    _notify();
  }

  // ── Helpers ──

  TextStyle _textStyleFor(_RichBlock b) {
    final base = b.type == 'heading'
        ? AppTypography.labelLarge
        : AppTypography.bodyMedium;
    return base.copyWith(
      fontSize: b.fontSize,
      color: b.color,
      fontWeight: b.bold ? FontWeight.w700 : FontWeight.w400,
      fontStyle: b.italic ? FontStyle.italic : FontStyle.normal,
      fontFamily: b.fontFamily == 'default' ? null : b.fontFamily,
    );
  }

  String _prefixFor(_RichBlock b, int idx) {
    if (b.type == 'list_item') return '•';
    if (b.type == 'numbered_item') return '${idx + 1}.';
    return '';
  }

  String _hintFor(String type) => switch (type) {
    'heading' => 'Nhập tiêu đề...',
    'list_item' => 'Nhập mục danh sách...',
    'numbered_item' => 'Nhập mục đánh số...',
    _ => 'Nhập nội dung...',
  };

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

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
        children: [
          _buildToolbar(),
          _buildBlockList(),
          if (_focusedIdx >= 0) _buildStatusBar(),
        ],
      ),
    );
  }

  // ── Toolbar ──

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
          // Font size
          _ToolbarDropdown<double>(
            value: _fontSize,
            items: _fontSizes
                .map(
                  (s) =>
                      DropdownMenuItem(value: s, child: Text('${s.toInt()}px')),
                )
                .toList(),
            onChanged: _applyFontSize,
            prefix: const Icon(
              LucideIcons.type,
              size: 13,
              color: AppColors.mutedForeground,
            ),
          ),

          _divider(),

          // Font family
          _ToolbarDropdown<String>(
            value: _fontFamily,
            items: _fontFamilies.entries
                .map(
                  (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                )
                .toList(),
            onChanged: _applyFontFamily,
          ),

          _divider(),

          // Color swatches
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.palette,
                size: 13,
                color: AppColors.mutedForeground,
              ),
              const SizedBox(width: AppSpacing.xs),
              ..._colors.map(
                (c) => _ColorSwatch(
                  color: c,
                  isSelected: _color == c,
                  onTap: () => _applyColor(c),
                ),
              ),
            ],
          ),

          _divider(),

          // Bold
          _ToolbarToggle(
            label: 'B',
            active: _bold,
            bold: true,
            onTap: _toggleBold,
          ),
          // Italic
          _ToolbarToggle(
            label: 'I',
            active: _italic,
            italic: true,
            onTap: _toggleItalic,
          ),

          _divider(),

          // Block type buttons
          ..._blockTypes.entries.map(
            (e) => _BlockTypeButton(
              type: e.key,
              icon: _blockIcons[e.key]!,
              label: e.value,
              isSelected: _blockType == e.key,
              onTap: () => _applyBlockType(e.key),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 16,
    color: AppColors.border,
    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
  );

  // ── Block list ──

  Widget _buildBlockList() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.smMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_blocks.isEmpty)
            _buildEmptyState()
          else
            ..._blocks.asMap().entries.map(
              (e) => _buildBlockRow(e.key, e.value),
            ),
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

  Widget _buildBlockRow(int idx, _RichBlock block) {
    final isFocused = _focusedIdx == idx;
    final prefix = _prefixFor(block, idx);

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
            // Text field
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
                  key: ValueKey(
                    '${idx}_${block.fontSize}_${block.color.value}_${block.bold}_${block.italic}_${block.fontFamily}_${block.type}',
                  ),
                  controller: block.controller,
                  maxLines: block.type == 'heading' ? 1 : null,
                  minLines: 1,
                  onChanged: (_) => _notify(),
                  style: _textStyleFor(block),
                  decoration: InputDecoration(
                    suffix: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // _iconBtn(
                        //   LucideIcons.chevronUp,
                        //   idx > 0 ? () => _moveUp(idx) : null,
                        // ),
                        // _iconBtn(
                        //   LucideIcons.chevronDown,
                        //   idx < _blocks.length - 1
                        //       ? () => _moveDown(idx)
                        //       : null,
                        // ),
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

            // // Actions (visible on focus/hover via AnimatedOpacity)
            // AnimatedOpacity(
            //   opacity: isFocused ? 1.0 : 0.0,
            //   duration: const Duration(milliseconds: 150),
            //   child: Row(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       _iconBtn(
            //         LucideIcons.chevronUp,
            //         idx > 0 ? () => _moveUp(idx) : null,
            //       ),
            //       _iconBtn(
            //         LucideIcons.chevronDown,
            //         idx < _blocks.length - 1 ? () => _moveDown(idx) : null,
            //       ),
            //       _iconBtn(
            //         LucideIcons.x,
            //         () => _removeBlock(idx),
            //         color: AppColors.destructive,
            //       ),
            //     ],
            //   ),
            // ),
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

  // ── Status bar ──

  Widget _buildStatusBar() {
    return Container(
      color: AppColors.muted.withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smMd,
        vertical: AppSpacing.xs,
      ),
      child: Text(
        'Dòng ${_focusedIdx + 1} đang được chọn — Thay đổi toolbar sẽ áp dụng ngay cho dòng này',
        style: AppTypography.bodySmall.copyWith(
          fontSize: 10,
          color: AppColors.mutedForeground,
        ),
      ),
    );
  }
}

// ─── Toolbar sub-widgets ──────────────────────────────────────────────────────

class _ToolbarDropdown<T> extends StatelessWidget {
  const _ToolbarDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    this.prefix,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T> onChanged;
  final Widget? prefix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorders.borderRadiusSm,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (prefix != null) ...[
            prefix!,
            const SizedBox(width: AppSpacing.xs),
          ],
          DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isDense: true,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.foreground,
              ),
              dropdownColor: AppColors.card,
              borderRadius: AppBorders.borderRadiusSm,
              items: items,
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 16,
        height: 16,
        margin: const EdgeInsets.only(left: AppSpacing.xxs),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color, blurRadius: 0, spreadRadius: 1.5)]
              : null,
        ),
      ),
    );
  }
}

class _ToolbarToggle extends StatelessWidget {
  const _ToolbarToggle({
    required this.label,
    required this.active,
    required this.onTap,
    this.bold = false,
    this.italic = false,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool bold;
  final bool italic;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: AppBorders.borderRadiusSm,
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: active ? AppColors.primaryForeground : AppColors.foreground,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
    );
  }
}

class _BlockTypeButton extends StatelessWidget {
  const _BlockTypeButton({
    required this.type,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String type;
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
          ),
          child: Icon(
            icon,
            size: 14,
            color: isSelected
                ? AppColors.primaryForeground
                : AppColors.mutedForeground,
          ),
        ),
      ),
    );
  }
}
