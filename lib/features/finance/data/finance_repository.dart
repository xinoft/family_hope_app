import '../../../core/network/api_client.dart';
import '../models/fee_payment.dart';
import '../models/fee_template.dart';

class FinanceRepository {
  final ApiClient _apiClient;

  FinanceRepository(this._apiClient);

  /// `FeeTemplateId: 0` and no `SchoolCycle` mean "no filter" on the
  /// backend (see `FinanceRepository.GetPaymentTracking`'s LINQ query) -
  /// this returns every payment ever recorded for the student, across all
  /// templates/cycles.
  Future<List<FeePayment>> fetchPaymentsForStudent(String studentId) async {
    final result = await _apiClient.postResult(
      '/Finance/GetPaymentTracking',
      data: {
        'FeeTemplateId': 0,
        'StudentIds': [int.parse(studentId)],
        'SchoolCycle': null,
      },
    );
    return (result as List)
        .map((item) => FeePayment.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<FeeTemplate>> fetchFeeTemplates() async {
    final result = await _apiClient.getResult('/Finance/GetFeeTemplateList');
    return (result as List)
        .map((item) => FeeTemplate.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// [amount] left null (or 0) lets the backend default to the template's
  /// own amount; [paidDate] left null defaults to now; the school cycle
  /// isn't sent at all - the backend always prefers its own `school_cycle`
  /// registry value over whatever a caller sends (see `PayFees`).
  Future<void> payFee({
    required String feeTemplateId,
    required String studentId,
    double? amount,
    double adjustmentAmount = 0,
    DateTime? paidDate,
    String? remarks,
  }) async {
    await _apiClient.postResult(
      '/Finance/PayFees',
      data: {
        'FeeTemplateId': int.parse(feeTemplateId),
        'StudentId': int.parse(studentId),
        'Amount': amount ?? 0,
        'AdjustmentAmount': adjustmentAmount,
        if (paidDate != null) 'PaidDate': paidDate.toIso8601String(),
        if (remarks != null && remarks.trim().isNotEmpty) 'Remarks': remarks.trim(),
      },
    );
  }
}
