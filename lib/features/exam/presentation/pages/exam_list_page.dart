import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/exam_entity.dart';
import '../bloc/exam/exam_bloc.dart';

class ExamListPage extends StatelessWidget {
  const ExamListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExamBloc>(
      create: (_) => getIt<ExamBloc>()..add(const LoadExams()),
      child: const _ExamListView(),
    );
  }
}

class _ExamListView extends StatelessWidget {
  const _ExamListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Trắc Nghiệm',
          style: AppTypography.h3.copyWith(color: AppColors.foreground),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: BlocBuilder<ExamBloc, ExamState>(
        builder: (context, state) => switch (state) {
          ExamLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
          ExamLoaded(:final exams) => exams.isEmpty
              ? Center(
                  child: Padding(
                    padding: AppSpacing.paddingMd,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.quiz_outlined,
                          size: AppSpacing.huge,
                          color: AppColors.mutedForeground,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Chưa có bài trắc nghiệm nào',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.mdLg),
                  itemCount: exams.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.smMd),
                  itemBuilder: (context, index) {
                    final exam = exams[index];
                    return _ExamCard(exam: exam);
                  },
                ),
          ExamError(:final message) => Center(
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
                      onPressed: () => context
                          .read<ExamBloc>()
                          .add(const RefreshExams()),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.exam});

  final ExamEntity exam;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/exams/${exam.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppBorders.borderRadiusMd,
          boxShadow: AppShadows.card,
        ),
        padding: AppSpacing.paddingCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exam.title,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.foreground,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              exam.subjectName,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: AppSpacing.md,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${exam.questionCount} câu hỏi',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Icon(
                  Icons.timer_outlined,
                  size: AppSpacing.md,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${exam.duration} phút',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Icon(
                  Icons.person_outline,
                  size: AppSpacing.md,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    exam.authorName,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  Icons.star_outline,
                  size: AppSpacing.md,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${exam.averageScore.toStringAsFixed(1)} điểm TB',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
