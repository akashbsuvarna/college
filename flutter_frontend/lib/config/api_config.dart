import 'package:flutter/foundation.dart';

class ApiConfig {
  // Local development IP address
  static const String machineIp = "192.168.1.10"; 

  static String get baseUrl {
    if (kDebugMode) {
      // Use local IP for physical devices or localhost for emulator/web
      if (kIsWeb) return "http://localhost:5000/api";
      return "http://10.0.2.2:5000/api"; // Default Android emulator IP
    }
    
    // Production URL
    return "https://college-sys-backend.vercel.app/api";
  }

  static const String adminPath = "/admin";
}

