import 'package:contractor/app/home/model/home_model.dart';
import 'package:contractor/core/services/auth_service.dart';
import 'package:contractor/core/services/home_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final Rx<HomeModel> model = HomeModel().obs;
  final AuthService _authService = AuthService();
  final HomeService _homeService = HomeService();

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadHomeData();
  }

  // Add this method to HomeController
  void handleQuickAction(QuickAction action) {
    Get.toNamed(action.route);
  }

  Future<void> _loadHomeData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Load user data
      final userData = await _authService.getUserData();
      final userType = await _authService.getUserType();
      final userLocation = await _authService.getUserLocation();

      // Load home data based on user type
      final homeData = await _homeService.getHomeData(
        userType: userType ?? 'CLIENT',
      );

      // Update model with loaded data
      model.update((val) {
        val!.userName = userData['fullName'] ?? userData['name'] ?? 'Guest';
        val.userType = userType ?? 'CLIENT';
        val.userLocation = userLocation ?? 'Dar es Salaam';
        val.activeJobs = homeData['activeJobs'] ?? 0;
        val.completedJobs = homeData['completedJobs'] ?? 0;
        val.totalEarnings = (homeData['totalEarnings'] ?? 0.0).toDouble();
        val.quickActions = _getQuickActions(userType ?? 'CLIENT');
        val.featuredCategories = _mapToServiceCategories(
          homeData['featuredCategories'] ?? [],
        );
        val.recentActivities = _mapToActivities(
          homeData['recentActivities'] ?? [],
        );
      });
    } catch (e) {
      errorMessage.value = 'Failed to load data: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      // Load default data on error
      _loadDefaultData();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadDefaultData() {
    model.update((val) {
      val!.userName = 'Guest';
      val.userType = 'CLIENT';
      val.userLocation = 'Dar es Salaam';
      val.activeJobs = 0;
      val.completedJobs = 0;
      val.totalEarnings = 0.0;
      val.quickActions = _getQuickActions('CLIENT');
      val.featuredCategories = _getDefaultFeaturedCategories();
      val.recentActivities = _getDefaultRecentActivities();
    });
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
      ServiceCategory(
        name: 'Masonry',
        icon: '🧱',
        jobCount: 0,
        backgroundColor: const Color(0xFFFCE4EC),
      ),
      ServiceCategory(
        name: 'AC Repair',
        icon: '❄️',
        jobCount: 0,
        backgroundColor: const Color(0xFFE0F7FA),
      ),
    ];
  }

  List<Activity> _getDefaultRecentActivities() {
    return [
      Activity(
        title: 'No recent activities',
        description: 'Start by posting a job!',
        time: '',
        icon: Icons.info_outline,
        iconColor: Colors.grey,
      ),
    ];
  }

  void refreshData() {
    _loadHomeData();
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
