// ignore_for_file: deprecated_member_use

import 'package:contractor/app/home/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;
    final textScale = media.textScaleFactor.clamp(0.9, 1.1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Obx(
          () => controller.isLoading.value
              ? _buildLoadingView()
              : _buildHomeView(width, height, textScale),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Color(0xFF0D1026)),
      ),
    );
  }

  Widget _buildHomeView(double width, double height, double textScale) {
    return RefreshIndicator(
      onRefresh: () async => controller.refreshData(),
      child: CustomScrollView(
        slivers: [
          /// APP BAR
          SliverAppBar(
            backgroundColor: const Color(0xFF0D1026),
            expandedHeight: height * 0.22,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.05,
                      vertical: constraints.maxHeight * 0.15,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back,',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: width * 0.038 * textScale,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    controller.model.value.userName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: width * 0.055 * textScale,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Get.toNamed('/profile'),
                              child: CircleAvatar(
                                radius: width * 0.06,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  color: const Color(0xFF0D1026),
                                  size: width * 0.06,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// LOCATION + ROLE
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: Colors.white.withOpacity(0.8),
                              size: width * 0.045,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                controller.model.value.userLocation,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: width * 0.038 * textScale,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: width * 0.04,
                                vertical: height * 0.005,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    controller.model.value.userType ==
                                        'CONTRACTOR'
                                    ? Colors.orange.withOpacity(0.2)
                                    : Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                controller.model.value.userType,
                                style: TextStyle(
                                  fontSize: width * 0.034 * textScale,
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
                  );
                },
              ),
            ),
          ),

          /// STATS
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(width * 0.05),
              child: _buildStatsCards(width, textScale),
            ),
          ),

          /// QUICK ACTIONS
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: width * 0.05),
              child: _buildQuickActions(width, textScale),
            ),
          ),

          /// CATEGORIES
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: width * 0.05, top: width * 0.05),
              child: _buildCategoriesGrid(width, height, textScale),
            ),
          ),

          /// ACTIVITIES
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(width * 0.05),
              child: _buildActivitiesList(width, textScale),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  /// STATS (IN A SINGLE ROW)
  Widget _buildStatsCards(double width, double textScale) {
    return Row(
      children: [
        /// ACTIVE JOBS CARD
        Expanded(
          child: _statCard(
            title: 'Active Jobs',
            value: controller.model.value.activeJobs.toString(),
            icon: Icons.work_outline,
            color: const Color(0xFF4CAF50),
            width: width,
            textScale: textScale,
          ),
        ),
        SizedBox(width: width * 0.02),

        /// EARNINGS/SPENT CARD
        Expanded(
          child: _statCard(
            title: controller.model.value.userType == 'CONTRACTOR'
                ? 'Earnings'
                : 'Spent',
            value:
                'TZS ${controller.model.value.totalEarnings.toStringAsFixed(0)}',
            icon: Icons.attach_money_outlined,
            color: const Color(0xFF2196F3),
            width: width,
            textScale: textScale,
          ),
        ),
        SizedBox(width: width * 0.02),

        /// COMPLETED JOBS CARD
        Expanded(
          child: _statCard(
            title: 'Completed',
            value: controller.model.value.completedJobs.toString(),
            icon: Icons.check_circle_outline,
            color: const Color(0xFF9C27B0),
            width: width,
            textScale: textScale,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double width,
    required double textScale,
  }) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: width * 0.07),
          SizedBox(height: width * 0.03),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: width * 0.055 * textScale,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: width * 0.034 * textScale,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// QUICK ACTIONS WITH HEADING
Widget _buildQuickActions(double width, double textScale) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      /// HEADING
      Padding(
        padding: EdgeInsets.only(left: width * 0.02, bottom: width * 0.03),
        child: Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: width * 0.05 * textScale,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0D1026),
          ),
        ),
      ),
      
      /// ACTIONS LIST
      SizedBox(
        height: width * 0.31,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.model.value.quickActions.length,
          itemBuilder: (_, index) {
            final action = controller.model.value.quickActions[index];
            return GestureDetector(
               onTap: () => controller.handleQuickAction(action),
              child: Container(
                width: width * 0.22,
                margin: EdgeInsets.only(right: width * 0.04),
                padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: action.color.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(action.icon,
                        style: TextStyle(fontSize: width * 0.075)),
                    SizedBox(height: width * 0.02),
                    Text(
                      action.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * 0.034 * textScale,
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
    ],
  );
}

  /// CATEGORIES
  /// CATEGORIES
  Widget _buildCategoriesGrid(double width, double height, double textScale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADING
        Padding(
          padding: EdgeInsets.only(left: width * 0.02, bottom: width * 0.03),
          child: Text(
            'Job Categories',
            style: TextStyle(
              fontSize: width * 0.05 * textScale,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D1026),
            ),
          ),
        ),

        /// GRID VIEW
        SizedBox(
          height: height * 0.3,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.model.value.featuredCategories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: width * 0.03,
              crossAxisSpacing: width * 0.03,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (_, index) {
              final category = controller.model.value.featuredCategories[index];
              return Container(
                padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  color: category.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.icon,
                      style: TextStyle(fontSize: width * 0.07),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: width * 0.04 * textScale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${category.jobCount} jobs',
                          style: TextStyle(
                            fontSize: width * 0.03 * textScale,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// ACTIVITIES
  Widget _buildActivitiesList(double width, double textScale) {
    return Column(
      children: controller.model.value.recentActivities
          .map(
            (activity) => Container(
              margin: EdgeInsets.only(bottom: width * 0.04),
              padding: EdgeInsets.all(width * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: width * 0.06,
                    backgroundColor: activity.iconColor.withOpacity(0.1),
                    child: Icon(activity.icon, color: activity.iconColor),
                  ),
                  SizedBox(width: width * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: width * 0.045 * textScale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          activity.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: width * 0.037 * textScale,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    activity.time,
                    style: TextStyle(
                      fontSize: width * 0.032 * textScale,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
