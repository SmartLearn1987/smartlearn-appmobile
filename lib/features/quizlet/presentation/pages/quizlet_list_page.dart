import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/features/auth/presentation/bloc/auth_bloc.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../router/route_names.dart';
import '../bloc/quizlet/quizlet_bloc.dart';
import '../helpers/quizlet_filter_helper.dart';
import '../helpers/quizlet_group_helper.dart';
import '../widgets/quizlet_card_widget.dart';
import '../widgets/view_mode_toggle.dart';

class QuizletListPage extends StatelessWidget {
  const QuizletListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : '';
    final educationLevel = authState is AuthAuthenticated
        ? authState.user.educationLevel
        : null;

    return BlocProvider<QuizletBloc>(
      create: (_) => getIt<QuizletBloc>()
        ..add(SyncUserContext(userId: userId, educationLevel: educationLevel))
        ..add(const LoadQuizlets()),
      child: _QuizletListView(currentUserId: userId),
    );
  }
}

class _QuizletListView extends StatelessWidget {
  final String currentUserId;

  const _QuizletListView({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Flashcards',
          style: AppTypography.h3.copyWith(color: AppColors.foreground),
        ),
      ),
      body: BlocConsumer<QuizletBloc, QuizletState>(
        listenWhen: (previous, current) {
          if (current is QuizletError) {
            return true;
          }
          if (previous is! QuizletLoaded || current is! QuizletLoaded) {
            return false;
          }

          // Only show delete success when the list shrinks without background
          // fetching transitions (e.g. tab switch/refetch), and exactly one item
          // from previous list is removed.
          if (previous.isFetching || current.isFetching) {
            return false;
          }

          if (current.allQuizlets.length != previous.allQuizlets.length - 1) {
            return false;
          }

          final currentIds = current.allQuizlets.map((q) => q.id).toSet();
          final removedCount = previous.allQuizlets
              .where((q) => !currentIds.contains(q.id))
              .length;

          return removedCount == 1;
        },
        listener: (context, state) {
          if (state is QuizletError) {
            final message = state.message == 'Không thể xóa'
                ? 'Không thể xóa học phần'
                : state.message;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
            return;
          }

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đã xóa học phần')));
        },
        builder: (context, state) => switch (state) {
          QuizletLoading() => const Center(child: CircularProgressIndicator()),
          QuizletLoaded() => _LoadedView(
            state: state,
            currentUserId: currentUserId,
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
                    onPressed: () => context.read<QuizletBloc>().add(
                      const RefreshQuizlets(),
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
    );
  }
}

class _LoadedView extends StatelessWidget {
  final QuizletLoaded state;
  final String currentUserId;

  const _LoadedView({required this.state, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final groupedQuizlets = groupQuizletsByLevelAndSubject(
      state.filteredQuizlets,
    );
    final isPersonal = state.viewMode == ViewMode.personal;

    return Stack(
      children: [
        Column(
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
                  ViewModeToggle(
                    value: state.viewMode,
                    onChanged: (mode) =>
                        context.read<QuizletBloc>().add(ChangeViewMode(mode)),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          onChanged: (query) => context.read<QuizletBloc>().add(
                            SearchQuizlets(query),
                          ),
                          hintText: 'Tìm kiếm học phần...',
                          prefixIcon: LucideIcons.search,
                        ),
                      ),
                      if (isPersonal) ...[
                        const SizedBox(width: AppSpacing.sm),
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () async {
                              final shouldRefresh = await context.push<bool>(
                                '/quizlet/create',
                              );
                              if (shouldRefresh == true && context.mounted) {
                                context.read<QuizletBloc>().add(
                                  const RefreshQuizlets(),
                                );
                              }
                            },
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
              child: state.filteredQuizlets.isEmpty
                  ? Center(
                      child: Padding(
                        padding: AppSpacing.paddingMd,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isPersonal
                                  ? 'Bạn chưa tạo học phần nào'
                                  : 'Chưa có bộ flashcard nào',
                              style: AppTypography.bodyLarge.copyWith(
                                color: AppColors.mutedForeground,
                              ),
                            ),
                            if (isPersonal) ...[
                              const SizedBox(height: AppSpacing.sm),
                              TextButton(
                                onPressed: () async {
                                  final shouldRefresh = await context
                                      .push<bool>('/quizlet/create');
                                  if (shouldRefresh == true &&
                                      context.mounted) {
                                    context.read<QuizletBloc>().add(
                                      const RefreshQuizlets(),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Tạo học phần đầu tiên của bạn',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.mdLg,
                        0,
                        AppSpacing.mdLg,
                        AppSpacing.mdLg,
                      ),
                      children: groupedQuizlets.entries.expand((levelEntry) {
                        final widgets = <Widget>[
                          Container(
                            margin: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            padding: const EdgeInsets.only(
                              top: AppSpacing.md,
                              bottom: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
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
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
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
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: Row(
                                spacing: AppSpacing.xs,
                                children: [
                                  Text(
                                    subjectEntry.key,
                                    style: AppTypography.textLg.bold,
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: AppColors.border,
                                    ),
                                  ),
                                  Container(
                                    padding: AppSpacing.paddingSm,
                                    decoration: BoxDecoration(
                                      color: AppColors.gray100,
                                      border: Border.all(
                                        color: AppColors.border,
                                      ),
                                      borderRadius: AppBorders.borderRadiusSm,
                                    ),
                                    child: Text(
                                      '${subjectEntry.value.length} HỌC PHẦN',
                                      style: AppTypography.text2Xs.bold
                                          .withColor(AppColors.mutedForeground),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                          widgets.addAll(
                            subjectEntry.value.map(
                              (quizlet) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.smMd,
                                ),
                                child: QuizletCardWidget(
                                  quizlet: quizlet,
                                  viewMode: state.viewMode,
                                  currentUserId: currentUserId,
                                  onTap: () => context.push(
                                    RoutePaths.quizletDetail(quizlet.id),
                                  ),
                                  onEdit: () async {
                                    final shouldRefresh = await context
                                        .push<bool>(
                                          '/quizlet/edit/${quizlet.id}',
                                        );
                                    if (shouldRefresh == true &&
                                        context.mounted) {
                                      context.read<QuizletBloc>().add(
                                        const RefreshQuizlets(),
                                      );
                                    }
                                  },
                                  onDelete: () async {
                                    final confirmDelete = await showDialog<bool>(
                                      context: context,
                                      builder: (dialogContext) => AlertDialog(
                                        title: const Text('Xác nhận'),
                                        content: const Text(
                                          'Bạn có chắc chắn muốn xóa học phần này?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(
                                              dialogContext,
                                            ).pop(false),
                                            child: const Text('Hủy'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(
                                              dialogContext,
                                            ).pop(true),
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  AppColors.destructive,
                                            ),
                                            child: const Text('Xóa'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirmDelete == true) {
                                      context.read<QuizletBloc>().add(
                                        DeleteQuizlet(quizlet.id),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          );
                        }

                        return widgets;
                      }).toList(),
                    ),
            ),
          ],
        ),
        if (state.isFetching)
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(
                color: AppColors.background.withValues(alpha: 0.6),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
      ],
    );
  }
}
