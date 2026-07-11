import '../../../core/network/api_client.dart';
import '../models/staff_profile.dart';

class UserRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  Future<StaffProfile> fetchUserById(String id) async {
    final result = await _apiClient.getResult('/UserAccount/GetUserAccountById', queryParameters: {'id': id});
    return StaffProfile.fromJson(result as Map<String, dynamic>);
  }
}
