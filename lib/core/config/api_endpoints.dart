import 'package:contractor/core/config/api_config.dart';

class ApiEndpoints {
  // Auth endpoints
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String test = '/api/auth/test';
  static const String profile = '/api/auth/me';
  static const String verify = '/api/auth/verify';

  // Job endpoints
  static const String jobs = '/api/jobs';
  static const String activeJobs = '/api/jobs/active';
  static const String myJobs = '/api/jobs/my-jobs';
  static const String jobsByCategory = '/api/jobs/category';
  static const String searchJobs = '/api/jobs/search';

  // Job picture endpoints
  static String jobPictures(int jobId) => '/api/jobs/$jobId/pictures';
  static String uploadJobPicture(int jobId) =>
      '/api/jobs/$jobId/pictures/upload';
  static String uploadMultipleJobPictures(int jobId) =>
      '/api/jobs/$jobId/pictures/upload-multiple';
  static String deleteJobPicture(int jobId) => '/api/jobs/$jobId/pictures';

  // **FIXED**: Helper method to build full URL - now async
  static Future<String> buildUrl(String endpoint) async {
    final url = await ApiConfig.baseUrl;
    return '$url$endpoint';
  }

  // **NEW**: Static method for when you have the URL already
  static String buildUrlWithBase(String baseUrl, String endpoint) {
    return '$baseUrl$endpoint';
  }
}