import '../../../../core/network/api_client.dart';

class PayrollService {
  PayrollService(this._api);
  final ApiClient _api;

  Future<List<Map<String, dynamic>>> all() async => _list('/payroll');
  Future<List<Map<String, dynamic>>> my() async => _list('/payroll/my');
  Future<Map<String, dynamic>> detail(int id) async => Map<String, dynamic>.from(await _api.get('/payroll/$id'));

  Future<List<Map<String, dynamic>>> _list(String path) async {
    final data = await _api.get(path);
    return List<Map<String, dynamic>>.from((data as List).map((e) => Map<String, dynamic>.from(e)));
  }
}
