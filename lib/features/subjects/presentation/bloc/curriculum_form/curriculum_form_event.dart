part of 'curriculum_form_bloc.dart';

sealed class CurriculumFormEvent extends Equatable {
  const CurriculumFormEvent();

  @override
  List<Object?> get props => [];
}

final class CurriculumFormInitialized extends CurriculumFormEvent {
  final CurriculumEntity? curriculum;

  const CurriculumFormInitialized({this.curriculum});

  @override
  List<Object?> get props => [curriculum];
}

final class CurriculumFormFieldChanged extends CurriculumFormEvent {
  final String field;
  final Object value;

  const CurriculumFormFieldChanged({
    required this.field,
    required this.value,
  });

  @override
  List<Object?> get props => [field, value];
}

final class CurriculumFormImageSelected extends CurriculumFormEvent {
  final File file;

  const CurriculumFormImageSelected({required this.file});

  @override
  List<Object?> get props => [file];
}

final class CurriculumFormImageRemoved extends CurriculumFormEvent {
  const CurriculumFormImageRemoved();
}

final class CurriculumFormStepChanged extends CurriculumFormEvent {
  final int step;

  const CurriculumFormStepChanged({required this.step});

  @override
  List<Object?> get props => [step];
}

final class CurriculumFormSubmitted extends CurriculumFormEvent {
  final String subjectId;

  const CurriculumFormSubmitted({required this.subjectId});

  @override
  List<Object?> get props => [subjectId];
}
