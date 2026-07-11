import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/config/app_config.dart';
import '../core/di/service_locator.dart';
import '../core/models/module_capability.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/providers/session_provider.dart';
import '../features/student_context/providers/student_context_provider.dart';
import 'router/app_router.dart';

class FamilyHopeApp extends StatefulWidget {
  const FamilyHopeApp({super.key});

  @override
  State<FamilyHopeApp> createState() => _FamilyHopeAppState();
}

class _FamilyHopeAppState extends State<FamilyHopeApp> {
  // Built once - go_router's `refreshListenable` handles reacting to
  // session changes internally, so this must not be rebuilt on every
  // Provider update or the navigation stack would reset.
  late final GoRouter _router = buildAppRouter(getIt<SessionProvider>());

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: getIt<SessionProvider>()),
        ChangeNotifierProvider.value(value: getIt<StudentContextProvider>()),
        // Exposes just the resolved Capabilities so core/ widgets (like
        // PermissionGate) can depend on that type without depending on
        // the features/auth layer.
        ProxyProvider<SessionProvider, Capabilities>(
          update: (_, session, _) => session.capabilities,
        ),
      ],
      child: MaterialApp.router(
        title: AppConfig.current.appName,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        routerConfig: _router,
      ),
    );
  }
}
