import '../../../../core/network/api_client.dart';

class RecruitmentService {
  RecruitmentService(this._api);
  final ApiClient _api;

  Future<List<Map<String, dynamic>>> jobs() async => _list('/jobs');
  Future<List<Map<String, dynamic>>> candidates() async => _list('/candidates');
  Future<Map<String, dynamic>> createJob(Map<String, dynamic> data) async => Map<String, dynamic>.from(await _api.post('/jobs', data: data));
  Future<Map<String, dynamic>> updateCandidateStatus(int id, String status) async => Map<String, dynamic>.from(await _api.put('/candidates/$id/status', data: {'status': status}));

  Future<List<Map<String, dynamic>>> _list(String path) async {
    final data = await _api.get(path);
    return List<Map<String, dynamic>>.from((data as List).map((e) => Map<String, dynamic>.from(e)));
  }
}
