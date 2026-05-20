import '../../../../core/network/api_client.dart';

class DashboardService {
  DashboardService(this._api);
  final ApiClient _api;

  Future<Map<String, dynamic>> stats() async => Map<String, dynamic>.from(await _api.get('/dashboard/stats'));
  Future<List<Map<String, dynamic>>> employeesByDepartment() async => _list('/dashboard/employees-by-department');
  Future<List<Map<String, dynamic>>> leavesByMonth() async => _list('/dashboard/leaves-by-month');
  Future<List<Map<String, dynamic>>> attendanceSummary() async => _list('/dashboard/attendance-summary');

  Future<List<Map<String, dynamic>>> _list(String path) async {
    final data = await _api.get(path);
    return List<Map<String, dynamic>>.from((data as List).map((e) => Map<String, dynamic>.from(e)));
  }
}
