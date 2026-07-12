/// Mirrors `Finance/GetFeeTemplateList`'s items - see
/// `InkersCore.Models.DataModels.FeeTemplateData`. Used to populate the
/// fee template picker on the Add Fee Payment form.
class FeeTemplate {
  final String id;
  final String name;
  final String grade;
  final String feeType;
  final String feeMode;
  final double amount;

  const FeeTemplate({
    required this.id,
    required this.name,
    required this.grade,
    required this.feeType,
    required this.feeMode,
    required this.amount,
  });

  String get label => '$name · $feeType · $feeMode';

  factory FeeTemplate.fromJson(Map<String, dynamic> json) {
    return FeeTemplate(
      id: (json['Id'] ?? 0).toString(),
      name: json['Name'] as String? ?? '',
      grade: json['Grade'] as String? ?? '',
      feeType: json['FeeType'] as String? ?? '',
      feeMode: json['FeeMode'] as String? ?? '',
      amount: (json['Amount'] as num?)?.toDouble() ?? 0,
    );
  }
}
