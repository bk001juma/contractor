import 'package:contractor/app/model/job.dart';
import 'package:contractor/core/config/api_client.dart';
import 'package:contractor/core/config/api_endpoints.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';

class JobsService extends GetxService {
  final ApiClient _apiClient = ApiClient();

  // **NEW**: Get available jobs for contractors (active jobs)
  Future<List<JobResponse>> getAvailableJobs({
    int limit = 5,
    int page = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': limit.toString(),
        'status': 'ACTIVE', // Only show active jobs for contractors
      };

      final response = await _apiClient.gets(
        ApiEndpoints.activeJobs,
        queryParameters: queryParams,
      );

      if (!response.containsKey('data')) {
        throw Exception('Invalid API response: missing data field');
      }

      final data = response['data'];

      if (data is List<dynamic>) {
        return _parseJobsFromList(data);
      } else if (data is Map<String, dynamic>) {
        return _extractJobsFromMap(data);
      } else {
        throw Exception('Unexpected data type: ${data.runtimeType}');
      }
    } catch (e) {
      print('Error loading available jobs: $e');
      rethrow;
    }
  }

  // **NEW**: Get client's jobs with specific statuses
  Future<List<JobResponse>> getClientJobs({
    List<String>? statuses,
    int limit = 5,
    int page = 0,
  }) async {
    try {
      // First get all client jobs
      final allJobs = await getMyJobs(page: page, size: limit);

      // Filter by status if provided
      if (statuses != null && statuses.isNotEmpty) {
        return allJobs.where((job) {
          return statuses.contains(job.status?.name.toUpperCase());
        }).toList();
      }

      return allJobs;
    } catch (e) {
      print('Error loading client jobs: $e');
      rethrow;
    }
  }

  // Existing method - Get client's jobs
  Future<List<JobResponse>> getMyJobs({
    JobStatus? status,
    String? searchQuery,
    int page = 0,
    int size = 20,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };

      if (status != null) {
        queryParams['status'] = status.name;
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }

      // Call API with query parameters
      final response = await _apiClient.gets(
        ApiEndpoints.myJobs,
        queryParameters: queryParams,
      );

      // Extract and validate response
      if (!response.containsKey('data')) {
        throw Exception('Invalid API response: missing data field');
      }

      final data = response['data'];

      // Handle different response formats
      if (data is List<dynamic>) {
        // Direct list format
        return _parseJobsFromList(data);
      } else if (data is Map<String, dynamic>) {
        // Nested list format (Spring Page, custom wrapper, etc.)
        return _extractJobsFromMap(data);
      } else {
        throw Exception('Unexpected data type: ${data.runtimeType}');
      }
    } catch (e) {
      // Re-throw with better error message
      throw Exception('Failed to load jobs: $e');
    }
  }

  /// Parse jobs from a direct list
  List<JobResponse> _parseJobsFromList(List<dynamic> items) {
    final jobs = <JobResponse>[];

    for (final item in items) {
      try {
        if (item is Map<String, dynamic>) {
          jobs.add(JobResponse.fromJson(item));
        }
      } catch (e) {
        // Log parsing error but continue with other items
        print('Warning: Failed to parse job item: $e');
      }
    }

    return jobs;
  }

  /// Extract jobs from a nested map structure
  List<JobResponse> _extractJobsFromMap(Map<String, dynamic> data) {
    // Check common keys for nested job lists
    const possibleListKeys = ['content', 'jobs', 'items', 'results', 'data'];

    for (final key in possibleListKeys) {
      if (data.containsKey(key) && data[key] is List<dynamic>) {
        final list = data[key] as List<dynamic>;
        return _parseJobsFromList(list);
      }
    }

    // If no list found, try to find any list value
    for (final value in data.values) {
      if (value is List<dynamic>) {
        return _parseJobsFromList(value);
      }
    }

    // No jobs found
    return [];
  }

  // Get job by ID
  Future<JobResponse> getJobById(int jobId) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.jobs}/$jobId');

      if (response['statusCode'] == 200 || response.containsKey('data')) {
        final Map<String, dynamic> data = response['data'] ?? {};
        return JobResponse.fromJson(data);
      } else {
        throw Exception('Failed to load job');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update job status
  Future<void> updateJobStatus(int jobId, JobStatus status) async {
    try {
      final response = await _apiClient.put(
        '${ApiEndpoints.jobs}/$jobId/status',
        {'status': status.name}, // This is the body, passed as second argument
      );

      if (response['statusCode'] != 200) {
        throw Exception('Failed to update job status');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete job
  Future<void> deleteJob(int jobId) async {
    try {
      final response = await _apiClient.delete('${ApiEndpoints.jobs}/$jobId');

      if (response['statusCode'] != 200) {
        throw Exception('Failed to delete job');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get job statistics
  Future<Map<String, dynamic>> getJobStats() async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.myJobs}/stats');

      if (response['statusCode'] == 200 || response.containsKey('data')) {
        final Map<String, dynamic> data = response['data'] ?? {};

        // Convert BigDecimals to doubles for Dart
        return {
          'totalJobs': data['totalJobs'] ?? 0,
          'activeJobs': data['activeJobs'] ?? 0,
          'completedJobs': data['completedJobs'] ?? 0,
          'pendingJobs': data['pendingJobs'] ?? 0,
          'inProgressJobs': data['inProgressJobs'] ?? 0,
          'assignedJobs': data['assignedJobs'] ?? 0,
          'cancelledJobs': data['cancelledJobs'] ?? 0,
          'expiredJobs': data['expiredJobs'] ?? 0,
          'totalSpent': (data['totalSpent'] as num?)?.toDouble() ?? 0.0,
          'averageBids': (data['averageBids'] as num?)?.toDouble() ?? 0.0,
          'totalViews': data['totalViews'] ?? 0,
          'totalBids': data['totalBids'] ?? 0,
          'recentJobs': data['recentJobs'] ?? 0,
          'completionRate': (data['completionRate'] as num?)?.toDouble() ?? 0.0,
          'activeRate': (data['activeRate'] as num?)?.toDouble() ?? 0.0,
        };
      } else {
        throw Exception('Failed to load job statistics');
      }
    } catch (e) {
      rethrow;
    }
  }
}
