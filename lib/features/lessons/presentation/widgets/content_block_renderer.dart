import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/content_block.dart';

/// Widget hiển thị danh sách các content block theo loại:
/// - paragraph → văn bản thường
/// - heading → tiêu đề in đậm, cỡ lớn
/// - list_item → văn bản với dấu đầu dòng (•)
/// - numbered_item → văn bản với số thứ tự (1., 2., ...)
///
/// Hỗ trợ styling: fontSize, fontFamily, color, bold, italic.
class ContentBlockRenderer extends StatelessWidget {
  const ContentBlockRenderer({
    super.key,
    required this.blocks,
  });

  final List<ContentBlock> blocks;

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) return const SizedBox.shrink();

    int numberedCounter = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.map((block) {
        if (block.type != 'numbered_item') {
          numberedCounter = 0;
        } else {
          numberedCounter++;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _buildBlock(block, numberedCounter),
        );
      }).toList(),
    );
  }

  Widget _buildBlock(ContentBlock block, int numberedIndex) {
    return switch (block.type) {
      'heading' => _buildHeading(block),
      'list_item' => _buildListItem(block),
      'numbered_item' => _buildNumberedItem(block, numberedIndex),
      _ => _buildParagraph(block),
    };
  }

  /// Merges block-level styling on top of a base [TextStyle].
  TextStyle _applyStyle(TextStyle base, ContentBlock block) {
    return base.copyWith(
      fontSize: block.fontSize,
      color: block.color != null ? _hexToColor(block.color!) : null,
      fontWeight: block.bold == true ? FontWeight.w700 : null,
      fontStyle: block.italic == true ? FontStyle.italic : null,
      fontFamily: (block.fontFamily != null && block.fontFamily != 'default')
          ? _resolveFontFamily(block.fontFamily!)
          : null,
    );
  }

  Widget _buildParagraph(ContentBlock block) {
    return Text(
      block.content,
      style: _applyStyle(
        AppTypography.bodyLarge.copyWith(color: AppColors.foreground),
        block,
      ),
    );
  }

  Widget _buildHeading(ContentBlock block) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Text(
        block.content,
        style: _applyStyle(
          AppTypography.h4.copyWith(
            color: AppColors.foreground,
            fontWeight: FontWeight.w700,
          ),
          block,
        ),
      ),
    );
  }

  Widget _buildListItem(ContentBlock block) {
    final style = _applyStyle(
      AppTypography.bodyLarge.copyWith(color: AppColors.foreground),
      block,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('•  ', style: style),
        Expanded(child: Text(block.content, style: style)),
      ],
    );
  }

  Widget _buildNumberedItem(ContentBlock block, int index) {
    final style = _applyStyle(
      AppTypography.bodyLarge.copyWith(color: AppColors.foreground),
      block,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 28, child: Text('$index.', style: style)),
        Expanded(child: Text(block.content, style: style)),
      ],
    );
  }
}

Color _hexToColor(String hex) {
  final h = hex.replaceFirst('#', '');
  return Color(int.parse('FF$h', radix: 16));
}

String _resolveFontFamily(String key) => switch (key) {
      'serif' => 'Georgia',
      'mono' => 'monospace',
      'sans' => 'Arial',
      _ => 'Arial',
    };
