import 'package:equatable/equatable.dart';

class ContentBlock extends Equatable {
  final String type;
  final String content;

  const ContentBlock({
    required this.type,
    required this.content,
  });

  @override
  List<Object?> get props => [type, content];
}
