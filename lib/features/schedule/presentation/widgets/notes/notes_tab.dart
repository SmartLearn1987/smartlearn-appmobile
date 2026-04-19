import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/theme/app_borders.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/note_item_entity.dart';
import '../../cubit/notes/notes_cubit.dart';
import '../shared/color_picker_widget.dart';
import 'note_add_form.dart';
import 'note_detail_modal.dart';
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
          curr.viewingNote != null && prev.viewingNote != curr.viewingNote,
      listener: (context, state) {
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

                        // Inline edit mode
                        if (state.editingNoteId == note.id) {
                          return _InlineEditCard(note: note);
                        }

                        return NoteItemCard(
                          note: note,
                          onView: () => cubit.setViewingNote(note),
                          onEdit: () => cubit.setEditingNote(note.id),
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

class _InlineEditCard extends StatefulWidget {
  const _InlineEditCard({required this.note});

  final NoteItemEntity note;

  @override
  State<_InlineEditCard> createState() => _InlineEditCardState();
}

class _InlineEditCardState extends State<_InlineEditCard> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late int _selectedColor;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _selectedColor = widget.note.color;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tiêu đề hoặc nội dung'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final updated = NoteItemEntity(
      id: widget.note.id,
      title: title,
      content: content,
      color: _selectedColor,
      updatedAt: DateTime.now(),
    );

    context.read<NotesCubit>().editNote(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu ghi chú'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorders.borderRadiusLg,
        border: Border.all(color: AppColors.primary, width: AppBorders.widthThick),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Color picker
              ColorPickerWidget(
                colors: noteColorsLight,
                selectedIndex: _selectedColor,
                onChanged: (index) => setState(() => _selectedColor = index),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Title
              TextField(
                controller: _titleController,
                style: AppTypography.bodySmall,
                decoration: const InputDecoration(
                  hintText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              // Content
              TextField(
                controller: _contentController,
                maxLines: 3,
                style: AppTypography.bodySmall,
                decoration: const InputDecoration(
                  hintText: 'Nội dung',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 30,
                      child: OutlinedButton(
                        onPressed: () =>
                            context.read<NotesCubit>().setEditingNote(null),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: AppBorders.shapeSm,
                          textStyle: AppTypography.buttonSmall,
                        ),
                        child: const Text('Hủy'),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.primaryForeground,
                          shape: AppBorders.shapeSm,
                          textStyle: AppTypography.buttonSmall,
                        ),
                        child: const Text('Lưu'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
