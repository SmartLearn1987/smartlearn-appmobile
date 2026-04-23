import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/constants/app_assets.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';
import 'package:smart_learn/core/widgets/app_toast.dart';

import 'dictation_selection_modal.dart';
import 'game_card_widget.dart';
import 'pictogram_selection_modal.dart';
import 'vtv_selection_modal.dart';
import 'nnc_selection_modal.dart';
import 'cdtn_selection_modal.dart';
import 'hcb_category_selection_modal.dart';

class GameTab extends StatelessWidget {
  const GameTab({super.key});

  static const _games = [
    (
      title: 'Đuổi hình bắt chữ',
      description: 'Thách thức tư duy với những câu đố hình ảnh đầy thú vị',
      image: AppAssets.gameduoihinhbatchu,
      isAvailable: true,
    ),
    (
      title: 'Vua tiếng Việt',
      description: 'Ông vua từ vựng và ngữ pháp tiếng Việt',
      image: AppAssets.gamevuatiengviet,
      isAvailable: true,
    ),
    (
      title: 'Chép chính tả',
      description: 'Luyện nghe và viết tiếng Việt chuẩn xác nhất',
      image: AppAssets.gamechepchinhta,
      isAvailable: true,
    ),
    (
      title: 'Học cùng bé',
      description:
          'Khám phá thế giới tri thức cùng những bài học vui nhộn cho bé',
      image: AppAssets.gamehoccungbe,
      isAvailable: true,
    ),
    (
      title: 'Ca dao tục ngữ',
      description:
          'Tìm hiểu kho tàng trí tuệ dân gian qua các câu ca dao truyền thống',
      image: AppAssets.gamecadao,
      isAvailable: true,
    ),
    (
      title: 'Nhanh như chớp',
      description:
          'Thử thách phản xạ và kiến thức cực nhanh với các câu hỏi hóc búa',
      image: AppAssets.gamenhanhnhuchop,
      isAvailable: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.gamepad2,
                size: 20,
                color: AppColors.accent,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Khu Vực Trò Chơi',
                style: AppTypography.h3.copyWith(color: AppColors.foreground),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ..._games.mapIndexed(
            (index, game) => Padding(
              padding: EdgeInsets.only(
                bottom: index < _games.length - 1 ? AppSpacing.sm : 0,
              ),
              child: _buildCard(context, index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, int index) {
    final game = _games[index];
    return GameCardWidget(
      title: game.title,
      description: game.description,
      image: game.image,
      isAvailable: game.isAvailable,
      onTap: () => _onGameTap(context, index),
    );
  }

  void _onGameTap(BuildContext context, int index) {
    final game = _games[index];
    if (!game.isAvailable) {
      AppToast.info(context, 'Sắp ra mắt');
      return;
    }

    switch (index) {
      case 0: // Đuổi hình bắt chữ
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const PictogramSelectionModal(),
        );
      case 1: // Vua tiếng Việt
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const VTVSelectionModal(),
        );
      case 2: // Chép chính tả
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const DictationSelectionModal(),
        );
      case 3: // Học cùng bé
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const HCBCategorySelectionModal(),
        );
      case 4: // Ca dao tục ngữ
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const CDTNSelectionModal(),
        );
      case 5: // Nhanh như chớp
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const NNCSelectionModal(),
        );
    }
  }
}
