import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../router/route_names.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/curriculum_entity.dart';
import '../bloc/subject_detail/subject_detail_bloc.dart';
import '../widgets/curriculum_card_widget.dart';
import '../widgets/curriculum_group_header.dart';
import '../widgets/delete_confirmation_dialog.dart';

class SubjectDetailPage extends StatefulWidget {
  const SubjectDetailPage({required this.subjectId, super.key});

  final String subjectId;

  @override
  State<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<SubjectDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<SubjectDetailBloc>().add(
      SubjectDetailLoadRequested(subjectId: widget.subjectId),
    );
  }

  @override
  void didUpdateWidget(covariant SubjectDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subjectId != widget.subjectId) {
      context.read<SubjectDetailBloc>().add(
        SubjectDetailLoadRequested(subjectId: widget.subjectId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SubjectDetailView(subjectId: widget.subjectId);
  }
}

class _SubjectDetailView extends StatelessWidget {
  const _SubjectDetailView({required this.subjectId});

  final String subjectId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubjectDetailBloc, SubjectDetailState>(
      listener: _handleStateChanges,
      buildWhen: (prev, curr) =>
          curr is SubjectDetailLoading ||
          curr is SubjectDetailLoaded ||
          curr is SubjectDetailError,
      builder: (context, state) => switch (state) {
        SubjectDetailLoading() => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
          body: const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
        SubjectDetailLoaded() => _buildContent(context, state),
        SubjectDetailError(:final message) => _buildErrorScaffold(
          context,
          message,
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }

  void _handleStateChanges(BuildContext context, SubjectDetailState state) {
    if (state is CurriculumDeleteSuccess) {
      AppToast.success(context, 'Đã xóa giáo trình');
    } else if (state is CurriculumDeleteFailure) {
      AppToast.error(context, 'Không thể xóa giáo trình');
    }
  }

  Widget _buildContent(BuildContext context, SubjectDetailLoaded state) {
    final subject = state.subject;
    final grouped = state.groupedCurricula;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(subject.name, overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.mdLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSubjectHeader(
              subject.icon,
              subject.name,
              subject.description,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildCreateButton(context, subject.name),
            const SizedBox(height: AppSpacing.md),
            if (grouped.isEmpty)
              _buildEmptyState()
            else
              _buildGroupedList(context, grouped, subject.name),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectHeader(String? icon, String name, String? description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) Text(icon, style: const TextStyle(fontSize: 40)),
            if (icon != null) const SizedBox(width: AppSpacing.md),
            Text(
              name,
              style: AppTypography.h1.copyWith(
                color: AppColors.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCreateButton(BuildContext context, String subjectName) {
    final isAuthenticated = context.read<AuthBloc>().state is AuthAuthenticated;
    if (!isAuthenticated) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.push(
          RoutePaths.createCurriculum(subjectId),
          extra: {'subjectName': subjectName},
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
        child: const Text('+ Tạo giáo trình mới'),
      ),
    );
  }

  Widget _buildEmptyState() {
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
              'Chưa có giáo trình nào do bạn tạo cho môn học này.',
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

  Widget _buildGroupedList(
    BuildContext context,
    Map<String, List<CurriculumEntity>> grouped,
    String subjectName,
  ) {
    final children = <Widget>[];
    for (final entry in grouped.entries) {
      children.add(
        CurriculumGroupHeader(label: entry.key, count: entry.value.length),
      );
      for (var i = 0; i < entry.value.length; i++) {
        final curriculum = entry.value[i];
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: CurriculumCardWidget(
              curriculum: curriculum,
              index: i,
              onManageLessons: () => context.push(
                RoutePaths.lessons(subjectId, curriculum.id),
                extra: {
                  'curriculumName': curriculum.name,
                  'publisher': curriculum.publisher,
                  'subjectName': subjectName,
                },
              ),
              onEdit: () => context.push(
                RoutePaths.editCurriculum(subjectId, curriculum.id),
                extra: {'subjectName': subjectName},
              ),
              onDelete: () => _showDeleteConfirmation(context, curriculum),
            ),
          ),
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    CurriculumEntity curriculum,
  ) {
    DeleteConfirmationDialog.show(
      context,
      onConfirm: () {
        context.read<SubjectDetailBloc>().add(
          CurriculumDeleteRequested(curriculumId: curriculum.id),
        );
      },
    );
  }

  Widget _buildErrorScaffold(BuildContext context, String message) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.mdLg),
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
                onPressed: () => context.read<SubjectDetailBloc>().add(
                  SubjectDetailLoadRequested(subjectId: subjectId),
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
