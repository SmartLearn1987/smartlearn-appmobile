import 'package:equatable/equatable.dart';

class SubjectEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final int sortOrder;
  final int curriculumCount;

  const SubjectEntity({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.sortOrder,
    required this.curriculumCount,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        icon,
        sortOrder,
        curriculumCount,
      ];
}
