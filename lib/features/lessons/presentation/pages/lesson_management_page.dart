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
import '../bloc/lessons_list/lessons_list_bloc.dart';
import '../widgets/lesson_card_widget.dart';

class LessonManagementPage extends StatelessWidget {
  const LessonManagementPage({
    super.key,
    required this.subjectId,
    required this.curriculumId,
    this.curriculumName,
    this.publisher,
  });

  final String subjectId;
  final String curriculumId;
  final String? curriculumName;
  final String? publisher;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LessonsListBloc>(
      create: (_) {
        final bloc = getIt<LessonsListBloc>();
        final authState = context.read<AuthBloc>().state;
        final studentId =
            authState is AuthAuthenticated ? authState.user.id : '';
        bloc.add(LessonsLoadRequested(
          curriculumId: curriculumId,
          studentId: studentId,
        ));
        return bloc;
      },
      child: _LessonManagementView(
        subjectId: subjectId,
        curriculumId: curriculumId,
        curriculumName: curriculumName,
        publisher: publisher,
      ),
    );
  }
}

class _LessonManagementView extends StatefulWidget {
  const _LessonManagementView({
    required this.subjectId,
    required this.curriculumId,
    this.curriculumName,
    this.publisher,
  });

  final String subjectId;
  final String curriculumId;
  final String? curriculumName;
  final String? publisher;

  @override
  State<_LessonManagementView> createState() => _LessonManagementViewState();
}

class _LessonManagementViewState extends State<_LessonManagementView> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LessonsListBloc, LessonsListState>(
      listener: _handleStateChanges,
      buildWhen: (prev, curr) =>
          curr is LessonsListLoading ||
          curr is LessonsListLoaded ||
          curr is LessonsListError,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: BackButton(
              onPressed: () => context.go(
                RoutePaths.subjectDetail(widget.subjectId),
              ),
            ),
            title: Text(
              widget.curriculumName ?? 'Quản lý bài học',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.mdLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(state),
                const SizedBox(height: AppSpacing.md),
                _buildTabSwitcher(),
                const SizedBox(height: AppSpacing.md),
                if (_selectedTabIndex == 0) _buildCreateButton(),
                if (_selectedTabIndex == 0)
                  const SizedBox(height: AppSpacing.md),
                _buildContent(state),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleStateChanges(BuildContext context, LessonsListState state) {
    if (state is LessonDeleteSuccess) {
      AppToast.success(context, 'Đã xóa bài học');
    } else if (state is LessonDeleteFailure) {
      AppToast.error(context, 'Không thể xóa bài học');
    } else if (state is LessonSaveSuccess) {
      AppToast.success(context, 'Đã lưu bài học thành công');
    } else if (state is LessonSaveFailure) {
      AppToast.error(context, state.message);
    }
  }

  Widget _buildHeader(LessonsListState state) {
    final lessonCount = state is LessonsListLoaded ? state.lessons.length : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.curriculumName ?? '',
          style: AppTypography.h2.copyWith(
            color: AppColors.foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            if (widget.publisher != null && widget.publisher!.isNotEmpty) ...[
              _buildSubjectBadge(widget.publisher!),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(
              '$lessonCount bài học',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubjectBadge(String label) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: AppBorders.borderRadiusSm,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.primary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
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
        children: [
          Expanded(
            child: _TabButton(
              label: 'Quản lý bài học',
              isSelected: _selectedTabIndex == 0,
              onTap: () => setState(() => _selectedTabIndex = 0),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Ôn tập',
              isSelected: _selectedTabIndex == 1,
              onTap: () => setState(() => _selectedTabIndex = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.go(
          RoutePaths.lessonForm(widget.subjectId, widget.curriculumId),
          extra: {
            'curriculumName': widget.curriculumName,
            'publisher': widget.publisher,
          },
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryForeground,
          textStyle: AppTypography.buttonMedium,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.smMd),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.borderRadiusSm,
          ),
          elevation: 2,
        ),
        child: const Text('+ Tạo ghi chú mới'),
      ),
    );
  }

  Widget _buildContent(LessonsListState state) {
    return switch (state) {
      LessonsListLoading() => const Center(
          child: Padding(
            padding: EdgeInsets.only(top: AppSpacing.xxl),
            child: CircularProgressIndicator(),
          ),
        ),
      LessonsListError(:final message) => _buildError(message),
      LessonsListLoaded() => _selectedTabIndex == 0
          ? _buildManageTab(state)
          : _buildReviewTab(state),
      _ => const SizedBox.shrink(),
    };
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
                final studentId =
                    authState is AuthAuthenticated ? authState.user.id : '';
                context.read<LessonsListBloc>().add(
                      LessonsLoadRequested(
                        curriculumId: widget.curriculumId,
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

  Widget _buildManageTab(LessonsListLoaded state) {
    if (state.lessons.isEmpty) {
      return _buildEmptyState(
        'Chưa có bài học nào cho giáo trình này.',
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.lessons.length,
      itemBuilder: (context, index) {
        final lesson = state.lessons[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: LessonCardWidget(
            lesson: lesson,
            index: index,
            onEdit: () => context.go(
              RoutePaths.lessonForm(widget.subjectId, widget.curriculumId),
              extra: {
                'curriculumName': widget.curriculumName,
                'publisher': widget.publisher,
                'lessonId': lesson.id,
              },
            ),
            onDelete: () => _showDeleteConfirmation(context, lesson.id),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String lessonId) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa bài học'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa bài học này?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.destructive,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        context
            .read<LessonsListBloc>()
            .add(LessonDeleteRequested(lessonId: lessonId));
      }
    });
  }

  Widget _buildReviewTab(LessonsListLoaded state) {
    if (state.lessons.isEmpty) {
      return _buildEmptyState(
        'Bạn chưa có bài học nào để ôn tập.',
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.lessons.length,
      itemBuilder: (context, index) {
        final lesson = state.lessons[index];
        final isCompleted = state.progressMap[lesson.id] ?? false;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: LessonCardWidget(
            lesson: lesson,
            index: index,
            isReviewMode: true,
            isCompleted: isCompleted,
            onTap: () => context.go(
              RoutePaths.lessonReview(
                widget.subjectId,
                widget.curriculumId,
                lesson.id,
              ),
            ),
          ),
        );
      },
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
            style: AppTypography.labelMedium.copyWith(
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
