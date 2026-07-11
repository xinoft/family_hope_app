import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/routes.dart';
import '../../../core/constants/app_module.dart';
import '../../../core/constants/user_type.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_module_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/permission_gate.dart';
import '../../auth/providers/session_provider.dart';
import '../../student_context/providers/student_context_provider.dart';

class _ModuleTile {
  final AppModule module;
  final String label;
  final IconData icon;
  final String route;

  const _ModuleTile(this.module, this.label, this.icon, this.route);
}

const _moduleTiles = [
  _ModuleTile(AppModule.circulars, 'Circulars', Icons.campaign_outlined, AppRoutes.circulars),
  _ModuleTile(AppModule.attendance, 'Attendance', Icons.event_available_outlined, AppRoutes.attendance),
  _ModuleTile(AppModule.timetable, 'Timetable', Icons.schedule_outlined, AppRoutes.timetable),
  _ModuleTile(AppModule.meetings, 'Meetings', Icons.groups_outlined, AppRoutes.meetings),
  _ModuleTile(AppModule.goals, 'Goals', Icons.flag_outlined, AppRoutes.goals),
  _ModuleTile(AppModule.reports, 'Reports', Icons.description_outlined, AppRoutes.reports),
  _ModuleTile(AppModule.finance, 'Finance', Icons.payments_outlined, AppRoutes.finance),
  _ModuleTile(AppModule.gallery, 'Gallery', Icons.photo_library_outlined, AppRoutes.gallery),
  _ModuleTile(AppModule.approvals, 'Approvals', Icons.fact_check_outlined, AppRoutes.approvals),
  _ModuleTile(AppModule.chat, 'Chat', Icons.chat_bubble_outline, AppRoutes.chat),
];

/// Post-login landing page. Shared by staff and parents - the module grid
/// itself never checks `userType`, each tile is hidden/shown purely via
/// [PermissionGate] on the view capability, so a future role just needs a
/// `PersonaPolicy` entry, not a shell change.
class HomeShellPage extends StatelessWidget {
  const HomeShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final isParent = session.currentUser?.userType == UserType.parent;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.l, AppSpacing.l, 0),
              sliver: SliverToBoxAdapter(
                child: _HomeHeader(
                  userName: session.currentUser?.name ?? '',
                  isParent: isParent,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.l),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.m,
                  crossAxisSpacing: AppSpacing.m,
                  childAspectRatio: 1.5,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tile = _moduleTiles[index];
                    return PermissionGate(
                      module: tile.module,
                      action: CapabilityAction.view,
                      child: _ModuleCard(tile: tile),
                    );
                  },
                  childCount: _moduleTiles.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final String userName;
  final bool isParent;

  const _HomeHeader({required this.userName, required this.isParent});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back${userName.isNotEmpty ? ', $userName' : ''}',
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                isParent ? 'Here\'s what\'s happening with your child' : 'Here\'s your school overview',
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        if (isParent) const _StudentSwitcher(),
        const SizedBox(width: AppSpacing.xs),
        const _ProfileAvatar(),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = context.watch<SessionProvider>().currentUser;
    final initial = (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : '?';

    return InkWell(
      onTap: () => context.push(AppRoutes.profile),
      customBorder: const CircleBorder(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppGradients.brand(colorScheme),
        ),
        alignment: Alignment.center,
        child: Text(
          initial,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final _ModuleTile tile;

  const _ModuleCard({required this.tile});

  @override
  Widget build(BuildContext context) {
    final accent = AppModuleColors.of(tile.module);

    return Card(
      color: Color.alphaBlend(accent.withValues(alpha: 0.10), Theme.of(context).colorScheme.surface),
      child: InkWell(
        onTap: () => context.push(tile.route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Icon(tile.icon, color: accent, size: 20),
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                tile.label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lets a parent with more than one linked student switch which student
/// the rest of the app is scoped to. Hidden entirely when there's only
/// one (which is all the backend supports today).
class _StudentSwitcher extends StatelessWidget {
  const _StudentSwitcher();

  @override
  Widget build(BuildContext context) {
    final studentContext = context.watch<StudentContextProvider>();
    if (!studentContext.hasMultipleStudents) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.switch_account_outlined),
      tooltip: 'Switch student',
      onSelected: (studentId) =>
          context.read<StudentContextProvider>().switchStudent(studentId),
      itemBuilder: (context) => [
        for (final student in studentContext.students)
          PopupMenuItem(value: student.id, child: Text(student.name)),
      ],
    );
  }
}
