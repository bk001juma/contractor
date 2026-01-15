import 'dart:async';
import 'package:contractor/app/home/model/home_model.dart';
import 'package:contractor/app/model/job.dart';
import 'package:contractor/core/services/auth_service.dart';
import 'package:contractor/core/services/home_service.dart';
import 'package:contractor/core/services/jobs_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final Rx<HomeModel> model = HomeModel().obs;
  final AuthService _authService = AuthService();
  final HomeService _homeService = HomeService();
  final JobsService _jobsService = JobsService();

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // Timer for auto-refresh
  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    _loadHomeData();
    // Start auto-refresh timer (every 60 seconds)
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (!isLoading.value) {
        _refreshCarouselData();
      }
    });
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  Future<void> _loadHomeData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Load user data
      final userData = await _authService.getUserData();
      final userType = await _authService.getUserType();
      final userLocation = await _authService.getUserLocation();

      // Load home data
      final homeData = await _homeService.getHomeData(
        userType: userType ?? 'CLIENT',
      );

      // Load carousel jobs
      final carouselJobs = await _loadCarouselJobs(userType ?? 'CLIENT');

      // Update model
      model.value = HomeModel(
        userName: userData['fullName'] ?? userData['name'] ?? 'Guest',
        userType: userType ?? 'CLIENT',
        userLocation: userLocation ?? 'Dar es Salaam',
        activeJobs: homeData['activeJobs'] ?? 0,
        completedJobs: homeData['completedJobs'] ?? 0,
        totalEarnings: (homeData['totalEarnings'] ?? 0.0).toDouble(),
        quickActions: _getQuickActions(userType ?? 'CLIENT'),
        featuredCategories: _mapToServiceCategories(
          homeData['featuredCategories'] ?? [],
        ),
        recentActivities: _mapToActivities(
          homeData['recentActivities'] ?? [],
        ),
        carouselJobs: carouselJobs,
      );
    } catch (e) {
      errorMessage.value = 'Failed to load data: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      _loadDefaultData();
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<JobCarouselItem>> _loadCarouselJobs(String userType) async {
    try {
      List<JobCarouselItem> carouselJobs = [];
      
      if (userType == 'CONTRACTOR') {
        // Load available jobs for contractors
        final availableJobs = await _jobsService.getAvailableJobs(
          limit: 5,
          page: 0,
        );
        
        carouselJobs = availableJobs.map((job) {
          return JobCarouselItem(
            id: job.id.toString(),
            title: job.title,
            description: job.description,
            location: job.location,
            budget: _formatBudget(job),
            status: _getJobStatusText(job.status),
            time: _formatTimeAgo(job.createdAt),
            urgency: _getUrgencyText(job.urgencyLevel),
          );
        }).toList();
      } else {
        // Load client's active jobs
        final clientJobs = await _jobsService.getClientJobs(
          statuses: ['ACTIVE', 'IN_PROGRESS', 'ASSIGNED'],
          limit: 5,
        );
        
        carouselJobs = clientJobs.map((job) {
          return JobCarouselItem(
            id: job.id.toString(),
            title: job.title,
            description: job.description,
            location: job.location,
            budget: _formatBudget(job),
            status: _getJobStatusText(job.status),
            time: _formatTimeAgo(job.createdAt),
            urgency: _getUrgencyText(job.urgencyLevel),
          );
        }).toList();
      }

      return carouselJobs;
    } catch (e) {
      print('Error loading carousel jobs: $e');
      return [];
    }
  }

  Future<void> _refreshCarouselData() async {
    try {
      final userType = await _authService.getUserType();
      final carouselJobs = await _loadCarouselJobs(userType ?? 'CLIENT');
      
      model.update((val) {
        val!.carouselJobs = carouselJobs;
      });
    } catch (e) {
      print('Error refreshing carousel: $e');
    }
  }

  String _formatBudget(JobResponse job) {
    if (job.budgetType == BudgetType.FIXED) {
      return 'TZS ${job.budgetMin.toStringAsFixed(0)}';
    } else if (job.budgetType == BudgetType.RANGE) {
      return 'TZS ${job.budgetMin!.toStringAsFixed(0)} - ${job.budgetMax!.toStringAsFixed(0)}';
    }
    return 'TZS 0';
  }

  String _getJobStatusText(JobStatus? status) {
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
      default:
        return 'Active';
    }
  }

  String _getUrgencyText(UrgencyLevel? urgency) {
    switch (urgency) {
      case UrgencyLevel.LOW:
        return 'Low';
      case UrgencyLevel.MEDIUM:
        return 'Medium';
      case UrgencyLevel.HIGH:
        return 'High';
      case UrgencyLevel.URGENT:
        return 'Urgent';
      default:
        return 'Medium';
    }
  }

  String _formatTimeAgo(DateTime date) {
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

  void _loadDefaultData() {
    model.value = HomeModel(
      userName: 'Guest',
      userType: 'CLIENT',
      userLocation: 'Dar es Salaam',
      activeJobs: 0,
      completedJobs: 0,
      totalEarnings: 0.0,
      quickActions: _getQuickActions('CLIENT'),
      featuredCategories: _getDefaultFeaturedCategories(),
      recentActivities: _getDefaultRecentActivities(),
      carouselJobs: [],
    );
  }

  List<QuickAction> _getQuickActions(String userType) {
    if (userType == 'CONTRACTOR') {
      return [
        QuickAction(
          title: 'Find Jobs',
          icon: '🔍',
          route: '/jobs',
          color: const Color(0xFF4CAF50),
        ),
        QuickAction(
          title: 'My Bids',
          icon: '💰',
          route: '/bids',
          color: const Color(0xFF2196F3),
        ),
        QuickAction(
          title: 'Schedule',
          icon: '📅',
          route: '/schedule',
          color: const Color(0xFF9C27B0),
        ),
        QuickAction(
          title: 'Earnings',
          icon: '💳',
          route: '/earnings',
          color: const Color(0xFFFF9800),
        ),
      ];
    } else {
      return [
        QuickAction(
          title: 'Post Job',
          icon: '📝',
          route: '/post-job',
          color: const Color(0xFF4CAF50),
        ),
        QuickAction(
          title: 'Find Fundi',
          icon: '👷',
          route: '/find-fundi',
          color: const Color(0xFF2196F3),
        ),
        QuickAction(
          title: 'My Jobs',
          icon: '📋',
          route: '/my-jobs',
          color: const Color(0xFF9C27B0),
        ),
        QuickAction(
          title: 'Messages',
          icon: '💬',
          route: '/messages',
          color: const Color(0xFFFF9800),
        ),
      ];
    }
  }

  List<ServiceCategory> _mapToServiceCategories(List<dynamic> data) {
    return data.map((item) {
      return ServiceCategory(
        name: item['name'] as String,
        icon: item['icon'] as String,
        jobCount: item['jobCount'] as int,
        backgroundColor: item['backgroundColor'] is Color
            ? item['backgroundColor'] as Color
            : Color((item['backgroundColor'] as int?) ?? 0xFFE3F2FD),
      );
    }).toList();
  }

  List<ServiceCategory> _getDefaultFeaturedCategories() {
    return [
      ServiceCategory(
        name: 'Plumbing',
        icon: '🚰',
        jobCount: 0,
        backgroundColor: const Color(0xFFE3F2FD),
      ),
      ServiceCategory(
        name: 'Electrical',
        icon: '🔌',
        jobCount: 0,
        backgroundColor: const Color(0xFFF3E5F5),
      ),
      ServiceCategory(
        name: 'Carpentry',
        icon: '🪚',
        jobCount: 0,
        backgroundColor: const Color(0xFFE8F5E8),
      ),
      ServiceCategory(
        name: 'Painting',
        icon: '🎨',
        jobCount: 0,
        backgroundColor: const Color(0xFFFFF3E0),
      ),
    ];
  }

  List<Activity> _mapToActivities(List<dynamic> data) {
    return data.map((item) {
      return Activity(
        title: item['title'] as String,
        description: item['description'] as String,
        time: item['time'] as String,
        icon: item['icon'] is IconData
            ? item['icon'] as IconData
            : Icons.info_outline,
        iconColor: item['iconColor'] is Color
            ? item['iconColor'] as Color
            : Colors.grey,
      );
    }).toList();
  }

  List<Activity> _getDefaultRecentActivities() {
    return [
      Activity(
        title: 'Welcome to Contractor App!',
        description: 'Get started by exploring features',
        time: 'Just now',
        icon: Icons.rocket_launch_outlined,
        iconColor: const Color(0xFF4CAF50),
      ),
      Activity(
        title: 'Complete your profile',
        description: 'Add more details to get better matches',
        time: '5m ago',
        icon: Icons.person_add_outlined,
        iconColor: const Color(0xFF2196F3),
      ),
      Activity(
        title: 'Verify your account',
        description: 'Get verified for more opportunities',
        time: '1h ago',
        icon: Icons.verified_outlined,
        iconColor: const Color(0xFF9C27B0),
      ),
    ];
  }

  void handleQuickAction(QuickAction action) {
    Get.toNamed(action.route);
  }

  Future<void> refreshData() async {
    await _loadHomeData();
  }

  void navigateTo(String route) {
    Get.toNamed(route);
  }

  void logout() async {
    try {
      await _authService.logout();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Logout Failed',
        'Please try again',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}