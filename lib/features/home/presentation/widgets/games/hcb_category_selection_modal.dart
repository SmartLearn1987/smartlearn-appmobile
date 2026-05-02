import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/app/di/injection.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/core/widgets/app_toast.dart';
import 'package:smart_learn/features/home/domain/entities/learning_category_entity.dart';
import 'package:smart_learn/features/home/domain/usecases/get_learning_categories.dart';
import 'package:smart_learn/features/home/domain/usecases/get_learning_questions.dart';
import 'package:smart_learn/features/home/presentation/widgets/games/game_selection_sheet.dart';
import 'package:smart_learn/features/home/presentation/widgets/games/game_selection_title.dart';
import 'package:smart_learn/router/route_names.dart';

import '../../../../../core/theme/theme.dart';

class HCBCategorySelectionModal extends StatefulWidget {
  const HCBCategorySelectionModal({super.key});

  @override
  State<HCBCategorySelectionModal> createState() =>
      _HCBCategorySelectionModalState();
}

class _HCBCategorySelectionModalState extends State<HCBCategorySelectionModal> {
  List<LearningCategoryEntity>? _categories;
  bool _isCategoriesLoading = true;
  String? _categoriesError;
  int? _selectedIndex;
  bool _isPlayLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final useCase = getIt<GetLearningCategoriesUseCase>();
    final result = await useCase(const NoParams());

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isCategoriesLoading = false;
          _categoriesError = failure.message;
        });
        AppToast.error(context, failure.message);
      },
      (categories) {
        setState(() {
          _isCategoriesLoading = false;
          _categories = categories;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameSelectionSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GameSelectionTitle(
            icon: LucideIcons.bookOpen,
            title: 'Học cùng bé',
            subtitle: 'Chọn một chủ đề để bắt đầu bài học',
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.mdLg),
          _buildCategoryList(),
          const SizedBox(height: AppSpacing.lg),
          GameModalFooter(
            isLoading: _isPlayLoading,
            onPlay: _onPlay,
            playEnabled: _selectedIndex != null,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    if (_isCategoriesLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_categoriesError != null || _categories == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(
          child: Text(
            _categoriesError ?? 'Đã xảy ra lỗi không xác định',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ),
      );
    }

    // Filter out categories with no items
    final visible = _categories!.asMap().entries.where((e) {
      final count = int.tryParse(e.value.itemCount ?? '0') ?? 0;
      return count > 0;
    }).toList();

    if (visible.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(
          child: Text(
            'Không có chủ đề nào',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ),
      );
    }

    return Column(
      children: visible.map((entry) {
        final index = entry.key;
        final category = entry.value;
        final isSelected = _selectedIndex == index;
        final count = category.itemCount ?? '0';

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _CategoryCard(
            name: category.name,
            itemCount: count,
            isSelected: isSelected,
            onTap: () => setState(() => _selectedIndex = index),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _onPlay() async {
    if (_selectedIndex == null || _categories == null) return;

    final category = _categories![_selectedIndex!];
    setState(() => _isPlayLoading = true);

    final useCase = getIt<GetLearningQuestionsUseCase>();
    final result = await useCase(category.id);

    if (!mounted) return;
    setState(() => _isPlayLoading = false);

    result.fold((failure) => AppToast.error(context, failure.message), (
      questions,
    ) {
      if (questions.isEmpty) {
        AppToast.info(context, 'Không có câu hỏi nào cho chủ đề này');
        return;
      }
      Navigator.of(context).pop();
      context.pushNamed(
        RouteNames.hcbPlay,
        extra: {
          'categoryName': category.name,
          'questions': questions,
          'generalQuestion': category.generalQuestion,
        },
      );
    });
  }
}

// ─── Category card ────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.name,
    required this.itemCount,
    required this.isSelected,
    required this.onTap,
  });

  final String name;
  final String itemCount;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? AppColors.primary.withValues(alpha: 0.1)
        : Colors.transparent;
    final borderColor = isSelected
        ? AppColors.primary.withValues(alpha: 0.5)
        : AppColors.border;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.smMd,
          vertical: AppSpacing.smMd,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppBorders.borderRadiusLg,
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.border,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.layoutGrid,
                size: 20,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(width: AppSpacing.smMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTypography.textSm.bold.copyWith(
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$itemCount HÌNH ẢNH',
                    style: AppTypography.text2Xs.bold.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            // Selection dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
