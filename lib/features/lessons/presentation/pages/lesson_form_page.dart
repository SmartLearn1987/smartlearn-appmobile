import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/content_block.dart';
import '../../domain/entities/lesson_entity.dart';
import '../../domain/entities/lesson_image.dart';
import '../../domain/usecases/get_lesson_by_id_use_case.dart';
import '../../domain/usecases/get_lesson_images_use_case.dart';
import '../bloc/lessons_list/lessons_list_bloc.dart';
import '../widgets/flashcard_editor.dart';
import '../widgets/image_upload_section.dart';
import '../widgets/quiz_question_editor.dart';
import '../widgets/rich_content_editor.dart';

/// Lesson form page for creating or editing a lesson.
///
/// When [lessonId] is provided, the page operates in edit mode and loads
/// existing lesson data from the API.
class LessonFormPage extends StatelessWidget {
  const LessonFormPage({
    super.key,
    required this.subjectId,
    required this.curriculumId,
    this.curriculumName,
    this.publisher,
    this.lessonId,
  });

  final String subjectId;
  final String curriculumId;
  final String? curriculumName;
  final String? publisher;
  final String? lessonId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LessonsListBloc>(
      create: (_) => getIt<LessonsListBloc>(),
      child: _LessonFormView(
        subjectId: subjectId,
        curriculumId: curriculumId,
        curriculumName: curriculumName,
        publisher: publisher,
        lessonId: lessonId,
      ),
    );
  }
}

class _LessonFormView extends StatefulWidget {
  const _LessonFormView({
    required this.subjectId,
    required this.curriculumId,
    this.curriculumName,
    this.publisher,
    this.lessonId,
  });

  final String subjectId;
  final String curriculumId;
  final String? curriculumName;
  final String? publisher;
  final String? lessonId;

  @override
  State<_LessonFormView> createState() => _LessonFormViewState();
}

class _LessonFormViewState extends State<_LessonFormView> {
  final _formKey = GlobalKey<FormState>();
  final _contentEditorKey = GlobalKey<RichContentEditorState>();
  final _quizEditorKey = GlobalKey<QuizQuestionEditorState>();
  final _flashcardEditorKey = GlobalKey<FlashcardEditorState>();
  final _imageUploadKey = GlobalKey<ImageUploadSectionState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _summaryController;
  late final TextEditingController _keyPointsController;

  /// Content blocks managed by the RichContentEditor.
  List<ContentBlock> _contentBlocks = [];

  /// Quiz questions managed by the QuizQuestionEditor.
  List<Map<String, dynamic>> _quizQuestions = [];

  /// Flashcards managed by the FlashcardEditor.
  List<Map<String, String>> _flashcards = [];

  /// Pending images queued locally for upload during save (create mode).
  List<File> _pendingImages = [];

  /// Existing images loaded from the server (edit mode).
  final List<LessonImage> _existingImages = [];

  bool get _isEditMode => widget.lessonId != null;

  /// Whether the form is currently saving.
  bool _isSaving = false;

  /// Whether the lesson data is being loaded (edit mode).
  bool _isLoadingLesson = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _summaryController = TextEditingController();
    _keyPointsController = TextEditingController();

    if (_isEditMode) {
      _loadLessonData();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _summaryController.dispose();
    _keyPointsController.dispose();
    super.dispose();
  }

  /// Loads existing lesson data and images for edit mode.
  Future<void> _loadLessonData() async {
    setState(() => _isLoadingLesson = true);

    final getLessonById = getIt<GetLessonByIdUseCase>();
    final getLessonImages = getIt<GetLessonImagesUseCase>();

    final lessonResult = await getLessonById(widget.lessonId!);
    final imagesResult = await getLessonImages(widget.lessonId!);

    if (!mounted) return;

    lessonResult.fold(
      (failure) {
        AppToast.error(context, 'Không thể tải dữ liệu bài học');
        setState(() => _isLoadingLesson = false);
      },
      (lesson) {
        _populateForm(lesson);

        imagesResult.fold(
          (_) {
            // Images failed to load, but lesson data is fine
            setState(() => _isLoadingLesson = false);
          },
          (images) {
            setState(() {
              _existingImages
                ..clear()
                ..addAll(images);
              _isLoadingLesson = false;
            });
          },
        );
      },
    );
  }

  /// Populates the form fields with existing lesson data.
  void _populateForm(LessonEntity lesson) {
    setState(() {
      _titleController.text = lesson.title;
      _descriptionController.text = lesson.description ?? '';
      _summaryController.text = lesson.summary ?? '';
      _keyPointsController.text = lesson.keyPoints.join('\n');

      _contentBlocks = List.of(lesson.content);

      _quizQuestions = lesson.quiz?.map((q) => <String, dynamic>{
                'question': q.question,
                'options': List<String>.from(q.options),
                'correctIndex': q.correctIndex,
                'explanation': q.explanation ?? '',
              })
          .toList() ?? [];

      _flashcards = lesson.flashcards?.map((f) => <String, String>{
                'front': f.front,
                'back': f.back,
              })
          .toList() ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LessonsListBloc, LessonsListState>(
      listener: _handleBlocState,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: _isLoadingLesson
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.mdLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleField(),
                        const SizedBox(height: AppSpacing.md),
                        _buildDescriptionField(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildContentSection(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildImageSection(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildSummaryField(),
                        const SizedBox(height: AppSpacing.md),
                        _buildKeyPointsField(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildQuizSection(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildFlashcardSection(),
                        const SizedBox(height: AppSpacing.xl),
                        _buildActionButtons(),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  // ─── BLoC Listener ───

  void _handleBlocState(BuildContext context, LessonsListState state) {
    if (state is LessonSaveSuccess) {
      setState(() => _isSaving = false);
      AppToast.success(context, 'Đã lưu bài học thành công');
      context.pop();
    } else if (state is LessonSaveFailure) {
      setState(() => _isSaving = false);
      AppToast.error(
        context,
        'Không thể lưu bài học. Vui lòng thử lại.',
      );
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: BackButton(onPressed: () => context.pop()),
      title: Column(
        children: [
          Text(
            _isEditMode ? 'Sửa bài học' : 'Tạo bài học',
            style: AppTypography.h3.copyWith(color: AppColors.foreground),
          ),
          if (widget.curriculumName != null)
            Text(
              widget.curriculumName!,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  // ─── Title Field ───

  Widget _buildTitleField() {
    return AppTextField(
      controller: _titleController,
      label: 'Tên bài học *',
      hintText: 'VD: Bài 1 - Giới thiệu',
      autovalidateMode: AutovalidateMode.disabled,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập tên bài học';
        }
        return null;
      },
    );
  }

  // ─── Description Field ───

  Widget _buildDescriptionField() {
    return AppTextField(
      controller: _descriptionController,
      label: 'Mô tả',
      hintText: 'Mô tả ngắn gọn về bài học',
      maxLines: 3,
      minLines: 2,
    );
  }

  // ─── Content Section (RichContentEditor) ───

  Widget _buildContentSection() {
    return _buildSectionContainer(
      icon: LucideIcons.fileText,
      title: 'Nội dung bài học',
      child: RichContentEditor(
        key: _contentEditorKey,
        initialBlocks: _contentBlocks,
        onChanged: (blocks) {
          _contentBlocks = blocks;
        },
      ),
    );
  }

  // ─── Image Section (ImageUploadSection) ───

  Widget _buildImageSection() {
    return _buildSectionContainer(
      icon: LucideIcons.image,
      title: 'Hình ảnh',
      child: ImageUploadSection(
        key: _imageUploadKey,
        lessonId: widget.lessonId,
        existingImages: _existingImages,
        onPendingImagesChanged: (images) {
          _pendingImages = images;
        },
      ),
    );
  }

  // ─── Summary Field ───

  Widget _buildSummaryField() {
    return AppTextField(
      controller: _summaryController,
      label: 'Tóm tắt',
      hintText: 'Tóm tắt nội dung bài học',
      maxLines: 5,
      minLines: 3,
    );
  }

  // ─── Key Points Field ───

  Widget _buildKeyPointsField() {
    return AppTextField(
      controller: _keyPointsController,
      label: 'Điểm chính',
      hintText: 'Mỗi điểm chính trên một dòng',
      maxLines: 5,
      minLines: 3,
    );
  }

  // ─── Quiz Section (QuizQuestionEditor) ───

  Widget _buildQuizSection() {
    return _buildSectionContainer(
      icon: LucideIcons.helpCircle,
      title: 'Trắc nghiệm',
      child: QuizQuestionEditor(
        key: _quizEditorKey,
        initialQuestions: _quizQuestions,
        onChanged: () {
          _quizQuestions =
              _quizEditorKey.currentState?.questions ?? _quizQuestions;
        },
      ),
    );
  }

  // ─── Flashcard Section (FlashcardEditor) ───

  Widget _buildFlashcardSection() {
    return _buildSectionContainer(
      icon: LucideIcons.layers,
      title: 'Flashcards',
      child: FlashcardEditor(
        key: _flashcardEditorKey,
        initialFlashcards: _flashcards,
        onChanged: () {
          _flashcards =
              _flashcardEditorKey.currentState?.flashcards ?? _flashcards;
        },
      ),
    );
  }

  // ─── Action Buttons ───

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSaving ? null : () => context.pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.mutedForeground,
              textStyle: AppTypography.buttonMedium,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.smMd),
              shape: RoundedRectangleBorder(
                borderRadius: AppBorders.borderRadiusSm,
              ),
              side: const BorderSide(color: AppColors.border),
            ),
            child: const Text('Hủy'),
          ),
        ),
        const SizedBox(width: AppSpacing.smMd),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.primaryForeground,
              textStyle: AppTypography.buttonMedium,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.smMd),
              shape: RoundedRectangleBorder(
                borderRadius: AppBorders.borderRadiusSm,
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryForeground,
                    ),
                  )
                : Text(_isEditMode ? 'Cập nhật bài học' : 'Lưu bài học'),
          ),
        ),
      ],
    );
  }

  // ─── Section Container Helper ───

  Widget _buildSectionContainer({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              title,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.foreground,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }

  // ─── Save Handler ───

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    // Collect latest data from editor widgets.
    final contentBlocks =
        _contentEditorKey.currentState?.blocks ?? _contentBlocks;
    final quizQuestions =
        _quizEditorKey.currentState?.questions ?? _quizQuestions;
    final flashcards =
        _flashcardEditorKey.currentState?.flashcards ?? _flashcards;
    final pendingImages =
        _imageUploadKey.currentState?.pendingImages ?? _pendingImages;

    // Build key points list from newline-separated text.
    final keyPoints = _keyPointsController.text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    // Build lesson data map (snake_case keys matching API format).
    final lessonData = <String, dynamic>{
      'curriculum_id': widget.curriculumId,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'content': contentBlocks
          .map((b) => {'type': b.type, 'content': b.content})
          .toList(),
      'summary': _summaryController.text.trim(),
      'key_points': keyPoints,
    };

    // Build quiz/flashcards data map for the updateQuizFlashcards endpoint.
    final quizFlashcardsData = <String, dynamic>{
      'quiz_questions': quizQuestions
          .map((q) => <String, dynamic>{
                'question': q['question'] as String? ?? '',
                'options': (q['options'] as List<dynamic>?)
                        ?.cast<String>()
                        .toList() ??
                    <String>[],
                'correct_index': q['correctIndex'] as int? ?? 0,
                'explanation': q['explanation'] as String? ?? '',
              })
          .toList(),
      'flashcards': flashcards
          .map((f) => <String, dynamic>{
                'front': f['front'] ?? '',
                'back': f['back'] ?? '',
              })
          .toList(),
    };

    final bloc = context.read<LessonsListBloc>();

    if (_isEditMode) {
      bloc.add(LessonUpdateRequested(
        lessonId: widget.lessonId!,
        lessonData: lessonData,
        quizFlashcardsData: quizFlashcardsData,
      ));
    } else {
      bloc.add(LessonCreateRequested(
        lessonData: lessonData,
        quizFlashcardsData: quizFlashcardsData,
        images: pendingImages,
      ));
    }
  }
}
