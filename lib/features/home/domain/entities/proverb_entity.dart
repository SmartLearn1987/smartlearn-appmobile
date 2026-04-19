import 'package:equatable/equatable.dart';

class ProverbEntity extends Equatable {
  final String id;
  final String content;
  final String level;

  const ProverbEntity({
    required this.id,
    required this.content,
    required this.level,
  });

  @override
  List<Object?> get props => [id, content, level];
}
