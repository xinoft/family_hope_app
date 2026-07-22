/// Mirrors `StudentGoalStatuses` on the backend - shared by a goal's
/// overall status and each checklist item's status.
enum GoalStatus {
  pending(1),
  completed(2),
  onHold(3),
  canceled(4);

  final int value;
  const GoalStatus(this.value);

  static GoalStatus fromInt(int value) => switch (value) {
        2 => GoalStatus.completed,
        3 => GoalStatus.onHold,
        4 => GoalStatus.canceled,
        _ => GoalStatus.pending,
      };
}

/// Mirrors `Goal/GetStudentGoals`'s items - see
/// `InkersCore.Models.DataModels.StudentGoalData`. Dummy content for now -
/// see `GoalsRepository`.
class StudentGoal {
  final String id;
  final String title;
  final String categoryName;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final GoalStatus status;
  final String? remarks;
  final List<GoalChecklistItem> checklistItems;

  const StudentGoal({
    required this.id,
    required this.title,
    required this.categoryName,
    this.description,
    this.startDate,
    this.endDate,
    required this.status,
    this.remarks,
    required this.checklistItems,
  });

  factory StudentGoal.fromJson(Map<String, dynamic> json) {
    return StudentGoal(
      id: (json['Id'] ?? 0).toString(),
      title: json['Title'] as String? ?? '',
      categoryName: json['CategoryName'] as String? ?? '',
      description: json['Description'] as String?,
      startDate: DateTime.tryParse(json['StartDate'] as String? ?? ''),
      endDate: DateTime.tryParse(json['EndDate'] as String? ?? ''),
      status: GoalStatus.fromInt(json['Status'] as int? ?? 1),
      remarks: json['Remarks'] as String?,
      checklistItems: (json['ChecklistItems'] as List? ?? [])
          .map((item) => GoalChecklistItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GoalChecklistItem {
  final String title;
  final String? objective;
  final GoalStatus status;

  const GoalChecklistItem({required this.title, this.objective, required this.status});

  factory GoalChecklistItem.fromJson(Map<String, dynamic> json) {
    return GoalChecklistItem(
      title: json['Title'] as String? ?? '',
      objective: json['Objective'] as String?,
      status: GoalStatus.fromInt(json['Status'] as int? ?? 1),
    );
  }
}
