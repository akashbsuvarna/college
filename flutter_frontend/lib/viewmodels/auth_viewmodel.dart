import 'package:flutter/material.dart';
import 'package:flutter_frontend/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final _service = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated => _user != null;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.login(email, password);
    if (response['success']) {
      _user = response['user'];
    } else {
      _errorMessage = response['message'];
    }

    _isLoading = false;
    notifyListeners();
  }



  Future<void> logout() async {
    await _service.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final response = await _service.getProfile();
    if (response['success']) {
      _user = response['user'];
      notifyListeners();
    } else {
      // If token is invalid or profile fetch fails, clear the session
      await logout();
    }
  }
}
