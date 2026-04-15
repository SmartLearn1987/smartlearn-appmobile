import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../cubit/notes/notes_cubit.dart';
import '../cubit/tasks/tasks_cubit.dart';
import '../cubit/timetable/timetable_cubit.dart';
import '../widgets/tab_switcher.dart';
import '../widgets/tasks/tasks_tab.dart';
import '../widgets/notes/notes_tab.dart';
import '../widgets/timetable/timetable_tab.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<TimetableCubit>()..loadGroups(),
        ),
        BlocProvider(
          create: (_) => getIt<TasksCubit>()..loadTasks(),
        ),
        BlocProvider(
          create: (_) => getIt<NotesCubit>()..loadNotes(),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thời gian biểu',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Quản lý lịch học, nhiệm vụ và ghi chú của bạn',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TabSwitcher(
                  selectedIndex: _selectedTabIndex,
                  onTabChanged: (index) {
                    setState(() => _selectedTabIndex = index);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildTabContent(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return const TimetableTab(key: ValueKey(0));
      case 1:
        return const TasksTab(key: ValueKey(1));
      case 2:
        return const NotesTab(key: ValueKey(2));
      default:
        return const SizedBox.shrink();
    }
  }
}
