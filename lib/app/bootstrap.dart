import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/constants/user_type.dart';
import '../core/di/service_locator.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage_service.dart';
import '../features/auth/data/user_repository.dart';
import '../features/auth/providers/session_provider.dart';
import '../features/finance/data/finance_repository.dart';
import '../features/gallery/data/gallery_repository.dart';
import '../features/student_context/data/student_repository.dart';
import '../features/student_context/providers/student_context_provider.dart';

/// Composition root: the one place allowed to know about every feature's
/// singletons. Registration must finish before [runApp] (the widget tree
/// reads these synchronously), but restoring the persisted session is left
/// running in the background - the splash screen covers that gap instead
/// of delaying the first frame.
void bootstrap() {
  setupCoreServiceLocator();

  getIt.registerLazySingleton<SessionProvider>(
    () => SessionProvider(
      secureStorage: getIt<SecureStorageService>(),
      apiClient: getIt<ApiClient>(),
    ),
  );
  getIt.registerLazySingleton<StudentContextProvider>(
    () => StudentContextProvider(),
  );
  getIt.registerLazySingleton<StudentRepository>(
    () => StudentRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<GalleryRepository>(
    () => GalleryRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<FinanceRepository>(
    () => FinanceRepository(getIt<ApiClient>()),
  );

  _syncSessionWithRealData();
  unawaited(getIt<SessionProvider>().restoreSession());
}

/// Fetches real profile/student data from the API right after a login or
/// restored session, and keeps [StudentContextProvider] in lockstep with
/// [SessionProvider] - covers both a fresh login *and* a session restored
/// from storage on app relaunch (the login pages alone can't handle the
/// restore case, since they're never shown when a session already exists).
///
/// The login itself is still a hardcoded dummy token (see
/// `SessionProvider`), but the entity id it's tagged with is real, so this
/// is genuine API data, not a placeholder.
void _syncSessionWithRealData() {
  final session = getIt<SessionProvider>();
  final studentContext = getIt<StudentContextProvider>();
  final studentRepository = getIt<StudentRepository>();
  final userRepository = getIt<UserRepository>();

  session.addListener(() {
    final user = session.currentUser;
    if (user == null) {
      studentContext.clear();
      return;
    }

    // Which student's data is shown (parent) is a separate concern from
    // whose name/email/phone represents the signed-in person - the latter
    // always comes from UserAccount, the same way for both personas.
    if (user.userType == UserType.parent && studentContext.activeStudent == null) {
      studentRepository.fetchStudentById(user.id).then(
        (student) => studentContext.setStudents([student]),
        onError: (Object error) => debugPrint('Failed to load student ${user.id}: $error'),
      );
    }

    if (!session.isProfileEnriched) {
      // There's no separate parent-account endpoint yet, so a parent's own
      // details are borrowed from the same UserAccount table staff use,
      // via a hardcoded id independent of which student they're viewing.
      // Revisit once a real, distinct parent login/identity exists.
      final accountId = user.userType == UserType.parent
          ? SessionProvider.dummyParentUserId
          : SessionProvider.dummyStaffUserId;
      userRepository.fetchUserById(accountId).then(
        (profile) => session.applyEnrichedProfile(
          user.copyWith(name: profile.fullName, email: profile.email, phone: profile.phone),
        ),
        onError: (Object error) {
          debugPrint('Failed to load profile for user $accountId: $error');
          session.markProfileEnrichmentAttempted();
        },
      );
    }
  });
}
