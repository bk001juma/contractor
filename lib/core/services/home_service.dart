// ignore_for_file: unused_field

import 'dart:math';
import 'package:contractor/app/model/job.dart';
import 'package:contractor/core/config/api_client.dart';

import 'package:contractor/core/services/job_service.dart';

import 'package:contractor/core/storage/local_storage.dart';
import 'package:flutter/material.dart';

class HomeService {
  final ApiClient _apiClient = ApiClient();
  final JobService _jobService = JobService();
  final LocalStorage _storage = LocalStorage();

  Future<Map<String, dynamic>> getHomeData({required String userType}) async {
    try {
      // For clients, get their jobs data
      if (userType == 'CLIENT') {
        return await _getClientHomeData();
      } 
      // For contractors, get different data
      else if (userType == 'CONTRACTOR') {
        return await _getContractorHomeData();
      }
      
      return _getDefaultHomeData();
    } catch (e) {
      // ignore: avoid_print
      print('Error loading home data: $e');
      return _getDefaultHomeData();
    }
  }

  Future<Map<String, dynamic>> _getClientHomeData() async {
    try {
      // Get client's jobs
      final myJobs = await _jobService.getMyJobs();
      
      // Calculate stats
      final activeJobs = myJobs.where((job) => 
        job.status.name != 'COMPLETED' && 
        job.status.name != 'CANCELLED' && 
        job.status.name != 'EXPIRED'
      ).length;
      
      final completedJobs = myJobs.where((job) => 
        job.status.name == 'COMPLETED'
      ).length;
      
      // Calculate total spent (sum of budgetMax for completed jobs)
      final totalSpent = myJobs
          .where((job) => job.status.name == 'COMPLETED')
          .fold<double>(0.0, (sum, job) => sum + job.budgetMax);
      
      // Get featured categories with real job counts
      final featuredCategories = await _getFeaturedCategories();
      
      // Get recent activities from jobs
      final recentActivities = _getRecentActivitiesFromJobs(myJobs);
      
      return {
        'activeJobs': activeJobs,
        'completedJobs': completedJobs,
        'totalEarnings': totalSpent,
        'featuredCategories': featuredCategories,
        'recentActivities': recentActivities,
      };
    } catch (e) {
      print('Error getting client home data: $e');
      return _getDefaultHomeData();
    }
  }

  Future<Map<String, dynamic>> _getContractorHomeData() async {
    try {
      // Get all active jobs for contractors to browse
      final activeJobsList = await _jobService.getActiveJobs();
      final activeJobsCount = activeJobsList.length;
      
      // TODO: Get contractor's bids and completed jobs
      // For now, use dummy data
      final completedJobs = 0; // Will implement bids later
      final totalEarnings = 0.0; // Will implement earnings later
      
      // Get featured categories
      final featuredCategories = await _getFeaturedCategories();
      
      // TODO: Get contractor's recent activities
      final recentActivities = _getDefaultRecentActivities();
      
      return {
        'activeJobs': activeJobsCount,
        'completedJobs': completedJobs,
        'totalEarnings': totalEarnings,
        'featuredCategories': featuredCategories,
        'recentActivities': recentActivities,
      };
    } catch (e) {
      print('Error getting contractor home data: $e');
      return _getDefaultHomeData();
    }
  }

  Future<List<Map<String, dynamic>>> _getFeaturedCategories() async {
    try {
      // Define all trade categories
      final allCategories = [
        {'name': 'Plumbing', 'icon': '🚰', 'category': 'PLUMBING'},
        {'name': 'Electrical', 'icon': '🔌', 'category': 'ELECTRICAL'},
        {'name': 'Carpentry', 'icon': '🪚', 'category': 'CARPENTRY'},
        {'name': 'Painting', 'icon': '🎨', 'category': 'PAINTING'},
        {'name': 'Masonry', 'icon': '🧱', 'category': 'MASONRY'},
        {'name': 'AC Repair', 'icon': '❄️', 'category': 'AIR_CONDITIONING'},
        {'name': 'Cleaning', 'icon': '🧹', 'category': 'CLEANING'},
        {'name': 'Gardening', 'icon': '🌿', 'category': 'GARDENING'},
        {'name': 'Tiling', 'icon': '🧱', 'category': 'TILING'},
        {'name': 'Welding', 'icon': '⚡', 'category': 'WELDING'},
        {'name': 'Generator', 'icon': '🔋', 'category': 'GENERATOR_REPAIR'},
        {'name': 'Other', 'icon': '🔧', 'category': 'OTHER'},
      ];

      // Get job counts for each category
      final List<Map<String, dynamic>> categoriesWithCounts = [];
      
      for (var categoryData in allCategories) {
        try {
          // Get jobs for this category
          final jobs = await _jobService.getJobsByCategory(
            _stringToTradeCategory(categoryData['category']!),
          );
          
          // Filter only active jobs
          final activeJobs = jobs.where((job) => 
            job.status.name != 'COMPLETED' && 
            job.status.name != 'CANCELLED' && 
            job.status.name != 'EXPIRED'
          ).length;
          
          if (activeJobs > 0) {
            categoriesWithCounts.add({
              'name': categoryData['name'],
              'icon': categoryData['icon'],
              'jobCount': activeJobs,
              'backgroundColor': _getCategoryColor(categoryData['name']!),
            });
          }
        } catch (e) {
          // Skip category if error
          continue;
        }
      }

      // Sort by job count (descending) and take top 6
      categoriesWithCounts.sort((a, b) => b['jobCount'].compareTo(a['jobCount']));
      return categoriesWithCounts.take(6).toList();
    } catch (e) {
      print('Error getting featured categories: $e');
      return _getDefaultFeaturedCategories();
    }
  }

  List<Map<String, dynamic>> _getRecentActivitiesFromJobs(List jobs) {
    try {
      final List<Map<String, dynamic>> activities = [];
      
      // Sort jobs by updatedAt (most recent first)
      jobs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
      // Take up to 4 most recent jobs
      for (var i = 0; i < min(4, jobs.length); i++) {
        final job = jobs[i];
        final timeAgo = _getTimeAgo(job.updatedAt);
        
        activities.add({
          'title': _getActivityTitle(job.status.name),
          'description': job.title,
          'time': timeAgo,
          'icon': _getActivityIcon(job.status.name),
          'iconColor': _getActivityColor(job.status.name),
        });
      }
      
      return activities;
    } catch (e) {
      print('Error getting recent activities: $e');
      return _getDefaultRecentActivities();
    }
  }

  // Helper methods
  TradeCategory _stringToTradeCategory(String category) {
    return TradeCategory.values.firstWhere(
      (e) => e.name == category,
      orElse: () => TradeCategory.OTHER,
    );
  }

  Color _getCategoryColor(String categoryName) {
    final colors = {
      'Plumbing': const Color(0xFFE3F2FD),
      'Electrical': const Color(0xFFF3E5F5),
      'Carpentry': const Color(0xFFE8F5E8),
      'Painting': const Color(0xFFFFF3E0),
      'Masonry': const Color(0xFFFCE4EC),
      'AC Repair': const Color(0xFFE0F7FA),
      'Cleaning': const Color(0xFFF1F8E9),
      'Gardening': const Color(0xFFE8F5E9),
      'Tiling': const Color(0xFFECEFF1),
      'Welding': const Color(0xFFF3E5F5),
      'Generator': const Color(0xFFE0F2F1),
      'Other': const Color(0xFFFAFAFA),
    };
    return colors[categoryName] ?? const Color(0xFFFAFAFA);
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${difference.inDays ~/ 7}w ago';
  }

  String _getActivityTitle(String status) {
    switch (status) {
      case 'PENDING': return 'Job Posted';
      case 'ACTIVE': return 'Job Active';
      case 'ASSIGNED': return 'Job Assigned';
      case 'IN_PROGRESS': return 'Job In Progress';
      case 'COMPLETED': return 'Job Completed';
      case 'CANCELLED': return 'Job Cancelled';
      default: return 'Job Updated';
    }
  }

  IconData _getActivityIcon(String status) {
    switch (status) {
      case 'PENDING': return Icons.add_circle_outline;
      case 'ACTIVE': return Icons.work_outline;
      case 'ASSIGNED': return Icons.person;
      case 'IN_PROGRESS': return Icons.build;
      case 'COMPLETED': return Icons.check_circle_outline;
      case 'CANCELLED': return Icons.cancel_outlined;
      default: return Icons.update;
    }
  }

  Color _getActivityColor(String status) {
    switch (status) {
      case 'PENDING': return Colors.blue;
      case 'ACTIVE': return Colors.green;
      case 'ASSIGNED': return Colors.orange;
      case 'IN_PROGRESS': return Colors.purple;
      case 'COMPLETED': return Colors.teal;
      case 'CANCELLED': return Colors.red;
      default: return Colors.grey;
    }
  }

  // Default data fallbacks
  Map<String, dynamic> _getDefaultHomeData() {
    return {
      'activeJobs': 0,
      'completedJobs': 0,
      'totalEarnings': 0.0,
      'featuredCategories': _getDefaultFeaturedCategories(),
      'recentActivities': _getDefaultRecentActivities(),
    };
  }

  List<Map<String, dynamic>> _getDefaultFeaturedCategories() {
    return [
      {
        'name': 'Plumbing',
        'icon': '🚰',
        'jobCount': 0,
        'backgroundColor': const Color(0xFFE3F2FD),
      },
      {
        'name': 'Electrical',
        'icon': '🔌',
        'jobCount': 0,
        'backgroundColor': const Color(0xFFF3E5F5),
      },
      {
        'name': 'Carpentry',
        'icon': '🪚',
        'jobCount': 0,
        'backgroundColor': const Color(0xFFE8F5E8),
      },
      {
        'name': 'Painting',
        'icon': '🎨',
        'jobCount': 0,
        'backgroundColor': const Color(0xFFFFF3E0),
      },
      {
        'name': 'Masonry',
        'icon': '🧱',
        'jobCount': 0,
        'backgroundColor': const Color(0xFFFCE4EC),
      },
      {
        'name': 'AC Repair',
        'icon': '❄️',
        'jobCount': 0,
        'backgroundColor': const Color(0xFFE0F7FA),
      },
    ];
  }

  List<Map<String, dynamic>> _getDefaultRecentActivities() {
    return [
      {
        'title': 'No recent activities',
        'description': 'Start by posting a job!',
        'time': '',
        'icon': Icons.info_outline,
        'iconColor': Colors.grey,
      },
    ];
  }
}