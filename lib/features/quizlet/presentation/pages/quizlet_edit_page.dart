import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_learn/app/di/injection.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/validators/form_validators.dart';
import 'package:smart_learn/core/widgets/app_dropdown_field.dart';
import 'package:smart_learn/core/widgets/app_text_field.dart';
import 'package:smart_learn/features/quizlet/domain/usecases/delete_quizlet_use_case.dart';
import 'package:smart_learn/features/quizlet/presentation/bloc/quizlet_create/quizlet_create_bloc.dart';
import 'package:smart_learn/features/quizlet/presentation/widgets/card_form_widget.dart';
import 'package:smart_learn/features/quizlet/presentation/widgets/csv_import_dialog.dart';
import 'package:smart_learn/features/subjects/domain/entities/education_level.dart';

class QuizletEditPage extends StatelessWidget {
  final String quizletId;

  const QuizletEditPage({super.key, required this.quizletId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<QuizletCreateBloc>()
        ..add(const LoadSubjects())
        ..add(LoadQuizletForEdit(quizletId)),
      child: const _QuizletEditView(),
    );
  }
}

class _QuizletEditView extends StatefulWidget {
  const _QuizletEditView();

  @override
  State<_QuizletEditView> createState() => _QuizletEditViewState();
}

class _QuizletEditViewState extends State<_QuizletEditView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa học phần')),
      body: SafeArea(
        child: BlocListener<QuizletCreateBloc, QuizletCreateState>(
          listenWhen: (previous, current) =>
              previous.isSuccess != current.isSuccess ||
              previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            if (state.isSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Đã lưu thành công!')));
              if (context.canPop()) {
                context.pop(true);
              } else {
                context.go('/quizlet');
              }
              return;
            }
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
          child: BlocBuilder<QuizletCreateBloc, QuizletCreateState>(
            builder: (context, state) {
              if (state.isLoadingDetail) {
                return const Center(child: CircularProgressIndicator());
              }

              final bloc = context.read<QuizletCreateBloc>();
              return Form(
                key: _formKey,
                child: ListView(
                padding: AppSpacing.paddingMd,
                children: [
                  AppTextField(
                    key: const Key('quizlet_edit_title_field'),
                    initialValue: state.title,
                    label: 'Tiêu đề *',
                    validator: (value) =>
                        FormValidators.required(value, 'Tiêu đề'),
                    onChanged: (value) => bloc.add(UpdateTitle(value)),
                  ),
                  const SizedBox(height: AppSpacing.smMd),
                  AppTextField(
                    initialValue: state.description,
                    label: 'Mô tả',
                    onChanged: (value) => bloc.add(UpdateDescription(value)),
                  ),
                  const SizedBox(height: AppSpacing.smMd),
                  AppDropdownField<bool>(
                    value: state.isPublic,
                    label: 'Chế độ hiển thị',
                    items: const [
                      DropdownMenuItem(
                        value: true,
                        child: Text('Công khai (Tất cả User đều thấy)'),
                      ),
                      DropdownMenuItem(
                        value: false,
                        child: Text('Không công khai (Chỉ mình tôi)'),
                      ),
                    ],
                    onChanged: (value) => value != null
                        ? bloc.add(ToggleVisibility(value))
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.smMd),
                  AppDropdownField<String>(
                    value: state.selectedSubjectId,
                    label: 'Môn học',
                    items: state.subjects
                        .map(
                          (subject) => DropdownMenuItem<String>(
                            value: subject.id,
                            child: Text(subject.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        value != null ? bloc.add(SelectSubject(value)) : null,
                  ),
                  const SizedBox(height: AppSpacing.smMd),
                  AppDropdownField<String>(
                    value: state.educationLevel,
                    label: 'Cấp học',
                    items: EducationLevel.values
                        .map(
                          (level) => DropdownMenuItem<String>(
                            value: level.label,
                            child: Text(level.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => value != null
                        ? bloc.add(SelectEducationLevel(value))
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.smMd),
                  AppTextField(
                    initialValue: state.grade,
                    label: 'Lớp',
                    onChanged: (value) => bloc.add(UpdateGrade(value)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...state.cards.asMap().entries.map(
                    (entry) => CardFormWidget(
                      index: entry.key,
                      data: entry.value,
                      canDelete: state.cards.length > 2,
                      onTermChanged: (value) => bloc.add(
                        UpdateCard(entry.key, value, entry.value.definition),
                      ),
                      onDefinitionChanged: (value) => bloc.add(
                        UpdateCard(entry.key, entry.value.term, value),
                      ),
                      onDelete: () => bloc.add(RemoveCard(entry.key)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => bloc.add(const AddCard()),
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm thẻ'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final csvContent = await showDialog<String>(
                              context: context,
                              builder: (_) => const CsvImportDialog(),
                            );
                            if (csvContent != null && context.mounted) {
                              context.read<QuizletCreateBloc>().add(
                                ImportCards(csvContent),
                              );
                            }
                          },
                          icon: const Icon(Icons.upload_file_outlined),
                          label: const Text('Nhập danh sách'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    key: const Key('save_quizlet_button'),
                    onPressed: state.isSubmitting
                        ? null
                        : () {
                            if (_formKey.currentState?.validate() != true) {
                              return;
                            }
                            bloc.add(const SubmitQuizlet());
                          },
                    child: state.isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Lưu thay đổi'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ElevatedButton.icon(
                    key: const Key('delete_quizlet_button'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.destructive,
                      foregroundColor: AppColors.destructiveForeground,
                    ),
                    onPressed: () async {
                      final confirmDelete = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Xác nhận'),
                          content: const Text(
                            'Bạn có chắc chắn muốn xóa học phần này?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                              child: const Text('Xóa'),
                            ),
                          ],
                        ),
                      );
                      if (confirmDelete != true) {
                        return;
                      }

                      final id = state.quizletId;
                      if (id == null) {
                        return;
                      }
                      final result = await getIt<DeleteQuizletUseCase>()(id);
                      if (!context.mounted) {
                        return;
                      }
                      result.fold(
                        (failure) => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(failure.message)),
                        ),
                        (_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã xóa học phần')),
                          );
                          context.go('/quizlet');
                        },
                      );
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Xóa'),
                  ),
                ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
