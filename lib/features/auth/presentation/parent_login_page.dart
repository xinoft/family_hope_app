import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/routes.dart';
import '../providers/session_provider.dart';
import 'widgets/login_form.dart';

/// The default screen of the unauthenticated flow - parents are the
/// primary audience, staff reach their own login via the footer link.
///
/// Only signs in here - seeding the parent's student context happens
/// centrally in `bootstrap.dart`'s session listener, which also covers a
/// session restored from storage on app relaunch (a case this page never
/// runs for).
class ParentLoginPage extends StatelessWidget {
  const ParentLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginForm(
      title: 'Parent Login',
      subtitle: 'Sign in to stay connected with your child\'s school',
      onSubmit: () => context.read<SessionProvider>().loginAsParent(),
      footerPrompt: 'Are you a staff member? ',
      footerActionLabel: 'Staff Login',
      onFooterActionTap: () => context.go(AppRoutes.staffLogin),
    );
  }
}
