import '../../../core/network/api_client.dart';
import '../models/approval_detail.dart';
import '../models/approval_response_status.dart';
import '../models/approval_summary.dart';
import '../models/master_option.dart';

class ApprovalRepository {
  final ApiClient _apiClient;

  ApprovalRepository(this._apiClient);

  /// Not scoped by grade/student - every approval comes back. Parents
  /// filter to their student client-side (see `ApprovalsPage`).
  Future<List<ApprovalSummary>> fetchApprovalList() async {
    final result = await _apiClient.getResult('/Approval/GetApprovalList');
    return (result as List)
        .map((item) => ApprovalSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ApprovalDetail> fetchApprovalDetail(String id) async {
    final result = await _apiClient.getResult('/Approval/GetApprovalById', queryParameters: {'id': id});
    return ApprovalDetail.fromJson(result as Map<String, dynamic>);
  }

  Future<List<MasterOption>> fetchGrades() => _fetchMasterList(1);

  Future<List<MasterOption>> fetchApprovalTypes() => _fetchMasterList(3);

  Future<List<MasterOption>> _fetchMasterList(int masterType) async {
    final result = await _apiClient.getResult('/Approval/GetMasterList', queryParameters: {'type': masterType});
    return (result as List)
        .map((item) => MasterOption.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Used by staff when creating an approval, to pick which students in
  /// the chosen grade to include.
  Future<List<ApprovalStudentResponse>> fetchStudentsByGrade(String gradeId) async {
    final result = await _apiClient.getResult(
      '/Approval/GetStudentsByGrade',
      queryParameters: {'gradeId': gradeId},
    );
    return (result as List)
        .map((item) => ApprovalStudentResponse.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createApproval({
    required String approvalTypeId,
    required String gradeId,
    required String title,
    required DateTime fromDate,
    required DateTime toDate,
    required DateTime respondBeforeDate,
    required String description,
    required List<String> studentIds,
  }) async {
    await _apiClient.postResult(
      '/Approval/CreateApproval',
      data: {
        'Id': 0,
        'ApprovalTypeId': int.parse(approvalTypeId),
        'GradeId': int.parse(gradeId),
        'Title': title.trim(),
        'FromDate': fromDate.toIso8601String(),
        'ToDate': toDate.toIso8601String(),
        'RespondBeforeDate': respondBeforeDate.toIso8601String(),
        'Description': description.trim(),
        'StudentIds': studentIds.map(int.parse).toList(),
      },
    );
  }

  Future<void> updateParentResponse({
    required String mappingId,
    required bool approve,
    String? responseRemarks,
  }) async {
    await _apiClient.postResult(
      '/Approval/UpdateParentResponse',
      data: {
        'MappingId': int.parse(mappingId),
        'ResponseStatus':
            approve ? ApprovalResponseStatus.approved.value : ApprovalResponseStatus.rejected.value,
        if (responseRemarks != null && responseRemarks.trim().isNotEmpty) 'ResponseRemarks': responseRemarks.trim(),
      },
    );
  }
}
