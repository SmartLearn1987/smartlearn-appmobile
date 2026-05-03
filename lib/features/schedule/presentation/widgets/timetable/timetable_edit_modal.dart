import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_borders.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_dropdown_field.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../domain/entities/timetable_entry_entity.dart';
import '../../cubit/timetable/timetable_cubit.dart';
import 'timetable_add_form.dart';
import 'timetable_day_section.dart';

class TimetableEditModal extends StatefulWidget {
  const TimetableEditModal({required this.entry, super.key});

  final TimetableEntryEntity entry;

  @override
  State<TimetableEditModal> createState() => _TimetableEditModalState();
}

class _TimetableEditModalState extends State<TimetableEditModal> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedDay;
  late TextEditingController _subjectController;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late TextEditingController _roomController;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.entry.day;
    _subjectController = TextEditingController(text: widget.entry.subject);
    _startTime = _parseTime(widget.entry.startTime);
    _endTime = _parseTime(widget.entry.endTime);
    _roomController = TextEditingController(text: widget.entry.room);
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (picked != null && mounted) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final updated = TimetableEntryEntity(
      id: widget.entry.id,
      day: _selectedDay,
      subject: _subjectController.text.trim(),
      startTime: _formatTime(_startTime),
      endTime: _formatTime(_endTime),
      room: _roomController.text.trim(),
    );

    context.read<TimetableCubit>().editEntry(updated);
    Navigator.of(context).pop();
    AppToast.success(context, 'Đã cập nhật môn học');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.mutedForeground,
                    borderRadius: AppBorders.borderRadiusFull,
                  ),
                  child: const SizedBox(width: 40, height: 4),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Sửa môn học',
                style: AppTypography.h4.copyWith(color: AppColors.foreground),
              ),
              const SizedBox(height: AppSpacing.md),
              // Day dropdown
              AppDropdownField<String>(
                label: 'Thứ trong tuần',
                value: _selectedDay,
                items: dayOrder
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedDay = v);
                },
              ),
              const SizedBox(height: AppSpacing.smMd),
              // Subject
              AppTextField(
                controller: _subjectController,
                label: 'Môn học',
                hintText: 'VD: Toán, Văn, Anh...',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Vui lòng nhập tên môn học'
                    : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: AppSpacing.smMd),
              // Time pickers
              Row(
                children: [
                  Expanded(
                    child: TimePickerField(
                      label: 'Bắt đầu',
                      time: _formatTime(_startTime),
                      onTap: () => _pickTime(isStart: true),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TimePickerField(
                      label: 'Kết thúc',
                      time: _formatTime(_endTime),
                      onTap: () => _pickTime(isStart: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.smMd),
              // Room (optional)
              AppTextField(
                controller: _roomController,
                label: 'Phòng học',
                hintText: 'VD: P.101, Online...',
              ),
              const SizedBox(height: AppSpacing.md),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<TimetableCubit>().setEditingEntry(null);
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.destructive,
                        side: const BorderSide(color: AppColors.destructive),
                        shape: AppBorders.shapeSm,
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.primaryForeground,
                        shape: AppBorders.shapeSm,
                      ),
                      child: const Text('Lưu thay đổi'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
