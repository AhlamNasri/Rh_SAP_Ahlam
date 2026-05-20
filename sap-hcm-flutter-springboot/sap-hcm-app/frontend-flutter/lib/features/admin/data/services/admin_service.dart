import '../../../../core/network/api_client.dart';

class AdminService {
  AdminService(this._api);
  final ApiClient _api;

  Future<List<Map<String, dynamic>>> users() async {
    final data = await _api.get('/admin/users');
    return List<Map<String, dynamic>>.from((data as List).map((e) => Map<String, dynamic>.from(e)));
  }

  Future<Map<String, dynamic>> updateRole(int id, String role) async => Map<String, dynamic>.from(await _api.put('/admin/users/$id/role', data: {'role': role}));
  Future<Map<String, dynamic>> updateStatus(int id, bool enabled) async => Map<String, dynamic>.from(await _api.put('/admin/users/$id/status', data: {'enabled': enabled}));
}
