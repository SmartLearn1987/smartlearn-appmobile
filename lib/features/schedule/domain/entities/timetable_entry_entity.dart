import 'package:equatable/equatable.dart';

class TimetableEntryEntity extends Equatable {
  final String id;
  final String day;
  final String subject;
  final String startTime;
  final String endTime;
  final String? room;

  const TimetableEntryEntity({
    required this.id,
    required this.day,
    required this.subject,
    required this.startTime,
    required this.endTime,
    this.room,
  });

  @override
  List<Object?> get props => [
        id,
        day,
        subject,
        startTime,
        endTime,
        room,
      ];
}
