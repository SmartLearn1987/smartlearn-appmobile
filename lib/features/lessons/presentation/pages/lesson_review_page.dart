import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/theme/theme.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/widgets/app_segmented_tabs.dart';
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
    this.subjectName,
    required this.curriculumId,
    required this.lessonId,
    this.curriculumName,
    this.publisher,
    required this.lessonCount,
  });

  final String subjectId;
  final String? subjectName;
  final String curriculumId;
  final String lessonId;
  final String? curriculumName;
  final String? publisher;
  final int lessonCount;
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
        subjectName: subjectName,
        curriculumId: curriculumId,
        lessonId: lessonId,
        lessonCount: lessonCount,
        curriculumName: curriculumName,
        publisher: publisher,
      ),
    );
  }
}

class _LessonReviewView extends StatefulWidget {
  const _LessonReviewView({
    required this.subjectId,
    this.subjectName,
    required this.curriculumId,
    required this.lessonId,
    this.curriculumName,
    this.publisher,
    required this.lessonCount,
  });

  final String subjectId;
  final String? subjectName;
  final String curriculumId;
  final String lessonId;
  final String? curriculumName;
  final String? publisher;
  final int lessonCount;
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
                  'subjectName': widget.subjectName,
                },
              ),
            ),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: AppSpacing.sm,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        widget.curriculumName ?? '',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: AppBorders.borderRadiusSm,
                      ),
                      child: Text(
                        'Môn: ${widget.subjectName ?? ''}',
                        textAlign: TextAlign.center,
                        style: AppTypography.textXs.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Ôn tập nội dung (${widget.lessonCount} bài)',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          body: _buildBody(state),
        );
      },
    );
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
          Row(
            spacing: AppSpacing.sm,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Expanded(child: _buildHeader(state.lesson))],
          ),
          const SizedBox(height: AppSpacing.md),
          AppSegmentedTabs(
            tabs: _tabLabels,
            selectedIndex: _selectedTabIndex,
            onTap: (index) => setState(() => _selectedTabIndex = index),
          ),
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
        Row(
          spacing: AppSpacing.sm,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                lesson.title,
                style: AppTypography.h2.copyWith(
                  color: AppColors.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _buildProgressToggle(),
          ],
        ),
        if (lesson.description != null && lesson.description!.isNotEmpty)
          Text(
            lesson.description!,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
      ],
    );
  }

  Widget _buildProgressToggle() {
    return ElevatedButton(
      onPressed: _onToggleProgress,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isCompleted ? AppColors.success : AppColors.muted,
        foregroundColor: _isCompleted
            ? AppColors.successForeground
            : AppColors.foreground,
        textStyle: AppTypography.buttonMedium,
        shape: RoundedRectangleBorder(borderRadius: AppBorders.borderRadiusSm),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
        elevation: _isCompleted ? 2 : 0,
      ),
      child: Icon(
        _isCompleted ? LucideIcons.checkCircle2 : LucideIcons.circle,
        size: 18,
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.mdLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('📝 Tổng kết', style: AppTypography.textLg.bold),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    state.lesson.summary!,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        // Key points numbered list
        if (hasKeyPoints) ...[
          if (hasSummary) const SizedBox(height: AppSpacing.md),
          Card(
            color: AppColors.primary.withValues(alpha: 0.05),
            shape: RoundedRectangleBorder(
              borderRadius: AppBorders.borderRadiusSm,
              side: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.1),
                width: AppBorders.widthThin,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.mdLg),
              child: Column(
                spacing: AppSpacing.md,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    spacing: AppSpacing.sm,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.lightbulb,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      Text(
                        'Điểm cần nhớ',
                        style: AppTypography.textLg.bold.withColor(
                          AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  ...state.lesson.keyPoints.asMap().entries.map(
                    (entry) => Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.smMd),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: AppTypography.textSm.copyWith(
                              color: AppColors.foreground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
