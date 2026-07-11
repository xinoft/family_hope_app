import '../../../core/constants/user_type.dart';

/// The signed-in identity. `id` is the real backend entity id (a staff
/// `UserAccount` id, or - for a parent - the hardcoded student id, since
/// there's no separate parent account id yet) - see `SessionProvider`'s
/// class doc for why these are still hardcoded rather than issued by a
/// real login. `name`/`email`/`phone` start as placeholders and are
/// enriched with real fetched data shortly after login/restore.
class AppUser {
  final String id;
  final String name;
  final UserType userType;
  final String? email;
  final String? phone;

  const AppUser({
    required this.id,
    required this.name,
    required this.userType,
    this.email,
    this.phone,
  });

  AppUser copyWith({String? name, String? email, String? phone}) => AppUser(
        id: id,
        userType: userType,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
      );
}
