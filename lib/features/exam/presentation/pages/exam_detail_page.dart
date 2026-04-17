import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../router/route_names.dart';
import '../../domain/entities/exam_detail_entity.dart';
import '../bloc/exam_detail/exam_detail_bloc.dart';

class ExamDetailPage extends StatelessWidget {
  const ExamDetailPage({required this.examId, super.key});

  final String examId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExamDetailBloc>(
      create: (_) =>
          getIt<ExamDetailBloc>()..add(LoadExamDetail(examId: examId)),
      child: const _ExamDetailView(),
    );
  }
}

class _ExamDetailView extends StatelessWidget {
  const _ExamDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
        title: BlocBuilder<ExamDetailBloc, ExamDetailState>(
          buildWhen: (prev, curr) =>
              curr is ExamDetailLoaded ||
              curr is ExamDetailLoading ||
              curr is ExamDetailError,
          builder: (context, state) {
            if (state is ExamDetailLoaded) {
              return Text(
                state.detail.title,
                style: AppTypography.h4.copyWith(color: AppColors.foreground),
                overflow: TextOverflow.ellipsis,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      body: BlocBuilder<ExamDetailBloc, ExamDetailState>(
        buildWhen: (prev, curr) =>
            curr is ExamDetailLoading ||
            curr is ExamDetailLoaded ||
            curr is ExamDetailError,
        builder: (context, state) => switch (state) {
          ExamDetailLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
          ExamDetailLoaded(:final detail) => _LoadedContent(detail: detail),
          ExamDetailError(:final message) => _ErrorContent(message: message),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _LoadedContent extends StatelessWidget {
  const _LoadedContent({required this.detail});

  final ExamDetailEntity detail;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              detail.title,
              style: AppTypography.h3.copyWith(color: AppColors.foreground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: 20,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${detail.questions.length} câu hỏi',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Icon(
                  Icons.timer_outlined,
                  size: 20,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${detail.duration} phút',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    context.go(RoutePaths.examPlay(detail.id), extra: detail),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.primaryForeground,
                  textStyle: AppTypography.buttonLarge,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.smMd,
                  ),
                ),
                child: const Text('Bắt đầu làm bài'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: () {
                final page =
                    context.findAncestorWidgetOfExactType<ExamDetailPage>();
                if (page != null) {
                  context.read<ExamDetailBloc>().add(
                        LoadExamDetail(examId: page.examId),
                      );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
                textStyle: AppTypography.buttonMedium,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
