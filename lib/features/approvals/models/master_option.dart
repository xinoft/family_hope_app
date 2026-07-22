/// A generic `{Id, Value}` master-data row - mirrors
/// `Approval/GetMasterList`'s items (grades, approval types) - see
/// `InkersCore.Models.SharedEntityModels.MasterEntity`.
class MasterOption {
  final String id;
  final String value;

  const MasterOption({required this.id, required this.value});

  factory MasterOption.fromJson(Map<String, dynamic> json) {
    return MasterOption(
      id: (json['Id'] ?? 0).toString(),
      value: json['Value'] as String? ?? '',
    );
  }
}
