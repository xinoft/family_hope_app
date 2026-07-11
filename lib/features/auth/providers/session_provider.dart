import 'package:flutter/foundation.dart';

import '../../../core/config/persona_policy.dart';
import '../../../core/constants/user_type.dart';
import '../../../core/models/module_capability.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../models/app_user.dart';

/// Holds the signed-in identity and its resolved [Capabilities].
///
/// There is no real staff/parent authentication on the backend yet, so
/// login here just tags the user with whichever button they tapped, issues
/// a hardcoded dummy token, and pins a hardcoded real backend entity id
/// (a staff `UserAccount` id, or - for a parent - a student id, since
/// there's no parent account concept yet). That id is what lets
/// `bootstrap.dart` fetch and display real profile/student data despite
/// the login itself being fake - see the class-level TODO on
/// [loginAsStaff]/[loginAsParent] for what needs to change once real auth
/// lands (the entity id should then come from the login response instead
/// of being hardcoded, but everything downstream of it stays the same).
class SessionProvider extends ChangeNotifier {
  // TODO(auth): replace with a real POST to AuthController.Login once
  // staff auth is wired, and with a real parent auth flow (plus fetching
  // the parent's linked student list instead of one hardcoded id) once
  // that exists on the backend.
  static const _dummyStaffToken = 'dummy-staff-token';
  static const _dummyParentToken = 'dummy-parent-token';

  /// Hardcoded per the current product decision: parents are assumed to
  /// have exactly this one student (a real id in the dev database) until
  /// real parent-student linkage exists on the backend.
  static const dummyParentStudentId = '3';

  /// Hardcoded staff `UserAccount` id, same reasoning as above.
  static const dummyStaffUserId = '1';

  /// Hardcoded `UserAccount` id used to enrich the *parent's own* name/
  /// email/phone (there's no separate parent-account concept yet, so this
  /// borrows the same UserAccount table staff use). Independent of
  /// [dummyParentStudentId], which scopes which student's data is shown -
  /// update this once a real, distinct parent login/identity exists.
  static const dummyParentUserId = '1';

  final SecureStorageService _secureStorage;
  final ApiClient _apiClient;

  AppUser? _currentUser;
  Capabilities _capabilities = Capabilities.none;

  // Defaults to false (rather than true) so widget tests that construct a
  // SessionProvider directly - without ever calling restoreSession() and
  // its real secure-storage read - skip the splash redirect entirely. Only
  // the real `restoreSession()` call (fired from main()) flips this true
  // for the brief window while it's reading from storage.
  bool _isInitializing = false;

  // Guards the one-time real-profile fetch bootstrap.dart does per
  // session, so it doesn't refire every time this notifies listeners
  // (including its own notify after the fetch completes).
  bool _isProfileEnriched = false;

  SessionProvider({
    required SecureStorageService secureStorage,
    required ApiClient apiClient,
  })  : _secureStorage = secureStorage,
        _apiClient = apiClient;

  AppUser? get currentUser => _currentUser;
  Capabilities get capabilities => _capabilities;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitializing => _isInitializing;
  bool get isProfileEnriched => _isProfileEnriched;

  /// Re-hydrates the session from secure storage on app startup. The
  /// router shows a splash screen for as long as this is in flight (see
  /// [isInitializing]).
  Future<void> restoreSession() async {
    _isInitializing = true;
    notifyListeners();
    try {
      final token = await _secureStorage.readToken();
      final userTypeName = await _secureStorage.readUserType();
      final entityId = await _secureStorage.readEntityId();
      if (token == null || userTypeName == null || entityId == null) return;

      final userType = UserType.values.firstWhere(
        (type) => type.name == userTypeName,
        orElse: () => UserType.staff,
      );
      await _applySession(userType: userType, token: token, entityId: entityId);
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> loginAsStaff() async {
    await _applySession(
      userType: UserType.staff,
      token: _dummyStaffToken,
      entityId: dummyStaffUserId,
    );
  }

  Future<void> loginAsParent() async {
    await _applySession(
      userType: UserType.parent,
      token: _dummyParentToken,
      entityId: dummyParentStudentId,
    );
  }

  Future<void> logout() async {
    _currentUser = null;
    _capabilities = Capabilities.none;
    _isProfileEnriched = false;
    _apiClient.authToken = null;
    await _secureStorage.clear();
    notifyListeners();
  }

  /// Replaces [currentUser] with real fetched profile data (name/email/
  /// phone) once `bootstrap.dart`'s listener has loaded it. Marks
  /// enrichment done regardless of the caller's success, so a failed
  /// fetch doesn't retry forever - the user just keeps the placeholder
  /// name for this session.
  void applyEnrichedProfile(AppUser enrichedUser) {
    _currentUser = enrichedUser;
    _isProfileEnriched = true;
    notifyListeners();
  }

  void markProfileEnrichmentAttempted() {
    _isProfileEnriched = true;
    notifyListeners();
  }

  Future<void> _applySession({
    required UserType userType,
    required String token,
    required String entityId,
  }) async {
    _currentUser = AppUser(
      id: entityId,
      name: userType == UserType.parent ? 'Parent' : 'Staff',
      userType: userType,
    );
    _capabilities = PersonaPolicy.resolve(userType);
    _isProfileEnriched = false;
    _apiClient.authToken = token;

    await _secureStorage.saveToken(token);
    await _secureStorage.saveUserType(userType.name);
    await _secureStorage.saveEntityId(entityId);

    notifyListeners();
  }
}
