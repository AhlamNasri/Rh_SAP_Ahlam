import '../../../../core/network/api_client.dart';
import '../models/auth_user.dart';

class AuthService {
  AuthService(this._api);
  final ApiClient _api;

  Future<AuthUser> login(String email, String password) async {
    final data = await _api.post('/auth/login', data: {'email': email, 'password': password});
    return AuthUser.fromLogin(Map<String, dynamic>.from(data));
  }

  Future<AuthUser> me(String token) async {
    final data = await _api.get('/auth/me');
    return AuthUser.fromMe(Map<String, dynamic>.from(data), token);
  }
}
