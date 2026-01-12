import 'package:contractor/core/utils/network_utils.dart';

class ApiConfig {
  // Use dynamic IP detection
  static Future<String> get baseUrl async {
    await NetworkUtils.getLocalIpAddress();
    return staticBaseUrl;
  }

  // Static base URL for synchronous operations (use with caution)
  static String staticBaseUrl = 'http://192.168.1.118:8080';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
