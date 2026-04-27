import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../router/route_names.dart';
import '../../domain/entities/exam_entity.dart';
import '../../domain/repositories/exam_repository.dart';
import '../bloc/exam/exam_bloc.dart';
import '../helpers/exam_group_helper.dart';
import '../widgets/exam_card_widget.dart';
import '../widgets/exam_tab_toggle.dart';

class ExamListPage extends StatelessWidget {
  const ExamListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExamBloc>(
      create: (_) =>
          getIt<ExamBloc>()..add(const LoadExams(tab: ExamTab.communityApi)),
      child: const _ExamListView(),
    );
  }
}

class _ExamListView extends StatefulWidget {
  const _ExamListView();

  @override
  State<_ExamListView> createState() => _ExamListViewState();
}

class _ExamListViewState extends State<_ExamListView> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  ExamTab _tab = ExamTab.community;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _fetchExams({bool isRefresh = false}) {
    final event = isRefresh
        ? RefreshExams(tab: _tab.apiValue, search: _searchController.text)
        : LoadExams(tab: _tab.apiValue, search: _searchController.text);
    context.read<ExamBloc>().add(event);
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), _fetchExams);
  }

  Future<void> _openExamForm({String? examId}) async {
    final shouldRefresh = await context.push<bool>(
      examId == null ? RoutePaths.examCreate : RoutePaths.examEdit(examId),
    );
    if (shouldRefresh == true && mounted) {
      _fetchExams(isRefresh: true);
    }
  }

  Future<void> _deleteExam(String examId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn xóa bài trắc nghiệm này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    final result = await getIt<ExamRepository>().deleteExam(examId);
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã xóa bài thi')));
        _fetchExams(isRefresh: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPersonal = _tab == ExamTab.personal;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Trắc Nghiệm',
          style: AppTypography.h3.copyWith(color: AppColors.foreground),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.mdLg,
              AppSpacing.md,
              AppSpacing.mdLg,
              AppSpacing.sm,
            ),
            child: Column(
              children: [
                ExamTabToggle(
                  value: _tab,
                  onChanged: (tab) {
                    setState(() => _tab = tab);
                    _fetchExams();
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        hintText: 'Tìm kiếm bài thi...',
                        prefixIcon: LucideIcons.search,
                      ),
                    ),
                    if (isPersonal) ...[
                      const SizedBox(width: AppSpacing.sm),
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () => _openExamForm(),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: AppBorders.shapeSm,
                          ),
                          child: const Icon(LucideIcons.plus),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ExamBloc, ExamState>(
              builder: (context, state) => switch (state) {
                ExamLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                ExamLoaded(:final exams) =>
                  exams.isEmpty
                      ? Center(
                          child: Padding(
                            padding: AppSpacing.paddingMd,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.clipboardList,
                                  size: AppSpacing.huge,
                                  color: AppColors.mutedForeground,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  isPersonal
                                      ? 'Bạn chưa tạo bài trắc nghiệm nào'
                                      : 'Chưa có bài trắc nghiệm cộng đồng',
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: AppColors.mutedForeground,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : _GroupedExamList(
                          exams: exams,
                          isPersonal: isPersonal,
                          onEdit: (examId) => _openExamForm(examId: examId),
                          onDelete: _deleteExam,
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
                          onPressed: () => _fetchExams(isRefresh: true),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                ),
                _ => const SizedBox.shrink(),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupedExamList extends StatelessWidget {
  const _GroupedExamList({
    required this.exams,
    required this.isPersonal,
    required this.onEdit,
    required this.onDelete,
  });

  final List<ExamEntity> exams;
  final bool isPersonal;
  final Future<void> Function(String examId) onEdit;
  final Future<void> Function(String examId) onDelete;

  @override
  Widget build(BuildContext context) {
    final groupedExams = groupExamsByLevelAndSubject(exams);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.mdLg,
        AppSpacing.xs,
        AppSpacing.mdLg,
        AppSpacing.mdLg,
      ),
      children: groupedExams.entries.expand((levelEntry) {
        final widgets = <Widget>[
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.only(
              top: AppSpacing.md,
              bottom: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: AppBorders.widthThin,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    size: 16,
                    LucideIcons.layers,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  levelEntry.key,
                  style: AppTypography.text2Xl.bold.withColor(
                    AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ];

        for (final subjectEntry in levelEntry.value.entries) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                spacing: AppSpacing.xs,
                children: [
                  Text(subjectEntry.key, style: AppTypography.textLg.bold),
                  Expanded(
                    child: Container(height: 1, color: AppColors.border),
                  ),
                  Container(
                    padding: AppSpacing.paddingSm,
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      border: Border.all(color: AppColors.border),
                      borderRadius: AppBorders.borderRadiusSm,
                    ),
                    child: Text(
                      '${subjectEntry.value.length} BÀI TRẮC NGHIỆM',
                      style: AppTypography.text2Xs.bold.withColor(
                        AppColors.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
          widgets.addAll(
            subjectEntry.value.map(
              (exam) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.smMd),
                child: ExamCardWidget(
                  exam: exam,
                  isPersonal: isPersonal,
                  onEdit: () => onEdit(exam.id),
                  onDelete: () => onDelete(exam.id),
                ),
              ),
            ),
          );
        }
        return widgets;
      }).toList(),
    );
  }
}
