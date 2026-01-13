import 'dart:convert';
import 'package:http/http.dart' as http_package; // Rename this
import 'package:contractor/core/config/api_config.dart';
import 'package:contractor/core/config/api_endpoints.dart';
import 'package:contractor/core/config/api_exceptions.dart';
import 'package:contractor/core/storage/local_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http_package.Client _client = http_package.Client(); // Use renamed
  final LocalStorage _storage = LocalStorage();

  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _storage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<Map<String, dynamic>> _handleResponse(
    http_package.Response response,
  ) async {
    // Use renamed
    final responseBody = json.decode(response.body);

    // Log response for debugging
    print('API Response [${response.statusCode}]: ${response.request?.url}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      final errorMessage =
          responseBody['message'] ??
          responseBody['error'] ??
          'Unknown error occurred';

      switch (response.statusCode) {
        case 400:
          throw ValidationException(message: errorMessage);
        case 401:
          throw UnauthorizedException(message: errorMessage);
        case 404:
          throw ApiException(message: 'Resource not found', statusCode: 404);
        case 500:
          throw ApiException(message: 'Server error', statusCode: 500);
        default:
          throw ApiException(
            message: errorMessage,
            statusCode: response.statusCode,
          );
      }
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = false,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(await ApiEndpoints.buildUrl(endpoint)),
            headers: await _getHeaders(requiresAuth: requiresAuth),
            body: json.encode(data),
          )
          .timeout(ApiConfig.connectTimeout);

      return await _handleResponse(response);
    } on http_package.ClientException catch (e) {
      // Use renamed
      throw ApiException(message: 'Network error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _client
          .get(
            Uri.parse(await ApiEndpoints.buildUrl(endpoint)),
            headers: await _getHeaders(requiresAuth: requiresAuth),
          )
          .timeout(ApiConfig.connectTimeout);

      return await _handleResponse(response);
    } on http_package.ClientException catch (e) {
      // Use renamed
      throw ApiException(message: 'Network error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // Test connection
  Future<bool> testConnection() async {
    try {
      final response = await _client
          .get(
            Uri.parse(await ApiEndpoints.buildUrl(ApiEndpoints.test)),
            headers: await _getHeaders(requiresAuth: false),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse(await ApiEndpoints.buildUrl(endpoint)),
            headers: await _getHeaders(requiresAuth: requiresAuth),
            body: json.encode(data),
          )
          .timeout(ApiConfig.connectTimeout);

      return await _handleResponse(response);
    } on http_package.ClientException catch (e) {
      throw ApiException(message: 'Network error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _client
          .delete(
            Uri.parse(await ApiEndpoints.buildUrl(endpoint)),
            headers: await _getHeaders(requiresAuth: requiresAuth),
          )
          .timeout(ApiConfig.connectTimeout);

      return await _handleResponse(response);
    } on http_package.ClientException catch (e) {
      throw ApiException(message: 'Network error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // Add this method to your ApiClient class
  Future<Map<String, dynamic>> gets(
    String endpoint, {
    bool requiresAuth = true,
    Map<String, dynamic>? queryParameters, // Add this parameter
  }) async {
    try {
      // Build URL with query parameters
      String url = await ApiEndpoints.buildUrl(endpoint);

      if (queryParameters != null && queryParameters.isNotEmpty) {
        final uri = Uri.parse(url);
        url = uri.replace(queryParameters: queryParameters).toString();
      }

      final response = await _client
          .get(
            Uri.parse(url),
            headers: await _getHeaders(requiresAuth: requiresAuth),
          )
          .timeout(ApiConfig.connectTimeout);

      return await _handleResponse(response);
    } on http_package.ClientException catch (e) {
      throw ApiException(message: 'Network error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }
}
