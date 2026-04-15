import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_learn/app/di/injection.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';
import 'package:smart_learn/core/widgets/app_toast.dart';
import 'package:smart_learn/features/home/domain/usecases/get_pictogram_questions.dart';

class PictogramSelectionModal extends StatefulWidget {
  const PictogramSelectionModal({super.key});

  @override
  State<PictogramSelectionModal> createState() =>
      _PictogramSelectionModalState();
}

class _PictogramSelectionModalState extends State<PictogramSelectionModal> {
  static const _levels = [
    (label: 'Dễ', value: 'easy'),
    (label: 'Trung bình', value: 'medium'),
    (label: 'Khó', value: 'hard'),
    (label: 'Cực khó', value: 'extreme'),
  ];

  static const _questionCounts = [5, 10, 15, 20, 30];
  static const _timeMinutes = [1, 2, 3, 5, 10, 15];

  int _selectedLevel = 1; // "Trung bình"
  int _selectedCount = 10;
  int _selectedTime = 5;
  bool _isLoading = false;

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
            'Đuổi hình bắt chữ',
            style: AppTypography.h4.copyWith(color: AppColors.foreground),
          ),
          const SizedBox(height: AppSpacing.mdLg),
          _buildSectionTitle('Cấp độ'),
          const SizedBox(height: AppSpacing.sm),
          _buildLevelChips(),
          const SizedBox(height: AppSpacing.md),
          _buildSectionTitle('Số câu hỏi'),
          const SizedBox(height: AppSpacing.sm),
          _buildCountChips(),
          const SizedBox(height: AppSpacing.md),
          _buildSectionTitle('Thời gian (phút)'),
          const SizedBox(height: AppSpacing.sm),
          _buildTimeChips(),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onPlay,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: AppBorders.shapeMd,
                textStyle: AppTypography.buttonLarge,
              ),
              child: _isLoading
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

  Widget _buildLevelChips() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: List.generate(_levels.length, (index) {
        final isSelected = _selectedLevel == index;
        return _buildChip(
          label: _levels[index].label,
          isSelected: isSelected,
          onTap: () => setState(() => _selectedLevel = index),
        );
      }),
    );
  }

  Widget _buildCountChips() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _questionCounts.map((count) {
        final isSelected = _selectedCount == count;
        return _buildChip(
          label: '$count',
          isSelected: isSelected,
          onTap: () => setState(() => _selectedCount = count),
        );
      }).toList(),
    );
  }

  Widget _buildTimeChips() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _timeMinutes.map((time) {
        final isSelected = _selectedTime == time;
        return _buildChip(
          label: '$time',
          isSelected: isSelected,
          onTap: () => setState(() => _selectedTime = time),
        );
      }).toList(),
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
            color: isSelected
                ? AppColors.accent
                : AppColors.border,
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
    setState(() => _isLoading = true);

    final useCase = getIt<GetPictogramQuestionsUseCase>();
    final result = await useCase(
      PictogramParams(
        level: _levels[_selectedLevel].value,
        limit: _selectedCount,
      ),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        AppToast.error(context, failure.message);
      },
      (questions) {
        if (questions.isEmpty) {
          AppToast.error(context, 'Không có câu hỏi nào cho cấp độ này');
          return;
        }
        Navigator.of(context).pop();
        context.go('/games/pictogram/play', extra: {
          'questions': questions,
          'timeInMinutes': _selectedTime,
        });
      },
    );
  }
}
