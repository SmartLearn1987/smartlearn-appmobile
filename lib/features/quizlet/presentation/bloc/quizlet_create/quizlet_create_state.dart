part of 'quizlet_create_bloc.dart';

class QuizletCreateState extends Equatable {
  final bool isEditMode;
  final String? quizletId;
  final String title;
  final String description;
  final bool isPublic;
  final String? selectedSubjectId;
  final String? educationLevel;
  final String grade;
  final List<CardFormData> cards;
  final List<SubjectEntity> subjects;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isLoadingDetail;
  final String? errorMessage;

  const QuizletCreateState({
    this.isEditMode = false,
    this.quizletId,
    this.title = '',
    this.description = '',
    this.isPublic = true,
    this.selectedSubjectId,
    this.educationLevel,
    this.grade = '',
    this.cards = const [CardFormData.empty(), CardFormData.empty()],
    this.subjects = const [],
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isLoadingDetail = false,
    this.errorMessage,
  });

  QuizletCreateState copyWith({
    bool? isEditMode,
    String? quizletId,
    String? title,
    String? description,
    bool? isPublic,
    String? selectedSubjectId,
    String? educationLevel,
    String? grade,
    List<CardFormData>? cards,
    List<SubjectEntity>? subjects,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isLoadingDetail,
    String? errorMessage,
  }) {
    return QuizletCreateState(
      isEditMode: isEditMode ?? this.isEditMode,
      quizletId: quizletId ?? this.quizletId,
      title: title ?? this.title,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      selectedSubjectId: selectedSubjectId ?? this.selectedSubjectId,
      educationLevel: educationLevel ?? this.educationLevel,
      grade: grade ?? this.grade,
      cards: cards ?? this.cards,
      subjects: subjects ?? this.subjects,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isEditMode,
        quizletId,
        title,
        description,
        isPublic,
        selectedSubjectId,
        educationLevel,
        grade,
        cards,
        subjects,
        isSubmitting,
        isSuccess,
        isLoadingDetail,
        errorMessage,
      ];
}
