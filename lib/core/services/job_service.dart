import 'dart:convert';
import 'dart:io';
import 'package:contractor/app/model/api_response.dart';
import 'package:contractor/app/model/job.dart';
import 'package:contractor/core/config/api_client.dart';
import 'package:contractor/core/config/api_endpoints.dart';
import 'package:contractor/core/config/api_exceptions.dart';
import 'package:contractor/core/storage/local_storage.dart';
import 'package:http/http.dart' as http;

class JobService {
  final ApiClient _apiClient = ApiClient();

  Future<JobResponse> createJob(JobRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.jobs,
        request.toJson(),
        requiresAuth: true,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response,
        null,
      );

      if (!apiResponse.success) {
        throw ApiException(message: apiResponse.message);
      }

      return JobResponse.fromJson(apiResponse.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<JobResponse>> getJobs({
    int page = 0,
    int size = 10,
    String sortBy = 'createdAt',
    String sortDir = 'DESC',
  }) async {
    try {
      final endpoint =
          '${ApiEndpoints.jobs}?page=$page&size=$size&sortBy=$sortBy&sortDir=$sortDir';
      final response = await _apiClient.get(endpoint);

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response,
        null,
      );

      if (!apiResponse.success) {
        throw ApiException(message: apiResponse.message);
      }

      final data = apiResponse.data!;
      final jobsData = data['jobs'] as List<dynamic>;

      return jobsData.map((jobJson) {
        return JobResponse.fromJson(jobJson as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<JobResponse> getJobById(int id) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.jobs}/$id');

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response,
        null,
      );

      if (!apiResponse.success) {
        throw ApiException(message: apiResponse.message);
      }

      return JobResponse.fromJson(apiResponse.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<JobResponse>> getActiveJobs() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.activeJobs);

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response,
        (data) => List<Map<String, dynamic>>.from(data['data'] ?? []),
      );

      if (!apiResponse.success) {
        throw ApiException(message: apiResponse.message);
      }

      return (apiResponse.data as List<dynamic>).map((jobJson) {
        return JobResponse.fromJson(jobJson as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<JobResponse>> getMyJobs({int page = 0, int size = 10}) async {
    try {
      print('=== START getMyJobs ===');
      final endpoint = '${ApiEndpoints.myJobs}?page=$page&size=$size';
      print('Endpoint: $endpoint');

      // Try to get the raw response first
      final response = await _apiClient.get(endpoint);
      print('Raw response type: ${response.runtimeType}');
      print('Raw response keys: ${response.keys}');
      print('Raw response: $response');

      // If response has 'data' key
      if (response.containsKey('data')) {
        final data = response['data'];
        print('Data type: ${data.runtimeType}');
        print('Data: $data');

        // Try to extract list
        List<dynamic> jobsList = [];

        if (data is List<dynamic>) {
          print('Data is directly a List');
          jobsList = data;
        } else if (data is Map<String, dynamic>) {
          print('Data is a Map, checking keys: ${data.keys}');

          // Try common keys
          if (data.containsKey('content')) {
            print('Found "content" key');
            jobsList = data['content'] as List<dynamic>;
          } else if (data.containsKey('jobs')) {
            print('Found "jobs" key');
            jobsList = data['jobs'] as List<dynamic>;
          } else {
            // Try to find any list value
            for (var key in data.keys) {
              final value = data[key];
              if (value is List<dynamic>) {
                print('Found list in key: $key');
                jobsList = value;
                break;
              }
            }
          }
        }

        if (jobsList.isNotEmpty) {
          print('Found ${jobsList.length} jobs');
          return jobsList.map((json) {
            try {
              return JobResponse.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              print('Error parsing job: $e');
              print('Problematic JSON: $json');
              rethrow;
            }
          }).toList();
        } else {
          print('No jobs found in response');
          return [];
        }
      } else {
        print('Response does not have "data" key');
        print('Response structure: $response');
        return [];
      }
    } catch (e, stackTrace) {
      print('=== ERROR in getMyJobs ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    } finally {
      print('=== END getMyJobs ===');
    }
  }

  Future<List<JobResponse>> getJobsByCategory(TradeCategory category) async {
    try {
      final endpoint = '${ApiEndpoints.jobsByCategory}/${category.name}';
      final response = await _apiClient.get(endpoint);

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response,
        (data) => List<Map<String, dynamic>>.from(data['data'] ?? []),
      );

      if (!apiResponse.success) {
        throw ApiException(message: apiResponse.message);
      }

      return (apiResponse.data as List<dynamic>).map((jobJson) {
        return JobResponse.fromJson(jobJson as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<JobResponse>> searchJobs({
    String? location,
    TradeCategory? category,
    double? minBudget,
  }) async {
    try {
      final queryParams = <String>[];
      if (location != null) queryParams.add('location=$location');
      if (category != null) queryParams.add('category=${category.name}');
      if (minBudget != null) queryParams.add('minBudget=$minBudget');

      final queryString = queryParams.isNotEmpty
          ? '?${queryParams.join('&')}'
          : '';

      final endpoint = '${ApiEndpoints.searchJobs}$queryString';
      final response = await _apiClient.get(endpoint);

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response,
        (data) => List<Map<String, dynamic>>.from(data['data'] ?? []),
      );

      if (!apiResponse.success) {
        throw ApiException(message: apiResponse.message);
      }

      return (apiResponse.data as List<dynamic>).map((jobJson) {
        return JobResponse.fromJson(jobJson as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<JobResponse> updateJobStatus(int jobId, JobStatus status) async {
    try {
      final endpoint =
          '${ApiEndpoints.jobs}/$jobId/status?status=${status.name}';
      final response = await _apiClient.get(endpoint); // Actually should be PUT

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response,
        null,
      );

      if (!apiResponse.success) {
        throw ApiException(message: apiResponse.message);
      }

      return JobResponse.fromJson(apiResponse.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteJob(int jobId) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.jobs}/$jobId',
      ); // Actually should be DELETE

      final apiResponse = ApiResponse<dynamic>.fromJson(response, null);

      if (!apiResponse.success) {
        throw ApiException(message: apiResponse.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Picture Management Methods

  Future<List<String>> getJobPictures(int jobId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.jobPictures(jobId));

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response,
        (data) => List<String>.from(data['data'] ?? []),
      );

      if (!apiResponse.success) {
        throw ApiException(message: apiResponse.message);
      }

      return (apiResponse.data as List<dynamic>).cast<String>();
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadJobPicture(int jobId, File imageFile) async {
    try {
      final token = await LocalStorage().getToken();
      if (token == null) {
        throw UnauthorizedException(message: 'No authentication token found');
      }

      final url = ApiEndpoints.buildUrl(ApiEndpoints.uploadJobPicture(jobId));
      final request = http.MultipartRequest('POST', Uri.parse(await url));

      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw ApiException(
          message: errorData['message'] ?? 'Failed to upload picture',
          statusCode: response.statusCode,
        );
      }

      final responseData = json.decode(response.body);
      return responseData['data']['url'] as String;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> uploadMultipleJobPictures(
    int jobId,
    List<File> imageFiles,
  ) async {
    try {
      final token = await LocalStorage().getToken();
      if (token == null) {
        throw UnauthorizedException(message: 'No authentication token found');
      }

      final url = ApiEndpoints.buildUrl(
        ApiEndpoints.uploadMultipleJobPictures(jobId),
      );
      final request = http.MultipartRequest('POST', Uri.parse(await url));

      request.headers['Authorization'] = 'Bearer $token';

      for (var imageFile in imageFiles) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'files',
            imageFile.path,
            filename: imageFile.path.split('/').last,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw ApiException(
          message: errorData['message'] ?? 'Failed to upload pictures',
          statusCode: response.statusCode,
        );
      }

      final responseData = json.decode(response.body);
      final uploadedFiles = responseData['data'] as List<dynamic>;

      return uploadedFiles.map<String>((fileData) {
        return fileData['url'] as String;
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteJobPicture(int jobId, String pictureUrl) async {
    try {
      final token = await LocalStorage().getToken();
      if (token == null) {
        throw UnauthorizedException(message: 'No authentication token found');
      }

      final url = Uri.parse(
        await ApiEndpoints.buildUrl(
          '${ApiEndpoints.deleteJobPicture(jobId)}?pictureUrl=$pictureUrl',
        ),
      );

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw ApiException(
          message: errorData['message'] ?? 'Failed to delete picture',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
