/// Mirrors `Meeting/GetMeetings`'s items - see
/// `InkersCore.Models.DataModels.MeetingData`. Dummy content for now - see
/// `MeetingsRepository`.
class Meeting {
  final String id;
  final String meetingTypeName;
  final String title;
  final String? description;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String? meetLink;
  final String audienceSummary;

  const Meeting({
    required this.id,
    required this.meetingTypeName,
    required this.title,
    this.description,
    required this.startDateTime,
    required this.endDateTime,
    this.meetLink,
    required this.audienceSummary,
  });

  bool get isUpcoming => endDateTime.isAfter(DateTime.now());

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: (json['Id'] ?? 0).toString(),
      meetingTypeName: json['MeetingTypeName'] as String? ?? '',
      title: json['Title'] as String? ?? '',
      description: json['Description'] as String?,
      startDateTime: DateTime.tryParse(json['StartDateTime'] as String? ?? '') ?? DateTime.now(),
      endDateTime: DateTime.tryParse(json['EndDateTime'] as String? ?? '') ?? DateTime.now(),
      meetLink: json['MeetLink'] as String?,
      audienceSummary: json['AudienceSummary'] as String? ?? '',
    );
  }
}
