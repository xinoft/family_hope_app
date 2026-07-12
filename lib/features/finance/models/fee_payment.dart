/// Mirrors `Finance/GetPaymentTracking`'s items - see
/// `InkersCore.Models.DataModels.FeePaymentData`.
class FeePayment {
  final String id;
  final String templateName;
  final String studentName;
  final String studentCode;
  final String schoolCycle;
  final String period;
  final double amount;
  final double adjustmentAmount;
  final DateTime paidDate;
  final String? remarks;

  const FeePayment({
    required this.id,
    required this.templateName,
    required this.studentName,
    required this.studentCode,
    required this.schoolCycle,
    required this.period,
    required this.amount,
    required this.adjustmentAmount,
    required this.paidDate,
    this.remarks,
  });

  double get totalAmount => amount + adjustmentAmount;

  factory FeePayment.fromJson(Map<String, dynamic> json) {
    return FeePayment(
      id: (json['Id'] ?? 0).toString(),
      templateName: json['TemplateName'] as String? ?? '',
      studentName: json['StudentName'] as String? ?? '',
      studentCode: json['StudentCode'] as String? ?? '',
      schoolCycle: json['SchoolCycle'] as String? ?? '',
      period: json['Period'] as String? ?? '',
      amount: (json['Amount'] as num?)?.toDouble() ?? 0,
      adjustmentAmount: (json['AdjustmentAmount'] as num?)?.toDouble() ?? 0,
      paidDate: DateTime.tryParse(json['PaidDate'] as String? ?? '') ?? DateTime.now(),
      remarks: (json['Remarks'] as String?)?.trim().isNotEmpty == true ? json['Remarks'] as String : null,
    );
  }
}
