import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_learn/app/di/injection.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';
import 'package:smart_learn/core/widgets/app_toast.dart';
import 'package:smart_learn/features/home/domain/usecases/get_random_dictation.dart';

class DictationSelectionModal extends StatefulWidget {
  const DictationSelectionModal({super.key});

  @override
  State<DictationSelectionModal> createState() =>
      _DictationSelectionModalState();
}

class _DictationSelectionModalState extends State<DictationSelectionModal> {
  static const _levels = [
    (label: 'Dễ', value: 'easy'),
    (label: 'Trung bình', value: 'medium'),
    (label: 'Khó', value: 'hard'),
    (label: 'Cực khó', value: 'extreme'),
  ];

  static const _languages = [
    (label: '🇻🇳 Tiếng Việt', value: 'vi'),
    (label: '🇺🇸 Tiếng Anh', value: 'en'),
    (label: '🇯🇵 Tiếng Nhật', value: 'ja'),
  ];

  int _selectedLevel = 1; // "Trung bình"
  String _selectedLanguage = 'vi';
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
            'Chép chính tả',
            style: AppTypography.h4.copyWith(color: AppColors.foreground),
          ),
          const SizedBox(height: AppSpacing.mdLg),
          _buildSectionTitle('Cấp độ'),
          const SizedBox(height: AppSpacing.sm),
          _buildLevelChips(),
          const SizedBox(height: AppSpacing.md),
          _buildSectionTitle('Ngôn ngữ'),
          const SizedBox(height: AppSpacing.sm),
          _buildLanguageChips(),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onPlay,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.quiz,
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

  Widget _buildLanguageChips() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _languages.map((lang) {
        final isSelected = _selectedLanguage == lang.value;
        return _buildChip(
          label: lang.label,
          isSelected: isSelected,
          onTap: () => setState(() => _selectedLanguage = lang.value),
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
          color: isSelected ? AppColors.quiz : AppColors.background,
          borderRadius: AppBorders.borderRadiusSm,
          border: Border.all(
            color: isSelected ? AppColors.quiz : AppColors.border,
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

    final useCase = getIt<GetRandomDictationUseCase>();
    final result = await useCase(
      DictationParams(
        level: _levels[_selectedLevel].value,
        language: _selectedLanguage,
      ),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        AppToast.error(context, failure.message);
      },
      (dictation) {
        Navigator.of(context).pop();
        if (context.mounted) {
          context.go('/games/dictation/play', extra: dictation);
        }
      },
    );
  }
}
