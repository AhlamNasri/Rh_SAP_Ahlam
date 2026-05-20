import '../../../../core/network/api_client.dart';

class PerformanceService {
  PerformanceService(this._api);
  final ApiClient _api;

  Future<List<Map<String, dynamic>>> all() async => _list('/performance');
  Future<List<Map<String, dynamic>>> my() async => _list('/performance/my');
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async => Map<String, dynamic>.from(await _api.post('/performance', data: data));

  Future<List<Map<String, dynamic>>> _list(String path) async {
    final data = await _api.get(path);
    return List<Map<String, dynamic>>.from((data as List).map((e) => Map<String, dynamic>.from(e)));
  }
}
