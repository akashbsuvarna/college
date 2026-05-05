import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_stats_model.dart';
import '../../core/app_constants.dart';
import '../../../services/auth_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final _authService = AuthService();
  DashboardStats? _stats;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DashboardViewModel() {
    loadStats();
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> loadStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse(AppConstants.dashboardStats), headers: headers)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        _stats = DashboardStats.fromJson(json);
      } else {
        _errorMessage = 'Stats load failed: ${response.statusCode}';
        print("Stats Error: ${response.body}");
      }
    } catch (e) {
      _errorMessage = 'Connection error. Check backend.';
      print("Stats Exception: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => loadStats();
}
