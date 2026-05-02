import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/theme.dart';
import '../../../home/domain/entities/pictogram_entity.dart';
import '../../../../router/route_names.dart';
import '../bloc/pictogram_play_bloc.dart';
import '../controllers/game_session_controller.dart';
import '../widgets/game_result_view.dart';
import '../widgets/question_view.dart';

class PictogramPlayScreen extends StatefulWidget {
  const PictogramPlayScreen({
    required this.questions,
    required this.timeInMinutes,
    super.key,
  });

  final List<PictogramEntity> questions;
  final int timeInMinutes;

  @override
  State<PictogramPlayScreen> createState() => _PictogramPlayScreenState();
}

class _PictogramPlayScreenState extends State<PictogramPlayScreen> {
  late GameSessionController _session;

  @override
  void initState() {
    super.initState();
    _session = GameSessionController(questions: widget.questions);
  }

  void _restartSession() {
    _session.dispose();
    setState(() {
      _session = GameSessionController(questions: widget.questions);
    });
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PictogramPlayBloc()
        ..add(
          StartGame(
            questions: widget.questions,
            timeInMinutes: widget.timeInMinutes,
          ),
        ),
      child: _PictogramPlayView(
        questions: widget.questions,
        timeInMinutes: widget.timeInMinutes,
        session: _session,
        onRestart: _restartSession,
      ),
    );
  }
}

class _PictogramPlayView extends StatelessWidget {
  const _PictogramPlayView({
    required this.questions,
    required this.timeInMinutes,
    required this.session,
    required this.onRestart,
  });

  final List<PictogramEntity> questions;
  final int timeInMinutes;
  final GameSessionController session;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PictogramPlayBloc, PictogramPlayState>(
      builder: (context, state) => switch (state) {
        PictogramPlayInProgress() => Scaffold(
          appBar: _AppBar(
            currentIndex: state.currentIndex,
            totalQuestions: state.questions.length,
          ),
          body: SafeArea(
            child: QuestionView(
              question: state.questions[state.currentIndex],
              currentIndex: state.currentIndex,
              totalQuestions: state.questions.length,
              remainingSeconds: state.remainingSeconds,
              answeredQuestions: state.answeredQuestions,
              session: session,
              onGoTo: (index) => context.read<PictogramPlayBloc>().add(
                GoToQuestion(index: index),
              ),
              onPrevious: () => context.read<PictogramPlayBloc>().add(
                const PreviousQuestion(),
              ),
              onNext: () =>
                  context.read<PictogramPlayBloc>().add(const NextQuestion()),
              onEndGame: () {
                // Tổng hợp kết quả từ session trước khi kết thúc
                final results = session.buildResults();
                final correct = session.correctCount;
                context.read<PictogramPlayBloc>().add(
                  EndGameWithResults(
                    answeredQuestions: results,
                    correctCount: correct,
                  ),
                );
              },
            ),
          ),
        ),
        PictogramPlayFinished() => Scaffold(
          appBar: AppBar(),
          body: SafeArea(
            child: GameResultView(
              correctCount: state.correctCount,
              totalQuestions: state.totalQuestions,
              elapsedSeconds: state.elapsedSeconds,
              questions: state.questions,
              answeredQuestions: state.answeredQuestions,
              onPlayAgain: () {
                onRestart();
                context.read<PictogramPlayBloc>().add(
                  StartGame(
                    questions: questions,
                    timeInMinutes: timeInMinutes,
                  ),
                );
              },
              onGoHome: () => context.go(RoutePaths.home),
            ),
          ),
        ),
        _ => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      },
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({required this.currentIndex, required this.totalQuestions});

  final int currentIndex;
  final int totalQuestions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: BackButton(onPressed: () => context.go(RoutePaths.home)),
      title: Padding(
        padding: const EdgeInsets.only(right: kToolbarHeight),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.gamepad2, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Đuổi hình bắt chữ', style: AppTypography.textBase.bold),
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
