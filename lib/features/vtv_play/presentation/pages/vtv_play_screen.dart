import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../router/route_names.dart';
import '../../../home/domain/entities/vtv_question_entity.dart';
import '../bloc/vtv_play_bloc.dart';
import '../widgets/vtv_game_result_view.dart';
import '../widgets/vtv_question_view.dart';

class VTVPlayScreen extends StatelessWidget {
  const VTVPlayScreen({
    required this.questions,
    required this.timeInMinutes,
    super.key,
  });

  final List<VTVQuestionEntity> questions;
  final int timeInMinutes;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VTVPlayBloc()
        ..add(StartGame(questions: questions, timeInMinutes: timeInMinutes)),
      child: const _VTVPlayView(),
    );
  }
}

class _VTVPlayView extends StatelessWidget {
  const _VTVPlayView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(RoutePaths.home)),
      ),
      backgroundColor: AppColors.background,
      body: BlocBuilder<VTVPlayBloc, VTVPlayState>(
        builder: (context, state) => switch (state) {
          VTVPlayInProgress() => const VTVQuestionView(),
          VTVPlayFinished() => const VTVGameResultView(),
          _ => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        },
      ),
    );
  }
}
