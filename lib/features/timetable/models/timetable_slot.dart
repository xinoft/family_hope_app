enum TimetableSlotType { lesson, breakTime, empty }

const List<String> weekDayNames = [
  '',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// Mirrors `ClassSchedule/GetTeacherSchedule`'s slot shape - see
/// `InkersCore.Models.DataModels.TeacherScheduleSlotData` (`SlotType`:
/// 1 = Lesson, 2 = Break, 3 = Empty, per `TeacherScheduleSlotTypes`).
/// Dummy content for now - see `TimetableRepository`.
class TimetableSlot {
  final String id;
  final int weekDay;
  final int displayOrder;
  final TimetableSlotType slotType;
  final String startTime;
  final String endTime;
  final String? title;

  const TimetableSlot({
    required this.id,
    required this.weekDay,
    required this.displayOrder,
    required this.slotType,
    required this.startTime,
    required this.endTime,
    this.title,
  });

  factory TimetableSlot.fromJson(Map<String, dynamic> json) {
    return TimetableSlot(
      id: (json['Id'] ?? 0).toString(),
      weekDay: json['WeekDay'] as int? ?? 1,
      displayOrder: json['DisplayOrder'] as int? ?? 0,
      slotType: switch (json['SlotType'] as int? ?? 1) {
        2 => TimetableSlotType.breakTime,
        3 => TimetableSlotType.empty,
        _ => TimetableSlotType.lesson,
      },
      startTime: json['StartTime'] as String? ?? '',
      endTime: json['EndTime'] as String? ?? '',
      title: json['Title'] as String?,
    );
  }
}
