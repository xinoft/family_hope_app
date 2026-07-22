import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_module.dart';
import '../../../core/constants/user_type.dart';
import '../../../core/theme/app_module_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatting.dart';
import '../../../core/widgets/permission_gate.dart';
import '../../auth/providers/session_provider.dart';
import '../../student_context/providers/student_context_provider.dart';
import '../data/approval_repository.dart';
import '../models/approval_detail.dart';
import '../models/approval_summary.dart';
import 'approval_detail_page.dart';
import 'approval_form_page.dart';
import 'widgets/approval_response_chip.dart';

/// Staff see every approval raised for any grade, and can raise new ones.
/// Parents see only approvals that include their active student - found by
/// pre-filtering the (unscoped) list by grade, then checking each
/// candidate's detail for the student, since the backend doesn't offer a
/// student-scoped list endpoint.
class ApprovalsPage extends StatefulWidget {
  const ApprovalsPage({super.key});

  @override
  State<ApprovalsPage> createState() => _ApprovalsPageState();
}

class _ParentApprovalEntry {
  final ApprovalSummary summary;
  final ApprovalStudentResponse response;

  const _ParentApprovalEntry({required this.summary, required this.response});
}

class _ApprovalsViewData {
  final List<ApprovalSummary>? staffApprovals;
  final List<_ParentApprovalEntry>? parentEntries;

  const _ApprovalsViewData.staff(this.staffApprovals) : parentEntries = null;
  const _ApprovalsViewData.parent(this.parentEntries) : staffApprovals = null;
}

class _ApprovalsPageState extends State<ApprovalsPage> {
  late Future<_ApprovalsViewData> _future = _load();

  bool get _isParent => context.read<SessionProvider>().currentUser?.userType == UserType.parent;

  Future<_ApprovalsViewData> _load() async {
    final repo = context.read<ApprovalRepository>();

    if (!_isParent) {
      return _ApprovalsViewData.staff(await repo.fetchApprovalList());
    }

    final activeStudent = context.read<StudentContextProvider>().activeStudent;
    if (activeStudent == null) return const _ApprovalsViewData.parent([]);

    final all = await repo.fetchApprovalList();
    final candidates = all.where((a) => a.gradeId == activeStudent.gradeId).toList();
    final details = await Future.wait(candidates.map((c) => repo.fetchApprovalDetail(c.id)));

    final entries = <_ParentApprovalEntry>[];
    for (final detail in details) {
      for (final response in detail.students) {
        if (response.studentId == activeStudent.id) {
          entries.add(_ParentApprovalEntry(summary: detail.summary, response: response));
          break;
        }
      }
    }
    return _ApprovalsViewData.parent(entries);
  }

  void _refresh() => setState(() => _future = _load());

  Future<void> _openDetail(String approvalId) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ApprovalDetailPage(approvalId: approvalId)),
    );
    if (changed == true) _refresh();
  }

  Future<void> _openCreateForm() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const ApprovalFormPage()),
    );
    if (saved == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approvals')),
      body: FutureBuilder<_ApprovalsViewData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Couldn't load approvals"));
          }

          final data = snapshot.data!;
          if (data.staffApprovals != null) {
            return _StaffApprovalList(
              approvals: data.staffApprovals!,
              onTap: (id) => _openDetail(id),
            );
          }
          return _ParentApprovalList(
            entries: data.parentEntries!,
            onTap: (id) => _openDetail(id),
          );
        },
      ),
      floatingActionButton: PermissionGate(
        module: AppModule.approvals,
        action: CapabilityAction.add,
        child: FloatingActionButton.extended(
          onPressed: _openCreateForm,
          icon: const Icon(Icons.add),
          label: const Text('New Approval'),
        ),
      ),
    );
  }
}

class _StaffApprovalList extends StatelessWidget {
  final List<ApprovalSummary> approvals;
  final ValueChanged<String> onTap;

  const _StaffApprovalList({required this.approvals, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (approvals.isEmpty) {
      return const Center(child: Text('No approvals yet'));
    }

    final accent = AppModuleColors.of(AppModule.approvals);

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.l),
      itemCount: approvals.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.m),
      itemBuilder: (context, index) {
        final approval = approvals[index];
        return Card(
          child: InkWell(
            onTap: () => onTap(approval.id),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(approval.title, style: Theme.of(context).textTheme.titleMedium),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          approval.approvalType,
                          style: TextStyle(color: accent, fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${approval.grade} · ${formatShortDate(approval.fromDate)} - ${formatShortDate(approval.toDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Row(
                    children: [
                      _CountBadge(label: 'Pending', count: approval.pendingCount, color: Colors.amber.shade800),
                      const SizedBox(width: AppSpacing.s),
                      _CountBadge(label: 'Approved', count: approval.approvedCount, color: Colors.green.shade700),
                      const SizedBox(width: AppSpacing.s),
                      _CountBadge(label: 'Declined', count: approval.rejectedCount, color: Colors.red.shade700),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CountBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _CountBadge({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$count $label',
      style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
    );
  }
}

class _ParentApprovalList extends StatelessWidget {
  final List<_ParentApprovalEntry> entries;
  final ValueChanged<String> onTap;

  const _ParentApprovalList({required this.entries, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(child: Text('No approvals for your child yet'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.l),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.m),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Card(
          child: InkWell(
            onTap: () => onTap(entry.summary.id),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(entry.summary.title, style: Theme.of(context).textTheme.titleMedium),
                      ),
                      ApprovalResponseChip(status: entry.response.responseStatus),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${entry.summary.approvalType} · Respond by ${formatShortDate(entry.summary.respondBeforeDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
