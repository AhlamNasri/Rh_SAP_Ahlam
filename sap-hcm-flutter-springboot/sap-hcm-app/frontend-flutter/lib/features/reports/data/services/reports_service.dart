import '../../../../core/network/api_client.dart';

class ReportsService {
  ReportsService(this._api);
  final ApiClient _api;

  Future<Map<String, dynamic>> getReport(String type) async => Map<String, dynamic>.from(await _api.get('/reports/$type'));
}
