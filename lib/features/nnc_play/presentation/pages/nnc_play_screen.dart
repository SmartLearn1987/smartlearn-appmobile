import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../router/route_names.dart';
import '../../../home/domain/entities/nnc_question_entity.dart';
import '../bloc/nnc_play_bloc.dart';
import '../widgets/nnc_game_result_view.dart';
import '../widgets/nnc_loading_view.dart';
import '../widgets/nnc_question_view.dart';

class NNCPlayScreen extends StatelessWidget {
  const NNCPlayScreen({
    required this.questions,
    required this.timeInMinutes,
    super.key,
  });

  final List<NNCQuestionEntity> questions;
  final int timeInMinutes;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NNCPlayBloc()
        ..add(StartGame(questions: questions, timeInMinutes: timeInMinutes)),
      child: const _NNCPlayView(),
    );
  }
}

class _NNCPlayView extends StatelessWidget {
  const _NNCPlayView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(RoutePaths.home)),
      ),
      backgroundColor: AppColors.background,
      body: BlocBuilder<NNCPlayBloc, NNCPlayState>(
        builder: (context, state) => switch (state) {
          NNCPlayInitial() => const SizedBox.shrink(),
          NNCPlayLoading() => const NNCLoadingView(),
          NNCPlayInProgress() => const NNCQuestionView(),
          NNCPlayFinished() => const NNCGameResultView(),
        },
      ),
    );
  }
}
