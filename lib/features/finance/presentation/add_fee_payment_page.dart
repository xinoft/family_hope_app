import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatting.dart';
import '../../../core/widgets/gradient_button.dart';
import '../data/finance_repository.dart';
import '../models/fee_template.dart';

/// Staff-only form to record a payment for one student - pushed with a
/// plain [MaterialPageRoute] (not a go_router route) since it's an
/// ephemeral action tied to whichever student is currently selected on
/// the Finance page, not a stable destination. Pops with `true` on
/// success so the caller knows to refresh its payment list.
class AddFeePaymentPage extends StatefulWidget {
  final String studentId;
  final String studentName;

  const AddFeePaymentPage({super.key, required this.studentId, required this.studentName});

  @override
  State<AddFeePaymentPage> createState() => _AddFeePaymentPageState();
}

class _AddFeePaymentPageState extends State<AddFeePaymentPage> {
  late final Future<List<FeeTemplate>> _templatesFuture =
      context.read<FinanceRepository>().fetchFeeTemplates();

  final _amountController = TextEditingController();
  final _adjustmentController = TextEditingController(text: '0');
  final _remarksController = TextEditingController();

  FeeTemplate? _selectedTemplate;
  DateTime _paidDate = DateTime.now();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _amountController.dispose();
    _adjustmentController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _onTemplateSelected(FeeTemplate template) {
    setState(() {
      _selectedTemplate = template;
      _amountController.text = template.amount.toStringAsFixed(2);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paidDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _paidDate = picked);
  }

  Future<void> _submit() async {
    final template = _selectedTemplate;
    if (template == null) {
      setState(() => _error = 'Please choose a fee template');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await context.read<FinanceRepository>().payFee(
            feeTemplateId: template.id,
            studentId: widget.studentId,
            amount: double.tryParse(_amountController.text),
            adjustmentAmount: double.tryParse(_adjustmentController.text) ?? 0,
            paidDate: _paidDate,
            remarks: _remarksController.text,
          );
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = "Couldn't record this payment");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('Add Payment - ${widget.studentName}')),
      body: FutureBuilder<List<FeeTemplate>>(
        future: _templatesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Couldn't load fee templates"));
          }

          final templates = snapshot.data!;
          if (templates.isEmpty) {
            return const Center(child: Text('No fee templates configured yet'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<FeeTemplate>(
                  initialValue: _selectedTemplate,
                  decoration: const InputDecoration(labelText: 'Fee Template'),
                  isExpanded: true,
                  items: [
                    for (final template in templates)
                      DropdownMenuItem(
                        value: template,
                        child: Text(template.label, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (template) {
                    if (template != null) _onTemplateSelected(template);
                  },
                ),
                const SizedBox(height: AppSpacing.m),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Amount (QAR)'),
                ),
                const SizedBox(height: AppSpacing.m),
                TextField(
                  controller: _adjustmentController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: const InputDecoration(
                    labelText: 'Adjustment Amount (QAR)',
                    helperText: 'Positive to add, negative to discount - optional',
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(16),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Paid Date'),
                    child: Text(formatShortDate(_paidDate)),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                TextField(
                  controller: _remarksController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Remarks (optional)'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.m),
                  Text(_error!, style: TextStyle(color: colorScheme.error)),
                ],
                const SizedBox(height: AppSpacing.l),
                GradientButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Record Payment'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
