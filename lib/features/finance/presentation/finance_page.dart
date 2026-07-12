import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_module.dart';
import '../../../core/constants/user_type.dart';
import '../../../core/widgets/permission_gate.dart';
import '../../auth/providers/session_provider.dart';
import '../../student_context/data/student_repository.dart';
import '../../student_context/models/student_summary.dart';
import '../../student_context/presentation/widgets/student_context_header.dart';
import '../../student_context/presentation/widgets/student_picker.dart';
import '../../student_context/providers/student_context_provider.dart';
import 'add_fee_payment_page.dart';
import 'widgets/payment_list.dart';

/// Parents see their current student's payments directly. Staff pick a
/// student first (there's no "current student" for staff), then see the
/// same list, plus an Add Payment action (gated by the `add` capability -
/// granted to staff, never to parents, via `PersonaPolicy`).
class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  StudentSummary? _staffSelectedStudent;
  int _refreshToken = 0;

  Future<void> _openAddPayment(String studentId, String studentName) async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddFeePaymentPage(studentId: studentId, studentName: studentName),
      ),
    );
    if (added == true) setState(() => _refreshToken++);
  }

  @override
  Widget build(BuildContext context) {
    final userType = context.watch<SessionProvider>().currentUser?.userType;

    String? studentId;
    String? studentName;
    Widget content;

    if (userType == UserType.parent) {
      final activeStudent = context.watch<StudentContextProvider>().activeStudent;
      if (activeStudent == null) {
        content = const Center(child: CircularProgressIndicator());
      } else {
        studentId = activeStudent.id;
        studentName = activeStudent.name;
        content = PaymentList(key: ValueKey('payments-${activeStudent.id}-$_refreshToken'), studentId: activeStudent.id);
      }
    } else if (_staffSelectedStudent == null) {
      content = StudentPicker(
        repository: context.read<StudentRepository>(),
        onSelected: (student) => setState(() => _staffSelectedStudent = student),
      );
    } else {
      final student = _staffSelectedStudent!;
      studentId = student.id;
      studentName = student.name;
      content = Column(
        children: [
          StudentContextHeader(
            name: student.name,
            onChange: () => setState(() => _staffSelectedStudent = null),
          ),
          Expanded(
            child: PaymentList(key: ValueKey('payments-${student.id}-$_refreshToken'), studentId: student.id),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Finance')),
      body: content,
      floatingActionButton: studentId == null
          ? null
          : PermissionGate(
              module: AppModule.finance,
              action: CapabilityAction.add,
              child: FloatingActionButton.extended(
                onPressed: () => _openAddPayment(studentId!, studentName!),
                icon: const Icon(Icons.add),
                label: const Text('Add Payment'),
              ),
            ),
    );
  }
}
