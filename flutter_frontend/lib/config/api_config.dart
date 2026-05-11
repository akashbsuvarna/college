import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // CHANGE THIS to your machine's local IP address for physical device testing
  static const String machineIp = "192.168.1.10"; 

  static String get baseUrl {
    // Production URL
    return "https://college-sys-backend.vercel.app/api";
  }

  static const String adminPath = "/admin";
}
