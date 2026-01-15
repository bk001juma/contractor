// ignore_for_file: deprecated_member_use

import 'package:carousel_slider/carousel_slider.dart';
import 'package:contractor/app/home/controller/home_controller.dart';
import 'package:contractor/app/home/model/home_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        // Make status bar icons white (light) so they're visible on dark background
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Column(
          children: [
            // Fixed AppBar - Extends behind status bar
            Container(
              height:
                  120 +
                  statusBarHeight, // Add status bar height to total height
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [const Color(0xFF0D1026), const Color(0xFF1A1F3E)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: statusBarHeight, // Start content below status bar
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getGreeting(),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: width * 0.038,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                controller.model.value.userName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: width * 0.055,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.white.withOpacity(0.8),
                                    size: width * 0.04,
                                  ),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      controller.model.value.userLocation,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: width * 0.035,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () => Get.toNamed('/profile'),
                              child: CircleAvatar(
                                radius: width * 0.07,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  color: const Color(0xFF0D1026),
                                  size: width * 0.06,
                                ),
                              ),
                            ),
                            SizedBox(height: 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    controller.model.value.userType ==
                                        'CONTRACTOR'
                                    ? Colors.orange.withOpacity(0.2)
                                    : Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      controller.model.value.userType ==
                                          'CONTRACTOR'
                                      ? Colors.orange
                                      : Colors.blue,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                controller.model.value.userType,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      controller.model.value.userType ==
                                          'CONTRACTOR'
                                      ? Colors.orange
                                      : Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Rest of your content in an Expanded widget
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => controller.refreshData(),
                child: ListView(
                  children: [
                    // Quick Stats
                    _buildQuickStats(width),

                    // Jobs Carousel
                    _buildJobsCarousel(width, height),

                    // Quick Actions
                    _buildQuickActions(width),

                    // Recent Activities
                    _buildRecentActivities(width),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Rest of your methods remain the same...
  Widget _buildQuickStats(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: controller.model.value.userType == 'CONTRACTOR'
                  ? 'Available Jobs'
                  : 'Active Jobs',
              value: controller.model.value.activeJobs.toString(),
              icon: Icons.work_outline,
              color: const Color(0xFF4CAF50),
              width: width,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: controller.model.value.userType == 'CONTRACTOR'
                  ? 'My Bids'
                  : 'My Jobs',
              value: controller.model.value.completedJobs.toString(),
              icon: controller.model.value.userType == 'CONTRACTOR'
                  ? Icons.assignment_outlined
                  : Icons.assignment_turned_in_outlined,
              color: const Color(0xFF2196F3),
              width: width,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: controller.model.value.userType == 'CONTRACTOR'
                  ? 'Earnings'
                  : 'Spent',
              value:
                  'TZS ${controller.model.value.totalEarnings.toStringAsFixed(0)}',
              icon: Icons.attach_money_outlined,
              color: const Color(0xFF9C27B0),
              width: width,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsCarousel(double width, double height) {
    final carouselJobs = controller.model.value.carouselJobs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.model.value.userType == 'CONTRACTOR'
                    ? 'Available Jobs Nearby'
                    : 'My Active Jobs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0D1026),
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(
                  controller.model.value.userType == 'CONTRACTOR'
                      ? '/available-jobs'
                      : '/my-jobs',
                ),
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF2196F3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (carouselJobs.isNotEmpty)
          CarouselSlider.builder(
            options: CarouselOptions(
              height: height * 0.25,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.85,
              autoPlayInterval: Duration(seconds: 5),
            ),
            itemCount: carouselJobs.length,
            itemBuilder: (context, index, realIndex) {
              final job = carouselJobs[index];
              return _JobCarouselCard(job: job, width: width);
            },
          )
        else
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_outline, size: 48, color: Colors.grey[400]),
                  SizedBox(height: 12),
                  Text(
                    controller.model.value.userType == 'CONTRACTOR'
                        ? 'No available jobs nearby'
                        : 'No active jobs',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildQuickActions(double width) {
    final quickActions = controller.model.value.quickActions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D1026),
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: quickActions.length,
            itemBuilder: (context, index) {
              final action = quickActions[index];
              return GestureDetector(
                onTap: () => controller.handleQuickAction(action),
                child: Container(
                  width: 90,
                  margin: EdgeInsets.only(right: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: action.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: action.color.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(action.icon, style: TextStyle(fontSize: 24)),
                      SizedBox(height: 8),
                      Text(
                        action.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRecentActivities(double width) {
    final activities = controller.model.value.recentActivities;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activities',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0D1026),
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed('/activities'),
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF2196F3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ...activities.take(3).map((activity) {
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: activity.iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      activity.icon,
                      color: activity.iconColor,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 4),
                        Text(
                          activity.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    activity.time,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double width;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _JobCarouselCard extends StatelessWidget {
  final JobCarouselItem job;
  final double width;

  const _JobCarouselCard({required this.job, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(job.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  job.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(job.status),
                  ),
                ),
              ),
              Spacer(),
              Text(
                job.budget,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            job.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            job.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  job.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
              Icon(Icons.schedule_outlined, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Text(
                job.time,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'completed':
        return Colors.purple;
      case 'assigned':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
