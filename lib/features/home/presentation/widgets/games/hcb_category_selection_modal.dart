import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_learn/app/di/injection.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/core/widgets/app_toast.dart';
import 'package:smart_learn/features/home/domain/entities/learning_category_entity.dart';
import 'package:smart_learn/features/home/domain/usecases/get_learning_categories.dart';
import 'package:smart_learn/features/home/domain/usecases/get_learning_questions.dart';
import 'package:smart_learn/router/route_names.dart';

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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorders.radiusXxl),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.mdLg,
        AppSpacing.sm,
        AppSpacing.mdLg,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: AppBorders.borderRadiusFull,
              ),
            ),
          ),
          Text(
            'Học cùng bé',
            style: AppTypography.h4.copyWith(color: AppColors.foreground),
          ),
          const SizedBox(height: AppSpacing.mdLg),
          _buildSectionTitle('Chọn chủ đề'),
          const SizedBox(height: AppSpacing.sm),
          _buildCategoryList(),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed:
                  _selectedIndex == null || _isPlayLoading ? null : _onPlay,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: AppBorders.shapeMd,
                textStyle: AppTypography.buttonLarge,
              ),
              child: _isPlayLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Chơi ngay'),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.labelMedium.copyWith(
        color: AppColors.foreground,
      ),
    );
  }

  Widget _buildCategoryList() {
    if (_isCategoriesLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
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

    if (_categories!.isEmpty) {
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

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: List.generate(_categories!.length, (index) {
        final category = _categories![index];
        final isSelected = _selectedIndex == index;
        return _buildChip(
          label: '${category.name} (${category.itemCount})',
          isSelected: isSelected,
          onTap: () => setState(() => _selectedIndex = index),
        );
      }),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.background,
          borderRadius: AppBorders.borderRadiusSm,
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected ? Colors.white : AppColors.foreground,
          ),
        ),
      ),
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

    result.fold(
      (failure) {
        AppToast.error(context, failure.message);
      },
      (questions) {
        if (questions.isEmpty) {
          AppToast.info(context, 'Không có câu hỏi nào cho chủ đề này');
          return;
        }
        Navigator.of(context).pop();
        context.pushNamed(
          RouteNames.hcbPlay,
          extra: {
            'questions': questions,
            'generalQuestion': category.generalQuestion,
          },
        );
      },
    );
  }
}
