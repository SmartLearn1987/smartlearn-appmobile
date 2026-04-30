import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_borders.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../cubit/timetable/timetable_cubit.dart';

class GroupSwitcherWidget extends StatefulWidget {
  const GroupSwitcherWidget({super.key});

  @override
  State<GroupSwitcherWidget> createState() => _GroupSwitcherWidgetState();
}

class _GroupSwitcherWidgetState extends State<GroupSwitcherWidget> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimetableCubit, TimetableState>(
      buildWhen: (prev, curr) =>
          prev.groups != curr.groups ||
          prev.selectedGroupIndex != curr.selectedGroupIndex ||
          prev.isAddingGroup != curr.isAddingGroup,
      builder: (context, state) {
        return SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...List.generate(state.groups.length, (index) {
                final group = state.groups[index];
                final isSelected = index == state.selectedGroupIndex;

                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () =>
                        context.read<TimetableCubit>().selectGroup(index),
                    onLongPress: () => _showDeleteDialog(context, group.id),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.card,
                        borderRadius: AppBorders.borderRadiusFull,
                        border: isSelected
                            ? null
                            : Border.all(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Center(
                          child: Text(
                            group.name,
                            style: AppTypography.labelSmall.copyWith(
                              color: isSelected
                                  ? AppColors.primaryForeground
                                  : AppColors.foreground,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              if (state.isAddingGroup)
                _buildInlineInput(context)
              else
                _buildAddButton(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<TimetableCubit>().toggleAddGroup(),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppBorders.borderRadiusFull,
          border: Border.all(color: AppColors.border),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.smMd),
          child: Center(
            child: Icon(Icons.add, size: 18, color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildInlineInput(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 180,
      child: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _nameController,
                autofocus: true,
                style: AppTypography.labelSmall,
                decoration: const InputDecoration(
                  hintText: 'Tên nhóm mới',
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            GestureDetector(
              onTap: () {
                final cubit = context.read<TimetableCubit>();
                final name = _nameController.text;
                if (name.trim().isEmpty) {
                  AppToast.error(context, 'Vui lòng nhập tên loại');
                  return;
                }
                cubit.addGroup(name);
                _nameController.clear();
                AppToast.success(context, 'Đã thêm loại thời khóa biểu mới');
              },
              child: const Icon(
                Icons.check,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            GestureDetector(
              onTap: () {
                _nameController.clear();
                context.read<TimetableCubit>().toggleAddGroup();
              },
              child: const Icon(
                Icons.close,
                size: 18,
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String groupId) {
    final cubit = context.read<TimetableCubit>();
    final group = cubit.state.groups.firstWhere((g) => g.id == groupId);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa nhóm'),
        content: Text('Bạn có chắc muốn xóa nhóm "${group.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (cubit.state.groups.length <= 1) {
                AppToast.error(context, 'Không thể xóa nhóm cuối cùng');
                return;
              }
              cubit.deleteGroup(groupId);
              AppToast.success(context, 'Đã xóa nhóm thời khóa biểu');
            },
            child: Text('Xóa', style: TextStyle(color: AppColors.destructive)),
          ),
        ],
      ),
    );
  }
}
