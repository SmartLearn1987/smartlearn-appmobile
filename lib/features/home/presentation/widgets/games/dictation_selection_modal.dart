import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_learn/app/di/injection.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/widgets/app_toast.dart';
import 'package:smart_learn/features/home/domain/usecases/get_random_dictation.dart';
import 'package:smart_learn/features/home/presentation/widgets/games/game_selection_sheet.dart';
import 'package:smart_learn/features/home/presentation/widgets/games/game_selection_title.dart';
import 'package:smart_learn/router/route_names.dart';

class DictationSelectionModal extends StatefulWidget {
  const DictationSelectionModal({super.key});

  @override
  State<DictationSelectionModal> createState() =>
      _DictationSelectionModalState();
}

class _DictationSelectionModalState extends State<DictationSelectionModal> {
  static const _languages = [
    (label: '🇻🇳 Tiếng Việt', value: 'vi'),
    (label: '🇺🇸 Tiếng Anh', value: 'en'),
    (label: '🇯🇵 Tiếng Nhật', value: 'ja'),
  ];

  int _selectedLevel = 1;
  String _selectedLanguage = 'vi';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GameSelectionSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GameSelectionTitle(
            title: 'Chép chính tả',
            subtitle: 'Chọn cấp độ và ngôn ngữ',
            color: AppColors.quiz,
          ),
          const SizedBox(height: AppSpacing.mdLg),
          const GameSectionTitle('Cấp độ'),
          const SizedBox(height: AppSpacing.sm),
          LevelChipRow(
            selectedIndex: _selectedLevel,
            onSelected: (i) => setState(() => _selectedLevel = i),
          ),
          const SizedBox(height: AppSpacing.md),
          const GameSectionTitle('Ngôn ngữ'),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _languages.map((lang) {
              return GameSelectionChip(
                label: lang.label,
                isSelected: _selectedLanguage == lang.value,
                activeColor: AppColors.primary,
                onTap: () => setState(() => _selectedLanguage = lang.value),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          GameModalFooter(
            isLoading: _isLoading,
            onPlay: _onPlay,
            playColor: AppColors.quiz,
          ),
        ],
      ),
    );
  }

  Future<void> _onPlay() async {
    setState(() => _isLoading = true);

    final useCase = getIt<GetRandomDictationUseCase>();
    final result = await useCase(
      DictationParams(
        level: levelValueAt(_selectedLevel),
        language: _selectedLanguage,
      ),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold((failure) => AppToast.error(context, failure.message), (
      dictation,
    ) {
      Navigator.of(context).pop();
      if (context.mounted) {
        context.go(RoutePaths.dictationPlay, extra: dictation);
      }
    });
  }
}
