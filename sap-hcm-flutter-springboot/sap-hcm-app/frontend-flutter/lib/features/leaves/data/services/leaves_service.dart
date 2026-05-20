import '../../../../core/network/api_client.dart';

class LeavesService {
  LeavesService(this._api);
  final ApiClient _api;

  Future<List<Map<String, dynamic>>> all() async => _list('/leaves');
  Future<List<Map<String, dynamic>>> my() async => _list('/leaves/my');
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async => Map<String, dynamic>.from(await _api.post('/leaves', data: data));
  Future<Map<String, dynamic>> approve(int id) async => Map<String, dynamic>.from(await _api.put('/leaves/$id/approve'));
  Future<Map<String, dynamic>> reject(int id) async => Map<String, dynamic>.from(await _api.put('/leaves/$id/reject'));
  Future<void> delete(int id) async => _api.delete('/leaves/$id');

  Future<List<Map<String, dynamic>>> _list(String path) async {
    final data = await _api.get(path);
    return List<Map<String, dynamic>>.from((data as List).map((e) => Map<String, dynamic>.from(e)));
  }
}
