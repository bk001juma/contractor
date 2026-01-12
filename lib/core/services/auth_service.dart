import 'package:contractor/core/config/api_client.dart';
import 'package:contractor/core/config/api_endpoints.dart';
import 'package:contractor/core/config/api_exceptions.dart';
import 'package:contractor/core/storage/local_storage.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiClient _apiClient = ApiClient();
  final LocalStorage _storage = LocalStorage();

  // Test API connection
  Future<bool> testConnection() async {
    try {
      return await _apiClient.testConnection();
    } catch (e) {
      return false;
    }
  }

  // Register user
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    String userType = 'CLIENT',
  }) async {
    try {
      final data = {
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
        'userType': userType,
      };

      final response = await _apiClient.post(
        ApiEndpoints.register,
        data,
        requiresAuth: false,
      );

      // Extract data from response
      final responseData = response['data'];
      if (responseData != null) {
        final token = responseData['token'];
        final user = responseData['user'];

        if (token != null && user != null) {
          // Save token and user data
          await _storage.saveToken(token);
          await _storage.saveUserData(
            userId: user['id'].toString(),
            userType: user['userType'] ?? 'CLIENT',
            email: user['email'],
          );
        }
      }

      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Registration failed: $e');
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = {'email': email, 'password': password};

      final response = await _apiClient.post(
        ApiEndpoints.login,
        data,
        requiresAuth: false,
      );

      // Extract data from response
      final responseData = response['data'];
      if (responseData != null) {
        final token = responseData['token'];
        final user = responseData['user'];

        if (token != null && user != null) {
          // Save token and user data
          await _storage.saveToken(token);
          await _storage.saveUserData(
            userId: user['id'].toString(),
            userType: user['userType'] ?? 'CLIENT',
            email: user['email'],
          );
        }
      }

      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Login failed: $e');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      return await _apiClient.get(ApiEndpoints.profile);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to get profile: $e');
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.getToken();
    return token != null && token.isNotEmpty;
  }

  // Get current user type
  Future<String?> getUserType() async {
    final userData = await _storage.getUserData();
    return userData['userType'];
  }

  // Add this method to your AuthService class

  // Get stored user data
  Future<Map<String, String?>> getUserData() async {
    try {
      final userData = await _storage.getUserData();

      // If we have stored user data, return it
      if (userData['userId'] != null) {
        return {
          'userId': userData['userId'],
          'userType': userData['userType'],
          'email': userData['email'],
          'name': _extractNameFromEmail(userData['email'] ?? ''),
          'location': 'Dar es Salaam', // Default location
        };
      }

      // If no stored data but user is logged in, try to get profile from API
      if (await isLoggedIn()) {
        final profile = await getProfile();
        final profileData = profile['data']?['user'] ?? {};

        return {
          'userId': profileData['id']?.toString(),
          'userType': profileData['userType'] ?? 'CLIENT',
          'email': profileData['email'] ?? '',
          'name':
              profileData['fullName'] ??
              _extractNameFromEmail(profileData['email'] ?? ''),
          'location': 'Dar es Salaam',
        };
      }

      // Return empty data if not logged in
      return {
        'userId': null,
        'userType': null,
        'email': null,
        'name': null,
        'location': null,
      };
    } catch (e) {
      // Return default data on error
      return {
        'userId': null,
        'userType': 'CLIENT',
        'email': null,
        'name': 'Guest',
        'location': 'Dar es Salaam',
      };
    }
  }

  // Helper method to extract name from email
  String _extractNameFromEmail(String email) {
    if (email.isEmpty) return 'Guest';

    final atIndex = email.indexOf('@');
    if (atIndex > 0) {
      final username = email.substring(0, atIndex);
      // Capitalize first letter
      return username[0].toUpperCase() + username.substring(1);
    }

    return 'Guest';
  }

  // Add this method to your AuthService class
  Future<String?> getUserLocation() async {
    try {
      final userData = await getUserData();
      return userData['location'];
    } catch (e) {
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _storage.clearAll();
  }
}
