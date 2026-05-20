import '../../../../core/network/api_client.dart';

class AttendanceService {
  AttendanceService(this._api);
  final ApiClient _api;

  Future<List<Map<String, dynamic>>> all() async => _list('/attendance');
  Future<List<Map<String, dynamic>>> my() async => _list('/attendance/my');
  Future<Map<String, dynamic>> today() async => Map<String, dynamic>.from(await _api.get('/attendance/today'));
  Future<Map<String, dynamic>> checkIn() async => Map<String, dynamic>.from(await _api.post('/attendance/check-in'));
  Future<Map<String, dynamic>> checkOut() async => Map<String, dynamic>.from(await _api.post('/attendance/check-out'));

  Future<List<Map<String, dynamic>>> _list(String path) async {
    final data = await _api.get(path);
    return List<Map<String, dynamic>>.from((data as List).map((e) => Map<String, dynamic>.from(e)));
  }
}
