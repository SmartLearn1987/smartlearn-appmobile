import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/theme.dart';
import '../../../home/domain/entities/vtv_question_entity.dart';
import '../../../home/presentation/helpers/level_icon_circle.dart';
import '../bloc/vtv_play_bloc.dart';
import '../widgets/vtv_game_result_view.dart';
import '../widgets/vtv_question_view.dart';

class VTVPlayScreen extends StatelessWidget {
  const VTVPlayScreen({
    required this.questions,
    required this.timeInMinutes,
    this.level,
    super.key,
  });

  final List<VTVQuestionEntity> questions;
  final int timeInMinutes;
  final String? level;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VTVPlayBloc()
        ..add(StartGame(questions: questions, timeInMinutes: timeInMinutes)),
      child: _VTVPlayView(level: level),
    );
  }
}

class _VTVPlayView extends StatelessWidget {
  const _VTVPlayView({this.level});

  final String? level;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VTVPlayBloc, VTVPlayState>(
      builder: (context, state) => switch (state) {
        VTVPlayInProgress() => Scaffold(
          appBar: _AppBar(
            currentIndex: state.currentIndex,
            totalQuestions: state.questions.length,
            level: level,
          ),
          body: SafeArea(child: const VTVQuestionView()),
        ),
        VTVPlayFinished() => Scaffold(
          body: SafeArea(child: const VTVGameResultView()),
        ),
        _ => Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: () => context.pop()),
          ),
          body: const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      },
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({
    required this.currentIndex,
    required this.totalQuestions,
    this.level,
  });

  final int currentIndex;
  final int totalQuestions;
  final String? level;

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
                  Text('Vua Tiếng Việt', style: AppTypography.textBase.bold),
                  Text(
                    'CÂU ${currentIndex + 1} / $totalQuestions',
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
