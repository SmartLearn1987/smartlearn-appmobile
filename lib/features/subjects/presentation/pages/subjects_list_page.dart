import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/subjects_list/subjects_list_bloc.dart';
import '../widgets/subject_card_widget.dart';

class SubjectsListPage extends StatelessWidget {
  const SubjectsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SubjectsListBloc>(
      create: (_) =>
          getIt<SubjectsListBloc>()..add(const SubjectsListLoadRequested()),
      child: const _SubjectsListView(),
    );
  }
}

class _SubjectsListView extends StatelessWidget {
  const _SubjectsListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Các môn học',
          style: AppTypography.h3.copyWith(color: AppColors.foreground),
        ),
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
                SubjectsListLoaded(:final subjects) => GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.smMd,
                      mainAxisSpacing: AppSpacing.smMd,
                      childAspectRatio: 1,
                    ),
                    itemCount: subjects.length,
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
}