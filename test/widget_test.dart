import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:family_hope_app/app/router/app_router.dart';
import 'package:family_hope_app/core/config/app_config.dart';
import 'package:family_hope_app/core/models/module_capability.dart';
import 'package:family_hope_app/core/network/api_client.dart';
import 'package:family_hope_app/core/storage/secure_storage_service.dart';
import 'package:family_hope_app/core/theme/app_theme.dart';
import 'package:family_hope_app/features/auth/providers/session_provider.dart';
import 'package:family_hope_app/features/student_context/providers/student_context_provider.dart';

void main() {
  testWidgets('shows the parent login page on launch, with a staff login link', (tester) async {
    // Providers are constructed directly here rather than via
    // `bootstrap()`/get_it - `bootstrap()` calls into real secure storage,
    // which has no platform to answer it in a widget test and hangs. A
    // fresh, unrestored session is also exactly what "on launch" means for
    // this smoke test anyway.
    final session = SessionProvider(
      secureStorage: SecureStorageService(),
      apiClient: ApiClient(),
    );
    final studentContext = StudentContextProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: session),
          ChangeNotifierProvider.value(value: studentContext),
          ProxyProvider<SessionProvider, Capabilities>(
            update: (_, s, _) => s.capabilities,
          ),
        ],
        child: MaterialApp.router(
          title: AppConfig.current.appName,
          theme: AppTheme.light(),
          routerConfig: buildAppRouter(session),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Staff Login'), findsOneWidget);
    expect(find.text('Parent Login'), findsOneWidget);
  });
}
