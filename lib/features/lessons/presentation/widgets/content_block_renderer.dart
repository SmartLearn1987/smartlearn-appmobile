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
        // Reset numbered counter when a non-numbered block appears
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
      _ => _buildParagraph(block), // paragraph and any unknown type
    };
  }

  Widget _buildParagraph(ContentBlock block) {
    return Text(
      block.content,
      style: AppTypography.bodyLarge.copyWith(
        color: AppColors.foreground,
      ),
    );
  }

  Widget _buildHeading(ContentBlock block) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Text(
        block.content,
        style: AppTypography.h4.copyWith(
          color: AppColors.foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildListItem(ContentBlock block) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '•  ',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.foreground,
          ),
        ),
        Expanded(
          child: Text(
            block.content,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.foreground,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberedItem(ContentBlock block, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Text(
            '$index.',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.foreground,
            ),
          ),
        ),
        Expanded(
          child: Text(
            block.content,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.foreground,
            ),
          ),
        ),
      ],
    );
  }
}
