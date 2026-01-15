import 'dart:ui';
import 'package:flutter/material.dart';

class HomeModel {
  // User info
  String userName;
  String userType;
  String userLocation;

  // Stats
  int activeJobs;
  int completedJobs;
  double totalEarnings;

  // Quick actions
  List<QuickAction> quickActions;

  // Featured categories
  List<ServiceCategory> featuredCategories;

  // Recent activities
  List<Activity> recentActivities;

  // Job carousel items
  List<JobCarouselItem> carouselJobs;

  HomeModel({
    this.userName = 'Guest',
    this.userType = 'CLIENT',
    this.userLocation = 'Dar es Salaam',
    this.activeJobs = 0,
    this.completedJobs = 0,
    this.totalEarnings = 0.0,
    this.quickActions = const [],
    this.featuredCategories = const [],
    this.recentActivities = const [],
    this.carouselJobs = const [],
  });

  // Copy with method for updates
  HomeModel copyWith({
    String? userName,
    String? userType,
    String? userLocation,
    int? activeJobs,
    int? completedJobs,
    double? totalEarnings,
    List<QuickAction>? quickActions,
    List<ServiceCategory>? featuredCategories,
    List<Activity>? recentActivities,
    List<JobCarouselItem>? carouselJobs,
  }) {
    return HomeModel(
      userName: userName ?? this.userName,
      userType: userType ?? this.userType,
      userLocation: userLocation ?? this.userLocation,
      activeJobs: activeJobs ?? this.activeJobs,
      completedJobs: completedJobs ?? this.completedJobs,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      quickActions: quickActions ?? this.quickActions,
      featuredCategories: featuredCategories ?? this.featuredCategories,
      recentActivities: recentActivities ?? this.recentActivities,
      carouselJobs: carouselJobs ?? this.carouselJobs,
    );
  }
}

class QuickAction {
  final String title;
  final String icon;
  final String route;
  final Color color;

  QuickAction({
    required this.title,
    required this.icon,
    required this.route,
    required this.color,
  });
}

class ServiceCategory {
  final String name;
  final String icon;
  final int jobCount;
  final Color backgroundColor;

  ServiceCategory({
    required this.name,
    required this.icon,
    required this.jobCount,
    required this.backgroundColor,
  });
}

class Activity {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color iconColor;

  Activity({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.iconColor,
  });
}

class JobCarouselItem {
  final String id;
  final String title;
  final String description;
  final String location;
  final String budget;
  final String status;
  final String time;
  final String urgency;

  JobCarouselItem({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.budget,
    required this.status,
    required this.time,
    required this.urgency,
  });
}
