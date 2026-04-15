import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../quizlet/domain/entities/quizlet_entity.dart';
import '../bloc/quizlet/quizlet_bloc.dart';

class QuizletListPage extends StatelessWidget {
  const QuizletListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuizletBloc>(
      create: (_) => getIt<QuizletBloc>()..add(const LoadQuizlets()),
      child: const _QuizletListView(),
    );
  }
}

class _QuizletListView extends StatelessWidget {
  const _QuizletListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Flashcards',
          style: AppTypography.h3.copyWith(color: AppColors.foreground),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: BlocBuilder<QuizletBloc, QuizletState>(
        builder: (context, state) => switch (state) {
          QuizletLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
          QuizletLoaded(:final quizlets) => quizlets.isEmpty
              ? Center(
                  child: Padding(
                    padding: AppSpacing.paddingMd,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.style_outlined,
                          size: AppSpacing.huge,
                          color: AppColors.mutedForeground,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Chưa có bộ flashcard nào',
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
                  itemCount: quizlets.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.smMd),
                  itemBuilder: (context, index) {
                    final quizlet = quizlets[index];
                    return _QuizletCard(quizlet: quizlet);
                  },
                ),
          QuizletError(:final message) => Center(
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
                          .read<QuizletBloc>()
                          .add(const RefreshQuizlets()),
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

class _QuizletCard extends StatelessWidget {
  const _QuizletCard({required this.quizlet});

  final QuizletEntity quizlet;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/quizlet/${quizlet.id}'),
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
              quizlet.title,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.foreground,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              quizlet.subjectName,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.style_outlined,
                  size: AppSpacing.md,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${quizlet.termCount} thuật ngữ',
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
                    quizlet.authorName,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                    overflow: TextOverflow.ellipsis,
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
