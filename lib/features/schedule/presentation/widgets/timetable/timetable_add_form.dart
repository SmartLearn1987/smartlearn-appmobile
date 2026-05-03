import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_borders.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_dropdown_field.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../cubit/timetable/timetable_cubit.dart';
import 'timetable_day_section.dart';

class TimetableAddForm extends StatefulWidget {
  const TimetableAddForm({super.key});

  @override
  State<TimetableAddForm> createState() => _TimetableAddFormState();
}

class _TimetableAddFormState extends State<TimetableAddForm> {
  final _formKey = GlobalKey<FormState>();
  String _selectedDay = dayOrder.first;
  final _subjectController = TextEditingController();
  TimeOfDay _startTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 8, minute: 30);
  final _roomController = TextEditingController();

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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<TimetableCubit>().addEntry(
      day: _selectedDay,
      subject: _subjectController.text.trim(),
      startTime: _formatTime(_startTime),
      endTime: _formatTime(_endTime),
      room: _roomController.text.trim(),
    );
    Navigator.of(context).pop();
    AppToast.success(context, 'Đã thêm môn học');
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thêm môn học mới',
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
                      onPressed: () => Navigator.of(context).pop(),
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
      ),
    );
  }
}

class TimePickerField extends StatelessWidget {
  const TimePickerField({
    required this.label,
    required this.time,
    required this.onTap,
    super.key,
  });

  final String label;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: AppBorders.borderRadiusSm,
              border: Border.all(color: AppColors.input),
            ),
            alignment: Alignment.centerLeft,
            child: Text(time, style: AppTypography.bodyMedium),
          ),
        ),
      ],
    );
  }
}
