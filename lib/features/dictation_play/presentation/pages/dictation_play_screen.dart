import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../router/route_names.dart';
import '../../../home/domain/entities/dictation_entity.dart';
import '../bloc/dictation_play_bloc.dart';
import '../widgets/dictation_audio_button.dart';
import '../widgets/dictation_input_area.dart';
import '../widgets/dictation_result_view.dart';

/// Main screen for the Dictation game play.
///
/// Receives a [DictationEntity] via constructor, provides
/// [DictationPlayBloc] to the widget tree, and dispatches
/// [StartDictation] on initialization.
///
/// Displays:
/// - [DictationAudioButton] + [DictationInputArea] during play
/// - [DictationResultView] after submission
class DictationPlayScreen extends StatelessWidget {
  const DictationPlayScreen({
    required this.entity,
    super.key,
  });

  final DictationEntity entity;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DictationPlayBloc>()
        ..add(StartDictation(entity: entity)),
      child: _DictationPlayView(entity: entity),
    );
  }
}

class _DictationPlayView extends StatelessWidget {
  const _DictationPlayView({required this.entity});

  final DictationEntity entity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.go(RoutePaths.home),
        ),
        title: Column(
          children: [
            Text(
              entity.title,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.foreground,
              ),
            ),
            Text(
              entity.level,
              style: AppTypography.caption.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.foreground,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: BlocBuilder<DictationPlayBloc, DictationPlayState>(
        builder: (context, state) => switch (state) {
          DictationPlayInProgress() => _InProgressBody(state: state),
          DictationPlayFinished() => DictationResultView(
              result: state.result,
              wordComparisons: state.wordComparisons,
              userInput: state.userInput,
              onPlayAgain: () => context.go(RoutePaths.home),
              onGoHome: () => context.go(RoutePaths.home),
            ),
          _ => const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
        },
      ),
    );
  }
}

/// Body content shown while the dictation game is in progress.
///
/// Displays the audio replay button and the text input area.
class _InProgressBody extends StatelessWidget {
  const _InProgressBody({required this.state});

  final DictationPlayInProgress state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          DictationAudioButton(
            isPlaying: state.isPlaying,
            onPressed: () => context
                .read<DictationPlayBloc>()
                .add(const ReplayAudio()),
          ),
          const SizedBox(height: 32),
          DictationInputArea(
            userInput: state.userInput,
            wordCount: state.wordCount,
            onChanged: (text) => context
                .read<DictationPlayBloc>()
                .add(UpdateUserInput(text: text)),
            onSubmit: () => context
                .read<DictationPlayBloc>()
                .add(const SubmitAnswer()),
          ),
        ],
      ),
    );
  }
}
