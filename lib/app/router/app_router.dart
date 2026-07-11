import 'package:go_router/go_router.dart';

import '../../features/approvals/presentation/approvals_page.dart';
import '../../features/attendance/presentation/attendance_page.dart';
import '../../features/auth/presentation/parent_login_page.dart';
import '../../features/auth/presentation/staff_login_page.dart';
import '../../features/auth/providers/session_provider.dart';
import '../../features/chat/presentation/chat_page.dart';
import '../../features/circulars/presentation/circulars_page.dart';
import '../../features/finance/presentation/finance_page.dart';
import '../../features/gallery/presentation/gallery_page.dart';
import '../../features/goals/presentation/goals_page.dart';
import '../../features/home/presentation/home_shell_page.dart';
import '../../features/meetings/presentation/meetings_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/reports/presentation/reports_page.dart';
import '../../features/splash/presentation/splash_page.dart';
import '../../features/timetable/presentation/timetable_page.dart';
import 'routes.dart';

/// Single router for both personas - staff and parents share the same
/// route tree, [PermissionGate]s inside each page decide what's visible.
/// `refreshListenable: session` means login/logout/session-restore all
/// automatically redirect without screens having to call `context.go`
/// themselves.
GoRouter buildAppRouter(SessionProvider session) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: session,
    redirect: (context, state) {
      if (session.isInitializing) {
        return state.matchedLocation == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final isAuthRoute =
          state.matchedLocation == AppRoutes.root || state.matchedLocation == AppRoutes.staffLogin;

      if (!session.isAuthenticated) {
        return isAuthRoute ? null : AppRoutes.root;
      }
      return (isAuthRoute || state.matchedLocation == AppRoutes.splash) ? AppRoutes.home : null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.root,
        builder: (context, state) => const ParentLoginPage(),
      ),
      GoRoute(
        path: AppRoutes.staffLogin,
        builder: (context, state) => const StaffLoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeShellPage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.circulars,
        builder: (context, state) => const CircularsPage(),
      ),
      GoRoute(
        path: AppRoutes.attendance,
        builder: (context, state) => const AttendancePage(),
      ),
      GoRoute(
        path: AppRoutes.timetable,
        builder: (context, state) => const TimetablePage(),
      ),
      GoRoute(
        path: AppRoutes.meetings,
        builder: (context, state) => const MeetingsPage(),
      ),
      GoRoute(
        path: AppRoutes.goals,
        builder: (context, state) => const GoalsPage(),
      ),
      GoRoute(
        path: AppRoutes.reports,
        builder: (context, state) => const ReportsPage(),
      ),
      GoRoute(
        path: AppRoutes.finance,
        builder: (context, state) => const FinancePage(),
      ),
      GoRoute(
        path: AppRoutes.gallery,
        builder: (context, state) => const GalleryPage(),
      ),
      GoRoute(
        path: AppRoutes.approvals,
        builder: (context, state) => const ApprovalsPage(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) => const ChatPage(),
      ),
    ],
  );
}
