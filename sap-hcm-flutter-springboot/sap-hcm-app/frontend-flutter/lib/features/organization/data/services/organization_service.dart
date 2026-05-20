import '../../../../core/network/api_client.dart';

class OrganizationService {
  OrganizationService(this._api);
  final ApiClient _api;

  Future<Map<String, dynamic>> tree() async => Map<String, dynamic>.from(await _api.get('/organization/tree'));
}
