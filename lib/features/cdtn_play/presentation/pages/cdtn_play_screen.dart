import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/theme.dart';
import '../../../home/domain/entities/proverb_entity.dart';
import '../../../home/presentation/helpers/level_icon_circle.dart';
import '../bloc/cdtn_play_bloc.dart';
import '../widgets/cdtn_game_result_view.dart';
import '../widgets/cdtn_question_view.dart';

class CDTNPlayScreen extends StatelessWidget {
  const CDTNPlayScreen({
    required this.questions,
    required this.timeInMinutes,
    this.level,
    super.key,
  });

  final List<ProverbEntity> questions;
  final int timeInMinutes;
  final String? level;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CDTNPlayBloc()
        ..add(StartGame(questions: questions, timeInMinutes: timeInMinutes)),
      child: _CDTNPlayView(level: level),
    );
  }
}

class _CDTNPlayView extends StatelessWidget {
  const _CDTNPlayView({this.level});

  final String? level;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CDTNPlayBloc, CDTNPlayState>(
      builder: (context, state) => switch (state) {
        CDTNPlayInProgress() => Scaffold(
          appBar: _AppBar(
            level: level,
            currentIndex: state.currentIndex,
            totalQuestions: state.questions.length,
          ),
          body: SafeArea(child: const CDTNQuestionView()),
        ),
        CDTNPlayFinished() => Scaffold(
          body: SafeArea(child: const CDTNGameResultView()),
        ),
        _ => Scaffold(
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
                  Text('Ca dao tục ngữ', style: AppTypography.textBase.bold),
                  if (currentIndex != null && totalQuestions != null)
                    Text(
                      'CÂU ${currentIndex! + 1} / ${totalQuestions!}',
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
