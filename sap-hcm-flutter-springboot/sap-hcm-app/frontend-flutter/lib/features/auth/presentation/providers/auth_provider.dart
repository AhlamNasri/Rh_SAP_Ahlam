import 'package:flutter/material.dart';

import '../../../../core/storage/token_storage.dart';
import '../../data/models/auth_user.dart';
import '../../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService, this._tokenStorage);

  final AuthService _authService;
  final TokenStorage _tokenStorage;

  AuthUser? user;
  bool isLoading = true;
  String? error;

  bool get isAuthenticated => user != null;
  List<String> get roles => user?.roles ?? const [];
  bool hasRole(String role) => roles.contains(role);
  bool hasAnyRole(List<String> expected) => expected.any(roles.contains);

  Future<void> bootstrap() async {
    isLoading = true;
    notifyListeners();
    final token = await _tokenStorage.readToken();
    if (token == null) {
      isLoading = false;
      notifyListeners();
      return;
    }
    try {
      user = await _authService.me(token);
      error = null;
    } catch (_) {
      await _tokenStorage.clear();
      user = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final logged = await _authService.login(email, password);
      await _tokenStorage.saveToken(logged.token);
      user = logged;
      return true;
    } catch (e) {
      error = e.toString();
      user = null;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
    user = null;
    notifyListeners();
  }
}
