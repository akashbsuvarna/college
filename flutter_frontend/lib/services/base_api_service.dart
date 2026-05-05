import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class BaseApiService {
  final http.Client client = http.Client();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<Map<String, String>> get _headers async {
    final token = await _getToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  Future<http.Response> get(String path) async {
    final url = Uri.parse("${ApiConfig.baseUrl}$path");
    return await client.get(url, headers: await _headers);
  }

  Future<http.Response> post(String path, dynamic body) async {
    final url = Uri.parse("${ApiConfig.baseUrl}$path");
    return await client.post(url, headers: await _headers, body: jsonEncode(body));
  }

  Future<http.Response> put(String path, dynamic body) async {
    final url = Uri.parse("${ApiConfig.baseUrl}$path");
    return await client.put(url, headers: await _headers, body: jsonEncode(body));
  }

  Future<http.Response> delete(String path) async {
    final url = Uri.parse("${ApiConfig.baseUrl}$path");
    return await client.delete(url, headers: await _headers);
  }
}
