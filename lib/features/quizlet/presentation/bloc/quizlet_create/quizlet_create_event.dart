part of 'quizlet_create_bloc.dart';

sealed class QuizletCreateEvent extends Equatable {
  const QuizletCreateEvent();

  @override
  List<Object?> get props => [];
}

final class LoadSubjects extends QuizletCreateEvent {
  const LoadSubjects();
}

final class LoadQuizletForEdit extends QuizletCreateEvent {
  final String quizletId;

  const LoadQuizletForEdit(this.quizletId);

  @override
  List<Object?> get props => [quizletId];
}

final class UpdateTitle extends QuizletCreateEvent {
  final String title;

  const UpdateTitle(this.title);

  @override
  List<Object?> get props => [title];
}

final class UpdateDescription extends QuizletCreateEvent {
  final String description;

  const UpdateDescription(this.description);

  @override
  List<Object?> get props => [description];
}

final class ToggleVisibility extends QuizletCreateEvent {
  final bool isPublic;

  const ToggleVisibility(this.isPublic);

  @override
  List<Object?> get props => [isPublic];
}

final class SelectSubject extends QuizletCreateEvent {
  final String subjectId;

  const SelectSubject(this.subjectId);

  @override
  List<Object?> get props => [subjectId];
}

final class SelectEducationLevel extends QuizletCreateEvent {
  final String educationLevel;

  const SelectEducationLevel(this.educationLevel);

  @override
  List<Object?> get props => [educationLevel];
}

final class UpdateGrade extends QuizletCreateEvent {
  final String grade;

  const UpdateGrade(this.grade);

  @override
  List<Object?> get props => [grade];
}

final class AddCard extends QuizletCreateEvent {
  const AddCard();
}

final class RemoveCard extends QuizletCreateEvent {
  final int index;

  const RemoveCard(this.index);

  @override
  List<Object?> get props => [index];
}

final class UpdateCard extends QuizletCreateEvent {
  final int index;
  final String term;
  final String definition;

  const UpdateCard(this.index, this.term, this.definition);

  @override
  List<Object?> get props => [index, term, definition];
}

final class ImportCards extends QuizletCreateEvent {
  final String csvContent;

  const ImportCards(this.csvContent);

  @override
  List<Object?> get props => [csvContent];
}

final class SubmitQuizlet extends QuizletCreateEvent {
  const SubmitQuizlet();
}
