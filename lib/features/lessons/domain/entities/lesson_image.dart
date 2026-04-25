import 'package:equatable/equatable.dart';

class LessonImage extends Equatable {
  final String id;
  final String lessonId;
  final String fileUrl;
  final String? caption;
  final int sortOrder;

  const LessonImage({
    required this.id,
    required this.lessonId,
    required this.fileUrl,
    this.caption,
    required this.sortOrder,
  });

  @override
  List<Object?> get props => [id, lessonId, fileUrl, caption, sortOrder];
}
