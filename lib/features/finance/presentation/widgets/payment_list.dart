import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_module_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatting.dart';
import '../../../../core/constants/app_module.dart';
import '../../data/finance_repository.dart';
import '../../models/fee_payment.dart';

/// Every payment ever recorded for one student - the API isn't paginated
/// for this endpoint, so this just fetches everything in one call.
class PaymentList extends StatefulWidget {
  final String studentId;

  const PaymentList({super.key, required this.studentId});

  @override
  State<PaymentList> createState() => _PaymentListState();
}

class _PaymentListState extends State<PaymentList> {
  late Future<List<FeePayment>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = context.read<FinanceRepository>().fetchPaymentsForStudent(widget.studentId);
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FeePayment>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _MessageState(
            message: "Couldn't load payments",
            actionLabel: 'Retry',
            onAction: () => setState(_load),
          );
        }

        final payments = snapshot.data!;
        if (payments.isEmpty) {
          return const _MessageState(message: 'No payments recorded yet');
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.m),
            itemCount: payments.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.s),
            itemBuilder: (context, index) => _PaymentCard(payment: payments[index]),
          ),
        );
      },
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final FeePayment payment;

  const _PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = AppModuleColors.of(AppModule.finance);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(11)),
              alignment: Alignment.center,
              child: Icon(Icons.receipt_long_outlined, color: accent, size: 20),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(payment.templateName, style: textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${payment.period} · ${payment.schoolCycle} · Paid ${formatShortDate(payment.paidDate)}',
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  if (payment.remarks != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      payment.remarks!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'QAR ${payment.totalAmount.toStringAsFixed(2)}',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (payment.adjustmentAmount != 0)
                  Text(
                    '${payment.adjustmentAmount > 0 ? '+' : ''}${payment.adjustmentAmount.toStringAsFixed(2)} adj.',
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageState({required this.message, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 40, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: AppSpacing.m),
          Text(message, style: TextStyle(color: colorScheme.onSurfaceVariant)),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.m),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
