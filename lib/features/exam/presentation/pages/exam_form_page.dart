import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/app/di/injection.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/core/validators/form_validators.dart';
import 'package:smart_learn/core/widgets/app_dropdown_field.dart';
import 'package:smart_learn/core/widgets/app_text_field.dart';
import 'package:smart_learn/features/exam/domain/repositories/exam_repository.dart';
import 'package:smart_learn/features/home/domain/entities/subject_entity.dart';
import 'package:smart_learn/features/subjects/domain/entities/education_level.dart';
import 'package:smart_learn/features/subjects/domain/usecases/get_subjects_use_case.dart';

class ExamFormPage extends StatefulWidget {
  const ExamFormPage({super.key, this.examId});

  final String? examId;

  bool get isEdit => examId != null;

  @override
  State<ExamFormPage> createState() => _ExamFormPageState();
}

class _ExamFormPageState extends State<ExamFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _gradeController = TextEditingController();
  final _durationController = TextEditingController(text: '30');

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isPublic = false;
  String? _selectedSubjectId;
  String? _educationLevel;
  List<SubjectEntity> _subjects = const [];
  List<_QuestionDraft> _questions = [_QuestionDraft.singleDefault()];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _gradeController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() => _isLoading = true);
    await _loadSubjects();
    if (widget.isEdit) {
      await _loadExamForEdit(widget.examId!);
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSubjects() async {
    final result = await getIt<GetSubjectsUseCase>()(const NoParams());
    if (!mounted) return;
    result.fold(
      (_) => _subjects = const [],
      (subjects) => _subjects = subjects,
    );
  }

  Future<void> _loadExamForEdit(String examId) async {
    final result = await getIt<ExamRepository>().getExamDetail(examId);
    if (!mounted) return;
    result.fold(
      (failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
        context.pop(false);
      },
      (detail) {
        _titleController.text = detail.title;
        _descriptionController.text = detail.description ?? '';
        _durationController.text = detail.duration.toString();
        _selectedSubjectId = detail.subjectId;
        _educationLevel = detail.educationLevel;
        _gradeController.text = detail.grade ?? '';
        _isPublic = detail.isPublic ?? false;
        _questions = detail.questions
            .map(
              (question) => _QuestionDraft(
                content: question.content,
                type: _normalizeQuestionType(question.type),
                options: question.options
                    .map(
                      (option) => _OptionDraft(
                        content: option.content,
                        isCorrect: option.isCorrect,
                      ),
                    )
                    .toList(),
              ),
            )
            .toList();
        if (_questions.isEmpty) {
          _questions = [_QuestionDraft.singleDefault()];
        }
      },
    );
  }

  String _normalizeQuestionType(String type) {
    const allowed = {'single', 'multiple', 'text', 'ordering'};
    return allowed.contains(type) ? type : 'single';
  }

  void _addQuestion() {
    setState(
      () => _questions = [..._questions, _QuestionDraft.singleDefault()],
    );
  }

  void _removeQuestion(int index) {
    if (_questions.length <= 1) return;
    final updated = [..._questions]..removeAt(index);
    setState(() => _questions = updated);
  }

  void _updateQuestion(
    int index, {
    String? content,
    String? type,
    List<_OptionDraft>? options,
  }) {
    final updated = [..._questions];
    final current = updated[index];
    updated[index] = current.copyWith(
      content: content ?? current.content,
      type: type ?? current.type,
      options: options ?? current.options,
    );
    setState(() => _questions = updated);
  }

  void _addOption(int questionIndex) {
    final question = _questions[questionIndex];
    _updateQuestion(
      questionIndex,
      options: [
        ...question.options,
        const _OptionDraft(content: ''),
      ],
    );
  }

  void _removeOption(int questionIndex, int optionIndex) {
    final question = _questions[questionIndex];
    if (question.options.length <= 1) return;
    final updatedOptions = [...question.options]..removeAt(optionIndex);
    _updateQuestion(questionIndex, options: updatedOptions);
  }

  void _toggleOptionCorrect(int questionIndex, int optionIndex) {
    final question = _questions[questionIndex];
    final updatedOptions = [...question.options];
    if (question.type == 'single') {
      for (var i = 0; i < updatedOptions.length; i++) {
        updatedOptions[i] = updatedOptions[i].copyWith(
          isCorrect: i == optionIndex,
        );
      }
    } else {
      updatedOptions[optionIndex] = updatedOptions[optionIndex].copyWith(
        isCorrect: !updatedOptions[optionIndex].isCorrect,
      );
    }
    _updateQuestion(questionIndex, options: updatedOptions);
  }

  Map<String, dynamic> _buildPayload() {
    final duration = int.tryParse(_durationController.text.trim()) ?? 30;
    final normalizedQuestions = _questions.map((question) {
      final type = question.type;
      final isTextual = type == 'text' || type == 'ordering';
      final options = isTextual
          ? [
              {
                'content': question.options.isEmpty
                    ? ''
                    : question.options.first.content.trim(),
                'is_correct': true,
              },
            ]
          : question.options
                .where((option) => option.content.trim().isNotEmpty)
                .map(
                  (option) => {
                    'content': option.content.trim(),
                    'is_correct': option.isCorrect,
                  },
                )
                .toList();

      return {
        'content': question.content.trim().isEmpty
            ? 'Câu hỏi không tên'
            : question.content.trim(),
        'type': type,
        'options': options,
      };
    }).toList();

    return {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'duration': duration,
      'subject_id': _selectedSubjectId,
      'education_level': _educationLevel,
      'grade': _gradeController.text.trim().isEmpty
          ? null
          : _gradeController.text.trim(),
      'is_public': _isPublic,
      'questions': normalizedQuestions,
    };
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_selectedSubjectId == null || _selectedSubjectId!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn môn học')));
      return;
    }
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm ít nhất một câu hỏi')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final payload = _buildPayload();
    final repo = getIt<ExamRepository>();
    final result = widget.isEdit
        ? await repo.updateExam(widget.examId!, payload)
        : await repo.createExam(payload);

    if (!mounted) return;
    setState(() => _isSaving = false);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEdit
                  ? 'Đã cập nhật bài thi'
                  : 'Đã tạo bài thi thành công',
            ),
          ),
        );
        context.pop(true);
      },
    );
  }

  Future<void> _deleteExam() async {
    if (!widget.isEdit) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn xóa bài trắc nghiệm này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isSaving = true);
    final result = await getIt<ExamRepository>().deleteExam(widget.examId!);
    if (!mounted) return;
    setState(() => _isSaving = false);
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã xóa bài thi')));
        context.pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit ? 'Chỉnh sửa bài trắc nghiệm' : 'Tạo bài trắc nghiệm',
        ),
        actions: [
          if (widget.isEdit)
            IconButton(
              icon: const Icon(LucideIcons.trash2),
              onPressed: _isSaving ? null : _deleteExam,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: AppSpacing.paddingMd,
                  children: [
                    AppTextField(
                      controller: _titleController,
                      label: 'Tên bài thi *',
                      validator: (value) =>
                          FormValidators.required(value, 'Tên bài thi'),
                    ),
                    const SizedBox(height: AppSpacing.smMd),
                    AppTextField(
                      controller: _descriptionController,
                      label: 'Mô tả',
                      minLines: 3,
                      maxLines: 4,
                    ),
                    const SizedBox(height: AppSpacing.smMd),
                    AppTextField(
                      controller: _durationController,
                      label: 'Thời gian (phút)',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppSpacing.smMd),
                    AppDropdownField<bool>(
                      value: _isPublic,
                      label: 'Chế độ hiển thị',
                      items: const [
                        DropdownMenuItem(value: true, child: Text('Công khai')),
                        DropdownMenuItem(
                          value: false,
                          child: Text('Không công khai'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _isPublic = value);
                      },
                    ),
                    const SizedBox(height: AppSpacing.smMd),
                    AppDropdownField<String>(
                      value: _selectedSubjectId,
                      label: 'Môn học',
                      items: _subjects
                          .map(
                            (subject) => DropdownMenuItem<String>(
                              value: subject.id,
                              child: Text(subject.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedSubjectId = value),
                    ),
                    const SizedBox(height: AppSpacing.smMd),
                    AppDropdownField<String>(
                      value: _educationLevel,
                      label: 'Cấp học',
                      items: EducationLevel.values
                          .map(
                            (level) => DropdownMenuItem<String>(
                              value: level.label,
                              child: Text(level.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _educationLevel = value),
                    ),
                    const SizedBox(height: AppSpacing.smMd),
                    AppTextField(controller: _gradeController, label: 'Lớp'),
                    const SizedBox(height: AppSpacing.lg),
                    ..._questions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final question = entry.value;
                      final isTextual =
                          question.type == 'text' ||
                          question.type == 'ordering';

                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Padding(
                          padding: AppSpacing.paddingMd,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('Câu ${index + 1}'),
                                  const Spacer(),
                                  DropdownButton<String>(
                                    value: question.type,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'single',
                                        child: Text('Một đáp án'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'multiple',
                                        child: Text('Nhiều đáp án'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'text',
                                        child: Text('Nhập văn bản'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'ordering',
                                        child: Text('Sắp xếp câu'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value == null) return;
                                      final updatedOptions =
                                          (value == 'text' ||
                                              value == 'ordering')
                                          ? [
                                              _OptionDraft(
                                                content:
                                                    question.options.isEmpty
                                                    ? ''
                                                    : question
                                                          .options
                                                          .first
                                                          .content,
                                                isCorrect: true,
                                              ),
                                            ]
                                          : (question.options.isEmpty
                                                ? const [
                                                    _OptionDraft(
                                                      content: 'Lựa chọn 1',
                                                      isCorrect: true,
                                                    ),
                                                  ]
                                                : question.options);
                                      _updateQuestion(
                                        index,
                                        type: value,
                                        options: updatedOptions,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    onPressed: _questions.length <= 1
                                        ? null
                                        : () => _removeQuestion(index),
                                    icon: const Icon(LucideIcons.trash2),
                                  ),
                                ],
                              ),
                              AppTextField(
                                initialValue: question.content,
                                hintText: 'Nhập câu hỏi',
                                onChanged: (value) =>
                                    _updateQuestion(index, content: value),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              if (isTextual)
                                AppTextField(
                                  initialValue: question.options.isEmpty
                                      ? ''
                                      : question.options.first.content,
                                  label: question.type == 'ordering'
                                      ? 'Nội dung câu đúng'
                                      : 'Đáp án đúng',
                                  onChanged: (value) {
                                    _updateQuestion(
                                      index,
                                      options: [
                                        _OptionDraft(
                                          content: value,
                                          isCorrect: true,
                                        ),
                                      ],
                                    );
                                  },
                                )
                              else ...[
                                ...question.options.asMap().entries.map((
                                  optionEntry,
                                ) {
                                  final optionIndex = optionEntry.key;
                                  final option = optionEntry.value;
                                  return Row(
                                    children: [
                                      Checkbox(
                                        value: option.isCorrect,
                                        onChanged: (_) => _toggleOptionCorrect(
                                          index,
                                          optionIndex,
                                        ),
                                      ),
                                      Expanded(
                                        child: AppTextField(
                                          initialValue: option.content,
                                          hintText:
                                              'Lựa chọn ${optionIndex + 1}',
                                          onChanged: (value) {
                                            final updatedOptions = [
                                              ...question.options,
                                            ];
                                            updatedOptions[optionIndex] =
                                                updatedOptions[optionIndex]
                                                    .copyWith(content: value);
                                            _updateQuestion(
                                              index,
                                              options: updatedOptions,
                                            );
                                          },
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: question.options.length <= 1
                                            ? null
                                            : () => _removeOption(
                                                index,
                                                optionIndex,
                                              ),
                                        icon: const Icon(LucideIcons.x),
                                      ),
                                    ],
                                  );
                                }),
                                TextButton.icon(
                                  onPressed: () => _addOption(index),
                                  icon: const Icon(LucideIcons.plus),
                                  label: const Text('Thêm lựa chọn'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                    OutlinedButton.icon(
                      onPressed: _addQuestion,
                      icon: const Icon(LucideIcons.plus),
                      label: const Text('Thêm câu hỏi'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _submit,
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              widget.isEdit ? 'Lưu thay đổi' : 'Tạo bài thi',
                            ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (widget.isEdit)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.destructive,
                          foregroundColor: AppColors.destructiveForeground,
                        ),
                        onPressed: _isSaving ? null : _deleteExam,
                        child: const Text('Xóa bài thi'),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _QuestionDraft {
  const _QuestionDraft({
    required this.content,
    required this.type,
    required this.options,
  });

  final String content;
  final String type;
  final List<_OptionDraft> options;

  factory _QuestionDraft.singleDefault() => const _QuestionDraft(
    content: '',
    type: 'single',
    options: [
      _OptionDraft(content: 'Lựa chọn 1', isCorrect: true),
      _OptionDraft(content: 'Lựa chọn 2'),
    ],
  );

  _QuestionDraft copyWith({
    String? content,
    String? type,
    List<_OptionDraft>? options,
  }) {
    return _QuestionDraft(
      content: content ?? this.content,
      type: type ?? this.type,
      options: options ?? this.options,
    );
  }
}

class _OptionDraft {
  const _OptionDraft({required this.content, this.isCorrect = false});

  final String content;
  final bool isCorrect;

  _OptionDraft copyWith({String? content, bool? isCorrect}) {
    return _OptionDraft(
      content: content ?? this.content,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}
