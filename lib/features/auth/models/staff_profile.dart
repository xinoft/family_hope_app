/// Mirrors the fields returned by `UserAccount/GetUserAccountById` - see
/// `InkersCore.Models.AuthEntityModels.UserAccount`.
class StaffProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;

  const StaffProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
  });

  String get fullName => [firstName, lastName].where((part) => part.isNotEmpty).join(' ');

  factory StaffProfile.fromJson(Map<String, dynamic> json) {
    return StaffProfile(
      id: (json['Id'] ?? 0).toString(),
      firstName: json['FirstName'] as String? ?? '',
      lastName: json['LastName'] as String? ?? '',
      email: json['Email'] as String?,
      phone: json['Phone'] as String?,
    );
  }
}
