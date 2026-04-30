import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_learn/app/di/injection.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/widgets/app_dropdown_field.dart';
import 'package:smart_learn/core/widgets/app_toast.dart';
import 'package:smart_learn/features/home/domain/usecases/get_nnc_questions.dart';
import 'package:smart_learn/features/home/presentation/widgets/games/game_selection_sheet.dart';
import 'package:smart_learn/features/home/presentation/widgets/games/game_selection_title.dart';
import 'package:smart_learn/router/route_names.dart';

class NNCSelectionModal extends StatefulWidget {
  const NNCSelectionModal({super.key});

  @override
  State<NNCSelectionModal> createState() => _NNCSelectionModalState();
}

class _NNCSelectionModalState extends State<NNCSelectionModal> {
  static const _questionCounts = [10, 20, 30];
  static const _timeMinutes = [5, 10, 15];

  int _selectedLevel = 1;
  int _selectedCount = 10;
  int _selectedTime = 5;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GameSelectionSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GameSelectionTitle(
            title: 'Nhanh như chớp',
            subtitle: 'Cấu hình lượt chơi của bạn',
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.mdLg),
          const GameSectionTitle('Cấp độ'),
          const SizedBox(height: AppSpacing.sm),
          LevelChipRow(
            selectedIndex: _selectedLevel,
            onSelected: (i) => setState(() => _selectedLevel = i),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppDropdownField<int>(
                  label: 'Số câu hỏi',
                  value: _selectedCount,
                  items: _questionCounts
                      .map(
                        (v) =>
                            DropdownMenuItem(value: v, child: Text('$v câu')),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedCount = v);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppDropdownField<int>(
                  label: 'Thời gian (phút)',
                  value: _selectedTime,
                  items: _timeMinutes
                      .map(
                        (v) =>
                            DropdownMenuItem(value: v, child: Text('$v phút')),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedTime = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          GameModalFooter(isLoading: _isLoading, onPlay: _onPlay),
        ],
      ),
    );
  }

  Future<void> _onPlay() async {
    setState(() => _isLoading = true);

    final useCase = getIt<GetNNCQuestionsUseCase>();
    final result = await useCase(
      NNCParams(level: levelValueAt(_selectedLevel), limit: _selectedCount),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold((failure) => AppToast.error(context, failure.message), (
      questions,
    ) {
      if (questions.isEmpty) {
        AppToast.error(context, 'Không có câu hỏi nào cho cấp độ này');
        return;
      }
      Navigator.of(context).pop();
      context.go(
        RoutePaths.nncPlay,
        extra: {'questions': questions, 'timeInMinutes': _selectedTime},
      );
    });
  }
}
