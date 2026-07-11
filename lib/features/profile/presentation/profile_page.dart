import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/user_type.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/providers/session_provider.dart';
import '../../student_context/providers/student_context_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You\'ll need to sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
              // Overrides the app-wide FilledButton minimumSize (a full-width
              // 54px-tall CTA, meant for screens like login) - a dialog
              // action needs to sit at the same compact scale as the
              // Cancel TextButton beside it, not stretch to fill the row.
              minimumSize: const Size(64, 40),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<SessionProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final session = context.watch<SessionProvider>();
    final user = session.currentUser;
    final isParent = user?.userType == UserType.parent;
    final activeStudent = context.watch<StudentContextProvider>().activeStudent;
    final isLoadingDetails = isParent ? activeStudent == null : !session.isProfileEnriched;

    final initial = (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.l, AppSpacing.l, 0),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.l),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: AppGradients.brand(colorScheme),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            child: Text(
                              initial,
                              style: textTheme.headlineMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Text(
                          user?.name ?? '',
                          style: textTheme.titleLarge?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            isParent ? 'Parent' : 'Staff',
                            style: textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isLoadingDetails) ...[
                          const SizedBox(height: AppSpacing.m),
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.xs),
                      child: Column(
                        children: [
                          _ProfileRow(icon: Icons.email_outlined, label: 'Email', value: user?.email ?? '-'),
                          const Divider(height: 1),
                          _ProfileRow(icon: Icons.phone_outlined, label: 'Phone', value: user?.phone ?? '-'),
                          if (isParent) ...[
                            const Divider(height: 1),
                            _ProfileRow(
                              icon: Icons.school_outlined,
                              label: 'Student',
                              value: activeStudent?.name ?? '-',
                            ),
                            const Divider(height: 1),
                            _ProfileRow(
                              icon: Icons.badge_outlined,
                              label: 'Student Code',
                              value: activeStudent?.studentCode ?? '-',
                            ),
                            const Divider(height: 1),
                            _ProfileRow(
                              icon: Icons.cake_outlined,
                              label: 'Date of Birth',
                              value: activeStudent?.dateOfBirth != null
                                  ? _formatDate(activeStudent!.dateOfBirth!)
                                  : '-',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Card(
                color: colorScheme.errorContainer.withValues(alpha: 0.4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _confirmLogout(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: colorScheme.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.logout, color: colorScheme.error, size: 18),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Text(
                          'Log Out',
                          style: textTheme.titleMedium?.copyWith(color: colorScheme.error),
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right, color: colorScheme.error),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: colorScheme.primary, size: 18),
          ),
          const SizedBox(width: AppSpacing.m),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
