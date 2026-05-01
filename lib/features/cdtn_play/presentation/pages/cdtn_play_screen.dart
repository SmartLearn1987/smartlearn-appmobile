import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme.dart';
import '../../../../router/route_names.dart';
import '../../../home/domain/entities/proverb_entity.dart';
import '../bloc/cdtn_play_bloc.dart';
import '../widgets/cdtn_game_result_view.dart';
import '../widgets/cdtn_question_view.dart';

class CDTNPlayScreen extends StatelessWidget {
  const CDTNPlayScreen({
    required this.questions,
    required this.timeInMinutes,
    super.key,
  });

  final List<ProverbEntity> questions;
  final int timeInMinutes;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CDTNPlayBloc()
        ..add(StartGame(questions: questions, timeInMinutes: timeInMinutes)),
      child: const _CDTNPlayView(),
    );
  }
}

class _CDTNPlayView extends StatelessWidget {
  const _CDTNPlayView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(RoutePaths.home)),
      ),
      backgroundColor: AppColors.background,
      body: BlocBuilder<CDTNPlayBloc, CDTNPlayState>(
        builder: (context, state) => switch (state) {
          CDTNPlayInProgress() => const CDTNQuestionView(),
          CDTNPlayFinished() => const CDTNGameResultView(),
          _ => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        },
      ),
    );
  }
}
