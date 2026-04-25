import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/theme/app_borders.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../cubit/notes/notes_cubit.dart';
import 'note_add_form.dart';
import 'note_detail_modal.dart';
import 'note_edit_modal.dart';
import 'note_item_card.dart';

class NotesTab extends StatelessWidget {
  const NotesTab({super.key});

  void _showAddModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorders.radiusLg),
        ),
      ),
      builder: (modalContext) => BlocProvider.value(
        value: context.read<NotesCubit>(),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalContext).viewInsets.bottom,
          ),
          child: const SingleChildScrollView(
            child: NoteAddForm(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotesCubit, NotesState>(
      listenWhen: (prev, curr) =>
          (curr.viewingNote != null &&
              prev.viewingNote != curr.viewingNote) ||
          (curr.editingNote != null &&
              prev.editingNote != curr.editingNote),
      listener: (context, state) {
        // View modal
        if (state.viewingNote != null) {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => NoteDetailModal(note: state.viewingNote!),
          ).whenComplete(() {
            if (context.mounted) {
              context.read<NotesCubit>().setViewingNote(null);
            }
          });
        }

        // Edit modal
        if (state.editingNote != null) {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppBorders.radiusLg),
              ),
            ),
            builder: (_) => BlocProvider.value(
              value: context.read<NotesCubit>(),
              child: NoteEditModal(note: state.editingNote!),
            ),
          ).whenComplete(() {
            if (context.mounted) {
              context.read<NotesCubit>().setEditingNote(null);
            }
          });
        }
      },
      builder: (context, state) {
        final cubit = context.read<NotesCubit>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + count badge + Add button
            Row(
              children: [
                Text(
                  'Ghi chú',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
                if (state.notes.isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.sm),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: AppBorders.borderRadiusFull,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      child: Text(
                        '${state.notes.length}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => _showAddModal(context),
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Thêm ghi chú'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: AppBorders.shapeSm,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.smMd),
            // Content
            Expanded(
              child: state.notes.isEmpty
                  ? _EmptyState()
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppSpacing.sm,
                        mainAxisSpacing: AppSpacing.sm,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: state.notes.length,
                      itemBuilder: (context, index) {
                        final note = state.notes[index];
                        return NoteItemCard(
                          note: note,
                          onView: () => cubit.setViewingNote(note),
                          onEdit: () => cubit.setEditingNote(note),
                          onDelete: () {
                            cubit.deleteNote(note.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã xóa ghi chú'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.stickyNote,
            size: 48,
            color: AppColors.mutedForeground,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Chưa có ghi chú nào',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Nhấn Thêm ghi chú để bắt đầu',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
