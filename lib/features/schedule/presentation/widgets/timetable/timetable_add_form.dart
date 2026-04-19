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

class TimetableAddForm extends StatefulWidget {
  const TimetableAddForm({super.key});

  @override
  State<TimetableAddForm> createState() => _TimetableAddFormState();
}

class _TimetableAddFormState extends State<TimetableAddForm> {
  int _selectedDay = 2;
  final _subjectController = TextEditingController();
  TimeOfDay _startTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 8, minute: 30);
  final _roomController = TextEditingController();
  int _selectedColor = 0;

  @override
  void dispose() {
    _subjectController.dispose();
    _roomController.dispose();
    super.dispose();
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

  void _submit() {
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

    final entry = TimetableEntryEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      day: _selectedDay,
      subject: subject,
      startTime: _formatTime(_startTime),
      endTime: _formatTime(_endTime),
      room: _roomController.text.trim(),
      color: _selectedColor,
    );

    context.read<TimetableCubit>().addEntry(entry);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã thêm môn học'),
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
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thêm môn học mới',
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
                  child: _TimePicker(
                    label: 'Bắt đầu',
                    time: _formatTime(_startTime),
                    onTap: () => _pickTime(isStart: true),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _TimePicker(
                    label: 'Kết thúc',
                    time: _formatTime(_endTime),
                    onTap: () => _pickTime(isStart: false),
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
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      shape: AppBorders.shapeSm,
                    ),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.primaryForeground,
                      shape: AppBorders.shapeSm,
                    ),
                    child: const Text('Thêm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  const _TimePicker({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        child: Text(time, style: AppTypography.bodyMedium),
      ),
    );
  }
}
