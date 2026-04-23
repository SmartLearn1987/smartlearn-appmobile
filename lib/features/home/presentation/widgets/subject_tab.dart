import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';
import 'package:smart_learn/features/home/presentation/bloc/home_bloc.dart';
import 'package:smart_learn/features/home/presentation/widgets/home_subject_grid.dart';
import 'package:smart_learn/router/route_names.dart';

class SubjectTab extends StatelessWidget {
  const SubjectTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is HomeError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Text(
                    state.message,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.destructive,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<HomeBloc>().add(const HomeLoadSubjects()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.primaryForeground,
                    ),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is HomeLoaded) {
          final hasSubjects = state.subjects.isNotEmpty;

          if (!hasSubjects) {
            return _buildEmptyState(context);
          }

          return _buildSubjectList(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.sparkles,
                size: 20,
                color: AppColors.secondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Các môn học',
                style: AppTypography.h3.copyWith(
                  color: AppColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Lưu trữ thông minh – Ghi nhớ sâu',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Center(
            child: Column(
              children: [
                Text(
                  'Bạn chưa chọn môn học nào để đưa vào sổ tay.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: () => context.go(RoutePaths.subjects),
                  child: Text(
                    'Bấm vào đây để cấu hình Thiết định môn học nhé',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectList(BuildContext context, HomeLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.mdLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.sparkles,
                    size: 20,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Các môn học',
                    style: AppTypography.h3.copyWith(
                      color: AppColors.foreground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Lưu trữ thông minh – Ghi nhớ sâu',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        HomeSubjectGrid(subjects: state.subjects),
      ],
    );
  }
}
