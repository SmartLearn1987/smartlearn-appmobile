import 'package:equatable/equatable.dart';

class PictogramEntity extends Equatable {
  final String id;
  final String imageUrl;
  final String answer;
  final String level;

  const PictogramEntity({
    required this.id,
    required this.imageUrl,
    required this.answer,
    required this.level,
  });

  @override
  List<Object?> get props => [id, imageUrl, answer, level];
}
