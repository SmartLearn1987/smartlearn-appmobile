import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_borders.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/timetable_entry_entity.dart';
import '../../cubit/timetable/timetable_cubit.dart';
import '../shared/color_picker_widget.dart';
import 'timetable_day_section.dart';
import 'timetable_entry_card.dart';

class TimetableEditModal extends StatefulWidget {
  const TimetableEditModal({required this.entry, super.key});

  final TimetableEntryEntity entry;

  @override
  State<TimetableEditModal> createState() => _TimetableEditModalState();
}

class _TimetableEditModalState extends State<TimetableEditModal> {
  late int _selectedDay;
  late TextEditingController _subjectController;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late TextEditingController _roomController;
  late int _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.entry.day;
    _subjectController = TextEditingController(text: widget.entry.subject);
    _startTime = _parseTime(widget.entry.startTime);
    _endTime = _parseTime(widget.entry.endTime);
    _roomController = TextEditingController(text: widget.entry.room);
    _selectedColor = widget.entry.color;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
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
    final subject = _subjectController.text.trim();
    if (subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên môn học'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final updated = TimetableEntryEntity(
      id: widget.entry.id,
      day: _selectedDay,
      subject: subject,
      startTime: _formatTime(_startTime),
      endTime: _formatTime(_endTime),
      room: _roomController.text.trim(),
      color: _selectedColor,
    );

    context.read<TimetableCubit>().editEntry(updated);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã cập nhật môn học'),
        duration: Duration(seconds: 3),
      ),
    );
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            DropdownMenu<int>(
              initialSelection: _selectedDay,
              label: const Text('Thứ'),
              expandedInsets: EdgeInsets.zero,
              dropdownMenuEntries: dayNames.entries
                  .map(
                    (e) => DropdownMenuEntry(
                      value: e.key,
                      label: e.value,
                    ),
                  )
                  .toList(),
              onSelected: (value) {
                if (value != null) setState(() => _selectedDay = value);
              },
            ),
            const SizedBox(height: AppSpacing.smMd),
            // Subject input
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Môn học *',
                hintText: 'VD: Toán, Văn, Anh...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: AppSpacing.smMd),
            // Time pickers row
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickTime(isStart: true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Bắt đầu',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      child: Text(
                        _formatTime(_startTime),
                        style: AppTypography.bodyMedium,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickTime(isStart: false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Kết thúc',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      child: Text(
                        _formatTime(_endTime),
                        style: AppTypography.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.smMd),
            // Room input
            TextField(
              controller: _roomController,
              decoration: const InputDecoration(
                labelText: 'Phòng học',
                hintText: 'VD: P.101, Online...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: AppSpacing.smMd),
            // Color picker
            Text(
              'Màu sắc',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ColorPickerWidget(
              colors: timetableEntryColors,
              selectedIndex: _selectedColor,
              onChanged: (index) => setState(() => _selectedColor = index),
            ),
            const SizedBox(height: AppSpacing.md),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<TimetableCubit>().setEditingEntry(null);
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
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
    );
  }
}
