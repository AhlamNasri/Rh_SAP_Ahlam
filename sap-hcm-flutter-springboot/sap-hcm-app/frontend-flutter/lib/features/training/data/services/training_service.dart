import '../../../../core/network/api_client.dart';

class TrainingService {
  TrainingService(this._api);
  final ApiClient _api;

  Future<List<Map<String, dynamic>>> all() async => _list('/trainings');
  Future<List<Map<String, dynamic>>> my() async => _list('/trainings/my');
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async => Map<String, dynamic>.from(await _api.post('/trainings', data: data));
  Future<Map<String, dynamic>> enroll(int trainingId, int employeeId) async => Map<String, dynamic>.from(await _api.post('/trainings/$trainingId/enroll', data: {'employeeId': employeeId}));

  Future<List<Map<String, dynamic>>> _list(String path) async {
    final data = await _api.get(path);
    return List<Map<String, dynamic>>.from((data as List).map((e) => Map<String, dynamic>.from(e)));
  }
}
