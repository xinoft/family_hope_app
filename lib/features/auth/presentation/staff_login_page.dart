import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/routes.dart';
import '../providers/session_provider.dart';
import 'widgets/login_form.dart';

class StaffLoginPage extends StatelessWidget {
  const StaffLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginForm(
      title: 'Staff Login',
      subtitle: 'Sign in with your staff account',
      onSubmit: () => context.read<SessionProvider>().loginAsStaff(),
      footerPrompt: 'Here to check on your child? ',
      footerActionLabel: 'Parent Login',
      onFooterActionTap: () => context.go(AppRoutes.root),
    );
  }
}
