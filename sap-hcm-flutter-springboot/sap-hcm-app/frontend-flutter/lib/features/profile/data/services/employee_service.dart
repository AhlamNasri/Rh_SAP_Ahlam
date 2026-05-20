import '../../../../core/network/api_client.dart';

class EmployeeService {
  EmployeeService(this._api);
  final ApiClient _api;

  Future<Map<String, dynamic>> me() async => Map<String, dynamic>.from(await _api.get('/employees/me'));
  Future<List<Map<String, dynamic>>> all() async => _list('/employees');
  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> data) async => Map<String, dynamic>.from(await _api.put('/employees/$id', data: data));

  Future<List<Map<String, dynamic>>> _list(String path) async {
    final data = await _api.get(path);
    return List<Map<String, dynamic>>.from((data as List).map((e) => Map<String, dynamic>.from(e)));
  }
}
