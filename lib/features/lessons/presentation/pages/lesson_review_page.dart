import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../router/route_names.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/lesson_entity.dart';
import '../bloc/lesson_detail/lesson_detail_bloc.dart';
import '../widgets/content_block_renderer.dart';
import '../widgets/image_slideshow_widget.dart';
import '../widgets/flashcard_viewer_widget.dart';
import '../widgets/quiz_runner_widget.dart';

class LessonReviewPage extends StatelessWidget {
  const LessonReviewPage({
    super.key,
    required this.subjectId,
    required this.curriculumId,
    required this.lessonId,
    this.curriculumName,
    this.publisher,
  });

  final String subjectId;
  final String curriculumId;
  final String lessonId;
  final String? curriculumName;
  final String? publisher;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LessonDetailBloc>(
      create: (_) {
        final bloc = getIt<LessonDetailBloc>();
        final authState = context.read<AuthBloc>().state;
        final studentId = authState is AuthAuthenticated
            ? authState.user.id
            : '';
        bloc.add(
          LessonDetailLoadRequested(lessonId: lessonId, studentId: studentId),
        );
        return bloc;
      },
      child: _LessonReviewView(
        subjectId: subjectId,
        curriculumId: curriculumId,
        lessonId: lessonId,
        curriculumName: curriculumName,
        publisher: publisher,
      ),
    );
  }
}

class _LessonReviewView extends StatefulWidget {
  const _LessonReviewView({
    required this.subjectId,
    required this.curriculumId,
    required this.lessonId,
    this.curriculumName,
    this.publisher,
  });

  final String subjectId;
  final String curriculumId;
  final String lessonId;
  final String? curriculumName;
  final String? publisher;

  @override
  State<_LessonReviewView> createState() => _LessonReviewViewState();
}

class _LessonReviewViewState extends State<_LessonReviewView> {
  int _selectedTabIndex = 0;
  bool _isCompleted = false;

  static const _tabLabels = [
    'Nội dung',
    'Trắc nghiệm',
    'Flashcard',
    'Tổng kết',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LessonDetailBloc, LessonDetailState>(
      listener: _handleStateChanges,
      buildWhen: (prev, curr) =>
          curr is LessonDetailLoading ||
          curr is LessonDetailLoaded ||
          curr is LessonDetailError,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: BackButton(
              onPressed: () => context.go(
                RoutePaths.lessons(widget.subjectId, widget.curriculumId),
                extra: {
                  'curriculumName': widget.curriculumName,
                  'publisher': widget.publisher,
                },
              ),
            ),
            title: Text(_lessonTitle(state), overflow: TextOverflow.ellipsis),
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  String _lessonTitle(LessonDetailState state) {
    if (state is LessonDetailLoaded) return state.lesson.title;
    return 'Ôn tập bài học';
  }

  void _handleStateChanges(BuildContext context, LessonDetailState state) {
    if (state is LessonDetailLoaded) {
      setState(() => _isCompleted = state.isCompleted);
    } else if (state is LessonProgressUpdateSuccess) {
      setState(() => _isCompleted = state.isCompleted);
      if (state.isCompleted) {
        AppToast.success(context, 'Đã đánh dấu hoàn thành');
      } else {
        AppToast.success(context, 'Đã bỏ đánh dấu');
      }
    } else if (state is LessonProgressUpdateFailure) {
      // Revert the toggle on failure
      setState(() => _isCompleted = !_isCompleted);
      AppToast.error(context, 'Không thể cập nhật tiến độ');
    }
  }

  Widget _buildBody(LessonDetailState state) {
    return switch (state) {
      LessonDetailLoading() => const Center(child: CircularProgressIndicator()),
      LessonDetailError(:final message) => _buildError(message),
      LessonDetailLoaded() => _buildLoadedContent(state),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildLoadedContent(LessonDetailLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.mdLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(state.lesson),
          const SizedBox(height: AppSpacing.md),
          _buildProgressToggle(),
          const SizedBox(height: AppSpacing.md),
          _buildTabSwitcher(),
          const SizedBox(height: AppSpacing.md),
          _buildTabContent(state),
        ],
      ),
    );
  }

  Widget _buildHeader(LessonEntity lesson) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lesson.title,
          style: AppTypography.h2.copyWith(
            color: AppColors.foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (lesson.description != null && lesson.description!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            lesson.description!,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressToggle() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _onToggleProgress,
        icon: Icon(
          _isCompleted ? LucideIcons.checkCircle2 : LucideIcons.circle,
          size: 18,
        ),
        label: Text(_isCompleted ? 'Đã học' : 'Đánh dấu học'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isCompleted ? AppColors.success : AppColors.muted,
          foregroundColor: _isCompleted
              ? AppColors.successForeground
              : AppColors.foreground,
          textStyle: AppTypography.buttonMedium,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.smMd),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.borderRadiusSm,
          ),
          elevation: _isCompleted ? 2 : 0,
        ),
      ),
    );
  }

  void _onToggleProgress() {
    final newCompleted = !_isCompleted;
    // Optimistically update the UI
    setState(() => _isCompleted = newCompleted);

    final authState = context.read<AuthBloc>().state;
    final studentId = authState is AuthAuthenticated ? authState.user.id : '';

    context.read<LessonDetailBloc>().add(
      LessonProgressToggleRequested(
        lessonId: widget.lessonId,
        studentId: studentId,
        completed: newCompleted,
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: AppBorders.borderRadiusSm,
      ),
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Row(
        children: List.generate(_tabLabels.length, (index) {
          return Expanded(
            child: _TabButton(
              label: _tabLabels[index],
              isSelected: _selectedTabIndex == index,
              onTap: () => setState(() => _selectedTabIndex = index),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent(LessonDetailLoaded state) {
    return switch (_selectedTabIndex) {
      0 => _buildContentTab(state),
      1 => _buildQuizTab(state),
      2 => _buildFlashcardTab(state),
      3 => _buildSummaryTab(state),
      _ => const SizedBox.shrink(),
    };
  }

  // ─── Content Tab ───
  Widget _buildContentTab(LessonDetailLoaded state) {
    if (state.lesson.content.isEmpty &&
        state.images.isEmpty &&
        state.lesson.vocabulary.isEmpty) {
      return _buildEmptyState('Chưa có nội dung cho bài học này.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image slideshow (if images exist)
        if (state.images.isNotEmpty) ...[
          ImageSlideshowWidget(images: state.images),
          const SizedBox(height: AppSpacing.md),
        ],

        // Content blocks
        if (state.lesson.content.isNotEmpty) ...[
          ContentBlockRenderer(blocks: state.lesson.content),
          const SizedBox(height: AppSpacing.md),
        ],

        // Vocabulary list (if vocabulary items exist)
        if (state.lesson.vocabulary.isNotEmpty) ...[
          const Divider(color: AppColors.border),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Từ vựng',
            style: AppTypography.h4.copyWith(
              color: AppColors.foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...state.lesson.vocabulary.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.smMd),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: AppBorders.borderRadiusSm,
                  border: Border.all(
                    color: AppColors.border,
                    width: AppBorders.widthThin,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.term,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.definition,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ─── Quiz Tab ───
  Widget _buildQuizTab(LessonDetailLoaded state) {
    if (state.lesson.quiz?.isEmpty ?? true) {
      return _buildEmptyState('Chưa có trắc nghiệm cho bài học này.');
    }
    return QuizRunnerWidget(questions: state.lesson.quiz!);
  }

  // ─── Flashcard Tab ───
  Widget _buildFlashcardTab(LessonDetailLoaded state) {
    if (state.lesson.flashcards?.isEmpty ?? true) {
      return _buildEmptyState('Chưa có flashcards cho bài học này.');
    }
    return FlashcardViewerWidget(flashcards: state.lesson.flashcards!);
  }

  // ─── Summary Tab ───
  Widget _buildSummaryTab(LessonDetailLoaded state) {
    final hasSummary =
        state.lesson.summary != null && state.lesson.summary!.isNotEmpty;
    final hasKeyPoints = state.lesson.keyPoints.isNotEmpty;

    if (!hasSummary && !hasKeyPoints) {
      return _buildEmptyState('Chưa có tóm tắt.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary text
        if (hasSummary) ...[
          Text(
            'Tóm tắt',
            style: AppTypography.h4.copyWith(
              color: AppColors.foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.mdLg),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: AppBorders.borderRadiusSm,
              border: Border.all(
                color: AppColors.border,
                width: AppBorders.widthThin,
              ),
            ),
            child: Text(
              state.lesson.summary!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.foreground,
              ),
            ),
          ),
        ],

        // Key points numbered list
        if (hasKeyPoints) ...[
          if (hasSummary) const SizedBox(height: AppSpacing.md),
          Text(
            'Điểm chính',
            style: AppTypography.h4.copyWith(
              color: AppColors.foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...state.lesson.keyPoints.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.smMd),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: AppBorders.borderRadiusSm,
                  border: Border.all(
                    color: AppColors.border,
                    width: AppBorders.widthThin,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppBorders.borderRadiusSm,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primaryForeground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.smMd),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          entry.value,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.foreground,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.bookOpen,
              size: 48,
              color: AppColors.mutedForeground,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: AppColors.destructive,
            ),
            const SizedBox(height: AppSpacing.md),
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
                final authState = context.read<AuthBloc>().state;
                final studentId = authState is AuthAuthenticated
                    ? authState.user.id
                    : '';
                context.read<LessonDetailBloc>().add(
                  LessonDetailLoadRequested(
                    lessonId: widget.lessonId,
                    studentId: studentId,
                  ),
                );
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.card : Colors.transparent,
          borderRadius: AppBorders.borderRadiusSm,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isSelected
                  ? AppColors.foreground
                  : AppColors.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }
}
