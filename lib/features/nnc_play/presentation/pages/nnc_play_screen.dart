import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/theme.dart';
import '../../../home/domain/entities/nnc_question_entity.dart';
import '../../../home/presentation/helpers/level_icon_circle.dart';
import '../bloc/nnc_play_bloc.dart';
import '../widgets/nnc_game_result_view.dart';
import '../widgets/nnc_loading_view.dart';
import '../widgets/nnc_question_view.dart';

class NNCPlayScreen extends StatelessWidget {
  const NNCPlayScreen({
    required this.questions,
    required this.timeInMinutes,
    this.level,
    super.key,
  });

  final List<NNCQuestionEntity> questions;
  final int timeInMinutes;
  final String? level;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NNCPlayBloc()
        ..add(StartGame(questions: questions, timeInMinutes: timeInMinutes)),
      child: _NNCPlayView(level: level),
    );
  }
}

class _NNCPlayView extends StatelessWidget {
  const _NNCPlayView({this.level});

  final String? level;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NNCPlayBloc, NNCPlayState>(
      builder: (context, state) => switch (state) {
        NNCPlayInProgress() => Scaffold(
          backgroundColor: AppColors.background,
          appBar: _AppBar(
            level: level,
            currentIndex: state.currentIndex,
            totalQuestions: state.questions.length,
          ),
          body: SafeArea(child: const NNCQuestionView()),
        ),
        NNCPlayFinished() => Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(child: const NNCGameResultView()),
        ),
        NNCPlayLoading() => Scaffold(
          backgroundColor: AppColors.background,
          appBar: _AppBar(level: level),
          body: const NNCLoadingView(),
        ),
        _ => Scaffold(
          backgroundColor: AppColors.background,
          appBar: _AppBar(level: level),
          body: const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      },
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({this.level, this.currentIndex, this.totalQuestions});

  final String? level;
  final int? currentIndex;
  final int? totalQuestions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: BackButton(onPressed: () => context.pop()),
      title: Padding(
        padding: const EdgeInsets.only(right: kToolbarHeight),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LevelIconCircle(icon: LucideIcons.gamepad2, level: level),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nhanh như chớp', style: AppTypography.textBase.bold),
                  if (currentIndex != null && totalQuestions != null)
                    Text(
                      'THỬ THÁCH ${currentIndex! + 1} / ${totalQuestions!}',
                      style: AppTypography.text2Xs.semiBold.withColor(
                        AppColors.mutedForeground,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
