import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/presentation/widgets/subject_selection_modal.dart';
import '../bloc/subjects_list/subjects_list_bloc.dart';
import '../widgets/subject_card_widget.dart';

class SubjectsListPage extends StatefulWidget {
  const SubjectsListPage({super.key});

  @override
  State<SubjectsListPage> createState() => _SubjectsListPageState();
}

class _SubjectsListPageState extends State<SubjectsListPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh whenever this page becomes visible (e.g. switching tabs).
    context
        .read<SubjectsListBloc>()
        .add(const SubjectsListRefreshRequested());
  }

  void _openSelectionModal(List<String> currentIds) {
    SubjectSelectionModal.show(
      context,
      currentSubjectIds: currentIds,
    ).then((saved) {
      if (saved == true && mounted) {
        context
            .read<SubjectsListBloc>()
            .add(const SubjectsListRefreshRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Các môn học',
          style: AppTypography.h3.copyWith(color: AppColors.foreground),
        ),
        actions: [
          BlocBuilder<SubjectsListBloc, SubjectsListState>(
            buildWhen: (prev, curr) =>
                curr is SubjectsListLoaded || curr is SubjectsListLoading,
            builder: (context, state) {
              if (state is SubjectsListLoaded && state.subjects.isNotEmpty) {
                return IconButton(
                  icon: const Icon(
                    LucideIcons.settings,
                    size: 20,
                    color: AppColors.mutedForeground,
                  ),
                  onPressed: () => _openSelectionModal(
                    state.subjects.map((s) => s.subject.id).toList(),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.mdLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ghi chép, lưu trữ bài học của bạn, giúp ôn tập tốt hơn!',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            BlocBuilder<SubjectsListBloc, SubjectsListState>(
              builder: (context, state) => switch (state) {
                SubjectsListLoading() => const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: AppSpacing.xxl),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                SubjectsListLoaded(:final subjects) => subjects.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: subjects.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.smMd),
                        itemBuilder: (context, index) {
                          final item = subjects[index];
                          return SubjectCardWidget(subjectWithCount: item);
                        },
                      ),
                SubjectsListError(:final message) => Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xxl),
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
                            onPressed: () =>
                                context.read<SubjectsListBloc>().add(
                                      const SubjectsListLoadRequested(),
                                    ),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  ),
                _ => const SizedBox.shrink(),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xxl),
        child: Column(
          children: [
            Icon(
              LucideIcons.bookOpen,
              size: 48,
              color: AppColors.mutedForeground.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Bạn chưa chọn môn học nào',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => _openSelectionModal(const []),
              icon: const Icon(LucideIcons.settings, size: 18),
              label: const Text('Thiết lập môn học'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                textStyle: AppTypography.buttonLarge,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.smMd,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
