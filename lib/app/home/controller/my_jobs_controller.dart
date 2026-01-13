// lib/app/jobs/controller/my_jobs_controller.dart
import 'package:contractor/app/model/job.dart';
import 'package:contractor/core/services/jobs_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyJobsController extends GetxController {
  final JobsService _jobsService = JobsService();

  // Reactive variables
  final RxList<JobResponse> jobs = <JobResponse>[].obs;
  final RxList<JobResponse> filteredJobs = <JobResponse>[].obs;
  final Rx<JobStatus?> selectedStatus = Rx<JobStatus?>(null);
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 0.obs;
  final RxBool hasMore = true.obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;

  // Statistics
  final RxInt totalJobs = 0.obs;
  final RxInt activeJobs = 0.obs;
  final RxInt completedJobs = 0.obs;
  final RxInt pendingJobs = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadJobs();
    loadJobStats();
  }

  // Load jobs with pagination
  Future<void> loadJobs({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        isLoading.value = true;
        currentPage.value = 0;
        jobs.clear();
      } else {
        isLoadingMore.value = true;
      }

      errorMessage.value = '';

      final loadedJobs = await _jobsService.getMyJobs(
        status: selectedStatus.value,
        searchQuery: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        page: currentPage.value,
        size: 10,
      );

      if (loadMore) {
        jobs.addAll(loadedJobs);
      } else {
        jobs.assignAll(loadedJobs);
      }

      // Apply filters to the newly loaded data
      applyFilters();

      // Check if there are more pages
      hasMore.value = loadedJobs.length >= 10;
      if (loadedJobs.isNotEmpty) {
        currentPage.value++;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load jobs: $e';
      print('Error loading jobs: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
      isRefreshing.value = false;
    }
  }

  // Load job statistics
  Future<void> loadJobStats() async {
    try {
      final stats = await _jobsService.getJobStats();

      totalJobs.value = stats['totalJobs'] ?? 0;
      activeJobs.value = stats['activeJobs'] ?? 0;
      completedJobs.value = stats['completedJobs'] ?? 0;
      pendingJobs.value = stats['pendingJobs'] ?? 0;
    } catch (e) {
      print('Failed to load job stats: $e');
    }
  }

  // Refresh jobs
  Future<void> refreshJobs() async {
    isRefreshing.value = true;
    await loadJobs();
    await loadJobStats();
  }

  void filterByStatus(JobStatus? status) {
    selectedStatus.value = status;
    
    applyFilters();
    
    update();
  }

  // Search jobs - FIXED VERSION
  void searchJobs(String query) {
    searchQuery.value = query;
    // Apply filters immediately
    applyFilters();
    
    // Ensure UI updates
    update();
  }


  // Apply filters to jobs - IMPROVED VERSION
  void applyFilters() {
    var filtered = jobs.where((job) {
      // Filter by status
      if (selectedStatus.value != null && job.status != selectedStatus.value) {
        return false;
      }

      // Filter by search query
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        return job.title.toLowerCase().contains(query) ||
            job.description.toLowerCase().contains(query) ||
            job.location.toLowerCase().contains(query) ||
            (job.specificSkill?.toLowerCase().contains(query) ?? false);
      }

      return true;
    }).toList();

    filteredJobs.assignAll(filtered);
  }

  // Update job status
  Future<void> updateJobStatus(int jobId, JobStatus newStatus) async {
    try {
      await _jobsService.updateJobStatus(jobId, newStatus);

      // Update local job
      final index = jobs.indexWhere((job) => job.id == jobId);
      if (index != -1) {
        final updatedJob = JobResponse(
          id: jobs[index].id,
          title: jobs[index].title,
          description: jobs[index].description,
          tradeCategory: jobs[index].tradeCategory,
          specificSkill: jobs[index].specificSkill,
          location: jobs[index].location,
          latitude: jobs[index].latitude,
          longitude: jobs[index].longitude,
          budgetType: jobs[index].budgetType,
          budgetMin: jobs[index].budgetMin,
          budgetMax: jobs[index].budgetMax,
          urgencyLevel: jobs[index].urgencyLevel,
          preferredDate: jobs[index].preferredDate,
          preferredTime: jobs[index].preferredTime,
          status: newStatus,
          pictureUrls: jobs[index].pictureUrls,
          viewsCount: jobs[index].viewsCount,
          bidsCount: jobs[index].bidsCount,
          createdAt: jobs[index].createdAt,
          updatedAt: DateTime.now(),
          expiresAt: jobs[index].expiresAt,
          client: jobs[index].client,
        );

        jobs[index] = updatedJob;
        applyFilters();

        Get.snackbar(
          'Success',
          'Job status updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update job status: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Delete job
  Future<void> deleteJob(int jobId) async {
    try {
      Get.defaultDialog(
        title: 'Delete Job',
        middleText: 'Are you sure you want to delete this job?',
        textConfirm: 'Delete',
        textCancel: 'Cancel',
        confirmTextColor: Colors.white,
        onConfirm: () async {
          Get.back();

          await _jobsService.deleteJob(jobId);

          // Remove from local list
          jobs.removeWhere((job) => job.id == jobId);
          applyFilters();

          // Update stats
          await loadJobStats();

          Get.snackbar(
            'Success',
            'Job deleted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete job: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // View job details
  void viewJobDetails(JobResponse job) {
    Get.toNamed('/job-details', arguments: job.id);
  }

  // Get status color
  Color getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.ACTIVE:
        return Colors.green;
      case JobStatus.PENDING:
        return Colors.orange;
      case JobStatus.IN_PROGRESS:
        return Colors.blue;
      case JobStatus.COMPLETED:
        return Colors.purple;
      case JobStatus.ASSIGNED:
        return Colors.teal;
      case JobStatus.CANCELLED:
        return Colors.red;
      case JobStatus.EXPIRED:
        return Colors.grey;
    }
  }

  // Get status text
  String getStatusText(JobStatus status) {
    switch (status) {
      case JobStatus.ACTIVE:
        return 'Active';
      case JobStatus.PENDING:
        return 'Pending';
      case JobStatus.IN_PROGRESS:
        return 'In Progress';
      case JobStatus.COMPLETED:
        return 'Completed';
      case JobStatus.ASSIGNED:
        return 'Assigned';
      case JobStatus.CANCELLED:
        return 'Cancelled';
      case JobStatus.EXPIRED:
        return 'Expired';
    }
  }

  // Get category text
  String getCategoryText(TradeCategory category) {
    switch (category) {
      case TradeCategory.AIR_CONDITIONING:
        return 'Air Conditioning';
      case TradeCategory.CARPENTRY:
        return 'Carpentry';
      case TradeCategory.CLEANING:
        return 'Cleaning';
      case TradeCategory.ELECTRICAL:
        return 'Electrical';
      case TradeCategory.GARDENING:
        return 'Gardening';
      case TradeCategory.GENERATOR_REPAIR:
        return 'Generator Repair';
      case TradeCategory.MASONRY:
        return 'Masonry';
      case TradeCategory.OTHER:
        return 'Other';
      case TradeCategory.PAINTING:
        return 'Painting';
      case TradeCategory.PLUMBING:
        return 'Plumbing';
      case TradeCategory.TILING:
        return 'Tiling';
      case TradeCategory.WELDING:
        return 'Welding';
    }
  }

  // Get urgency icon
  IconData getUrgencyIcon(UrgencyLevel urgency) {
    switch (urgency) {
      case UrgencyLevel.LOW:
        return Icons.schedule_outlined;
      case UrgencyLevel.MEDIUM:
        return Icons.watch_later_outlined;
      case UrgencyLevel.HIGH:
        return Icons.warning_amber_outlined;
      case UrgencyLevel.URGENT:
        return Icons.error_outline;
    }
  }

  // Get urgency color
  Color getUrgencyColor(UrgencyLevel urgency) {
    switch (urgency) {
      case UrgencyLevel.LOW:
        return Colors.green;
      case UrgencyLevel.MEDIUM:
        return Colors.orange;
      case UrgencyLevel.HIGH:
        return Colors.red;
      case UrgencyLevel.URGENT:
        return Colors.deepOrange;
    }
  }

  // Format date
  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Format currency
  String formatCurrency(double amount) {
    return 'TZS ${amount.toStringAsFixed(0)}';
  }
}
