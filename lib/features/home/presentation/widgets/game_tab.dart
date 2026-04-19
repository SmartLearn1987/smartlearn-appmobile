import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/constants/app_assets.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';
import 'package:smart_learn/core/widgets/app_toast.dart';
import 'package:smart_learn/features/home/presentation/widgets/dictation_selection_modal.dart';
import 'package:smart_learn/features/home/presentation/widgets/game_card_widget.dart';
import 'package:smart_learn/features/home/presentation/widgets/pictogram_selection_modal.dart';

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
      isAvailable: false,
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
      isAvailable: false,
    ),
    (
      title: 'Ca dao tục ngữ',
      description:
          'Tìm hiểu kho tàng trí tuệ dân gian qua các câu ca dao truyền thống',
      image: AppAssets.gamecadao,
      isAvailable: false,
    ),
    (
      title: 'Nhanh như chớp',
      description:
          'Thử thách phản xạ và kiến thức cực nhanh với các câu hỏi hóc búa',
      image: AppAssets.gamenhanhnhuchop,
      isAvailable: false,
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
          _buildGrid(context),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < _games.length; i += 2)
          Padding(
            padding: EdgeInsets.only(
              bottom: i + 2 < _games.length ? AppSpacing.sm : 0,
            ),
            child: Row(
              children: [
                Expanded(child: _buildCard(context, i)),
                const SizedBox(width: AppSpacing.smMd),
                if (i + 1 < _games.length)
                  Expanded(child: _buildCard(context, i + 1))
                else
                  const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
      ],
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
      case 2: // Chép chính tả
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const DictationSelectionModal(),
        );
    }
  }
}
