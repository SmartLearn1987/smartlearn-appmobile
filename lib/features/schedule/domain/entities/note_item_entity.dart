import 'package:equatable/equatable.dart';

class NoteItemEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final DateTime updatedAt;

  const NoteItemEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, title, content, updatedAt];
}
