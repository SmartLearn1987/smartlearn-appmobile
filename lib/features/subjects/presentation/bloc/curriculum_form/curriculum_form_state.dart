part of 'curriculum_form_bloc.dart';

class CurriculumFormState extends Equatable {
  final int step;
  final String name;
  final String grade;
  final String publisher;
  final String educationLevel;
  final bool isPublic;
  final int lessonCount;
  final File? imageFile;
  final String? existingImageUrl;
  final bool isSubmitting;
  final String? errorMessage;
  final bool isSuccess;
  final bool isEditMode;
  final String curriculumId;

  const CurriculumFormState({
    this.step = 0,
    this.name = '',
    this.grade = '',
    this.publisher = '',
    this.educationLevel = '',
    this.isPublic = false,
    this.lessonCount = 1,
    this.imageFile,
    this.existingImageUrl,
    this.isSubmitting = false,
    this.errorMessage,
    this.isSuccess = false,
    this.isEditMode = false,
    this.curriculumId = '',
  });

  CurriculumFormState copyWith({
    int? step,
    String? name,
    String? grade,
    String? publisher,
    String? educationLevel,
    bool? isPublic,
    int? lessonCount,
    File? imageFile,
    bool clearImageFile = false,
    String? existingImageUrl,
    bool clearExistingImageUrl = false,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? isSuccess,
    bool? isEditMode,
    String? curriculumId,
  }) {
    return CurriculumFormState(
      step: step ?? this.step,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      publisher: publisher ?? this.publisher,
      educationLevel: educationLevel ?? this.educationLevel,
      isPublic: isPublic ?? this.isPublic,
      lessonCount: lessonCount ?? this.lessonCount,
      imageFile: clearImageFile ? null : (imageFile ?? this.imageFile),
      existingImageUrl: clearExistingImageUrl
          ? null
          : (existingImageUrl ?? this.existingImageUrl),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
      isEditMode: isEditMode ?? this.isEditMode,
      curriculumId: curriculumId ?? this.curriculumId,
    );
  }

  @override
  List<Object?> get props => [
        step,
        name,
        grade,
        publisher,
        educationLevel,
        isPublic,
        lessonCount,
        imageFile,
        existingImageUrl,
        isSubmitting,
        errorMessage,
        isSuccess,
        isEditMode,
        curriculumId,
      ];
}
