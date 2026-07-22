import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/user_type.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatting.dart';
import '../../../core/widgets/approval_action_bar.dart';
import '../../auth/providers/session_provider.dart';
import '../../student_context/providers/student_context_provider.dart';
import '../data/approval_repository.dart';
import '../models/approval_detail.dart';
import '../models/approval_response_status.dart';
import 'widgets/approval_response_chip.dart';

/// Staff see every student's response (read-only - only parents respond).
/// Parents see just their own student's response, with an Approve/Decline
/// action while it's Pending.
class ApprovalDetailPage extends StatefulWidget {
  final String approvalId;

  const ApprovalDetailPage({super.key, required this.approvalId});

  @override
  State<ApprovalDetailPage> createState() => _ApprovalDetailPageState();
}

class _ApprovalDetailPageState extends State<ApprovalDetailPage> {
  late final Future<ApprovalDetail> _future = _load();

  Future<ApprovalDetail> _load() => context.read<ApprovalRepository>().fetchApprovalDetail(widget.approvalId);

  @override
  Widget build(BuildContext context) {
    final userType = context.watch<SessionProvider>().currentUser?.userType;
    final isParent = userType == UserType.parent;
    final myStudentId = isParent ? context.watch<StudentContextProvider>().activeStudent?.id : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Approval')),
      body: FutureBuilder<ApprovalDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Couldn't load this approval"));
          }

          final detail = snapshot.data!;
          final summary = detail.summary;
          final colorScheme = Theme.of(context).colorScheme;
          final textTheme = Theme.of(context).textTheme;

          ApprovalStudentResponse? myResponse;
          if (isParent && myStudentId != null) {
            for (final student in detail.students) {
              if (student.studentId == myStudentId) {
                myResponse = student;
                break;
              }
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(summary.title, style: textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(
                  '${summary.approvalType} · ${summary.grade}',
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.l),
                _DetailRow(label: 'From', value: formatShortDate(summary.fromDate)),
                _DetailRow(label: 'To', value: formatShortDate(summary.toDate)),
                _DetailRow(label: 'Respond By', value: formatShortDate(summary.respondBeforeDate)),
                const SizedBox(height: AppSpacing.l),
                Text(detail.description),
                const SizedBox(height: AppSpacing.l),
                if (isParent) ...[
                  if (myResponse != null) ...[
                    Row(
                      children: [
                        Text('Your Response', style: textTheme.titleMedium),
                        const Spacer(),
                        ApprovalResponseChip(status: myResponse.responseStatus),
                      ],
                    ),
                    if (myResponse.responseRemarks != null) ...[
                      const SizedBox(height: AppSpacing.s),
                      Text(myResponse.responseRemarks!, style: TextStyle(color: colorScheme.onSurfaceVariant)),
                    ],
                    if (myResponse.responseStatus == ApprovalResponseStatus.pending) ...[
                      const SizedBox(height: AppSpacing.l),
                      ApprovalActionBar(
                        itemNoun: 'request',
                        declineLabel: 'Decline',
                        onDecide: ({required approve, note}) async {
                          await context.read<ApprovalRepository>().updateParentResponse(
                                mappingId: myResponse!.mappingId,
                                approve: approve,
                                responseRemarks: note,
                              );
                          if (context.mounted) Navigator.of(context).pop(true);
                        },
                      ),
                    ],
                  ] else
                    Text(
                      'This approval does not include your student',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                ] else ...[
                  Text('Responses', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.s),
                  for (final student in detail.students)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(student.studentName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                if (student.responseRemarks != null)
                                  Text(
                                    student.responseRemarks!,
                                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                  ),
                              ],
                            ),
                          ),
                          ApprovalResponseChip(status: student.responseStatus),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
