import 'package:equatable/equatable.dart';

class DictationEntity extends Equatable {
  final String id;
  final String title;
  final String level;
  final String content;
  final String language;

  const DictationEntity({
    required this.id,
    required this.title,
    required this.level,
    required this.content,
    required this.language,
  });

  @override
  List<Object?> get props => [id, title, level, content, language];
}
