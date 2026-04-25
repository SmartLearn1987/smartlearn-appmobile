import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_learn/app/di/injection.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/features/quizlet/presentation/bloc/quizlet_create/quizlet_create_bloc.dart';
import 'package:smart_learn/features/quizlet/presentation/widgets/card_form_widget.dart';
import 'package:smart_learn/features/quizlet/presentation/widgets/csv_import_dialog.dart';
import 'package:smart_learn/features/subjects/domain/entities/education_level.dart';

class QuizletCreatePage extends StatelessWidget {
  const QuizletCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<QuizletCreateBloc>()..add(const LoadSubjects()),
      child: const _QuizletCreateView(),
    );
  }
}

class _QuizletCreateView extends StatelessWidget {
  const _QuizletCreateView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo học phần')),
      body: BlocListener<QuizletCreateBloc, QuizletCreateState>(
        listenWhen: (previous, current) =>
            previous.isSuccess != current.isSuccess ||
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã tạo học phần thành công!')),
            );
            context.go('/quizlet');
            return;
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        child: BlocBuilder<QuizletCreateBloc, QuizletCreateState>(
          builder: (context, state) {
            final bloc = context.read<QuizletCreateBloc>();
            return ListView(
              padding: AppSpacing.paddingMd,
              children: [
                TextFormField(
                  key: const Key('quizlet_title_field'),
                  initialValue: state.title,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề *',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => bloc.add(UpdateTitle(value)),
                ),
                const SizedBox(height: AppSpacing.smMd),
                TextFormField(
                  key: const Key('quizlet_description_field'),
                  initialValue: state.description,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => bloc.add(UpdateDescription(value)),
                ),
                const SizedBox(height: AppSpacing.smMd),
                DropdownButtonFormField<bool>(
                  key: const Key('quizlet_visibility_field'),
                  initialValue: state.isPublic,
                  decoration: const InputDecoration(
                    labelText: 'Chế độ hiển thị',
                    border: OutlineInputBorder(),
                  ),
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
                  onChanged: (value) =>
                      value != null ? bloc.add(ToggleVisibility(value)) : null,
                ),
                const SizedBox(height: AppSpacing.smMd),
                DropdownButtonFormField<String>(
                  key: const Key('quizlet_subject_field'),
                  initialValue: state.selectedSubjectId,
                  decoration: const InputDecoration(
                    labelText: 'Môn học',
                    border: OutlineInputBorder(),
                  ),
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
                DropdownButtonFormField<String>(
                  key: const Key('quizlet_education_level_field'),
                  initialValue: state.educationLevel,
                  decoration: const InputDecoration(
                    labelText: 'Cấp học',
                    border: OutlineInputBorder(),
                  ),
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
                TextFormField(
                  key: const Key('quizlet_grade_field'),
                  initialValue: state.grade,
                  decoration: const InputDecoration(
                    labelText: 'Lớp',
                    border: OutlineInputBorder(),
                  ),
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
                  key: const Key('submit_quizlet_button'),
                  onPressed: state.isSubmitting
                      ? null
                      : () => bloc.add(const SubmitQuizlet()),
                  child: state.isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Tạo và ôn luyện'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
