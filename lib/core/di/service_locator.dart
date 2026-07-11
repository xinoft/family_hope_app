import 'package:get_it/get_it.dart';

import '../network/api_client.dart';
import '../storage/secure_storage_service.dart';

/// Global service locator. Used sparingly - only for singletons that need
/// to be reachable outside the widget tree (e.g. a SignalR listener
/// updating session/chat state, or a push-notification handler navigating
/// via go_router). Everything else should be provided through Provider in
/// the widget tree instead.
final GetIt getIt = GetIt.instance;

/// Registers core, feature-independent singletons. Feature-owned
/// singletons (e.g. `SessionProvider`, `StudentContextProvider`) are
/// registered in `app/bootstrap.dart`, which runs after this and is the
/// one place allowed to know about every feature.
void setupCoreServiceLocator() {
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
}
