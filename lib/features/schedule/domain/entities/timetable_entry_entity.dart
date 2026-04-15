import 'package:equatable/equatable.dart';

class TimetableEntryEntity extends Equatable {
  final String id;
  final int day;
  final String subject;
  final String startTime;
  final String endTime;
  final String room;
  final int color;

  const TimetableEntryEntity({
    required this.id,
    required this.day,
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.color,
  });

  @override
  List<Object?> get props => [
        id,
        day,
        subject,
        startTime,
        endTime,
        room,
        color,
      ];
}
