// lib/app/jobs/view/my_jobs_view.dart
// ignore_for_file: deprecated_member_use

import 'package:contractor/app/home/controller/my_jobs_controller.dart';
import 'package:contractor/app/model/job.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyJobsView extends GetView<MyJobsController> {
  const MyJobsView({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;
    final textScale = media.textScaleFactor.clamp(0.9, 1.1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildCustomAppBar(width, textScale),

            // Statistics Cards
            Obx(() => _buildStatisticsCards(width, textScale)),

            // Filter Chips
            _buildFilterChips(width, textScale),

            // Search Bar
            _buildSearchBar(width, textScale),

            // Jobs List
            Expanded(child: _buildJobsList(width, height, textScale)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/post-job'),
        backgroundColor: const Color(0xFF0D1026),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCustomAppBar(double width, double textScale) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.05,
        vertical: width * 0.04,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1026),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: width * 0.1,
              height: width * 0.1,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: width * 0.05,
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(width: width * 0.04),

          // Title
          Expanded(
            child: Text(
              'My Jobs',
              style: TextStyle(
                color: Colors.white,
                fontSize: width * 0.05 * textScale,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // Filter Button
          GestureDetector(
            onTap: _showSortOptions,
            child: Container(
              width: width * 0.1,
              height: width * 0.1,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.filter_list_rounded,
                size: width * 0.05,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(double width, double textScale) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Total',
              value: controller.totalJobs.value.toString(),
              icon: Icons.work_outline,
              color: const Color(0xFF0D1026),
              width: width,
              textScale: textScale,
            ),
          ),
          SizedBox(width: width * 0.02),
          Expanded(
            child: _buildStatCard(
              title: 'Active',
              value: controller.activeJobs.value.toString(),
              icon: Icons.check_circle_outline,
              color: Colors.green,
              width: width,
              textScale: textScale,
            ),
          ),
          SizedBox(width: width * 0.02),
          Expanded(
            child: _buildStatCard(
              title: 'Completed',
              value: controller.completedJobs.value.toString(),
              icon: Icons.done_all,
              color: Colors.purple,
              width: width,
              textScale: textScale,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double width,
    required double textScale,
  }) {
    return Container(
      padding: EdgeInsets.all(width * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: width * 0.05, color: color),
              SizedBox(width: width * 0.02),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: width * 0.032 * textScale,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: width * 0.02),
          Text(
            value,
            style: TextStyle(
              fontSize: width * 0.05 * textScale,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D1026),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(double width, double textScale) {
    return Obx(
      () => SizedBox(
        height: width * 0.12,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: width * 0.04),
          children: [
            // All Jobs Chip
            _buildFilterChip(
              label: 'All',
              isSelected: controller.selectedStatus.value == null,
              onTap: () => controller.filterByStatus(null),
              width: width,
              textScale: textScale,
            ),

            // Active Jobs Chip
            _buildFilterChip(
              label: 'Active',
              isSelected: controller.selectedStatus.value == JobStatus.ACTIVE,
              onTap: () => controller.filterByStatus(JobStatus.ACTIVE),
              width: width,
              textScale: textScale,
              color: Colors.green,
            ),

            // Pending Jobs Chip
            _buildFilterChip(
              label: 'Pending',
              isSelected: controller.selectedStatus.value == JobStatus.PENDING,
              onTap: () => controller.filterByStatus(JobStatus.PENDING),
              width: width,
              textScale: textScale,
              color: Colors.orange,
            ),

            // In Progress Chip
            _buildFilterChip(
              label: 'In Progress',
              isSelected:
                  controller.selectedStatus.value == JobStatus.IN_PROGRESS,
              onTap: () => controller.filterByStatus(JobStatus.IN_PROGRESS),
              width: width,
              textScale: textScale,
              color: Colors.blue,
            ),

            // Completed Chip
            _buildFilterChip(
              label: 'Completed',
              isSelected:
                  controller.selectedStatus.value == JobStatus.COMPLETED,
              onTap: () => controller.filterByStatus(JobStatus.COMPLETED),
              width: width,
              textScale: textScale,
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required double width,
    required double textScale,
    Color color = const Color(0xFF0D1026),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: width * 0.02),
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: width * 0.02,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Icon(Icons.check_circle, size: width * 0.04, color: color),
            if (isSelected) SizedBox(width: width * 0.01),
            Text(
              label,
              style: TextStyle(
                fontSize: width * 0.035 * textScale,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(double width, double textScale) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: width * 0.02,
      ),
      child: Container(
        height: width * 0.12,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: controller.searchJobs,
          decoration: InputDecoration(
            hintText: 'Search jobs...',
            hintStyle: TextStyle(
              fontSize: width * 0.038 * textScale,
              color: Colors.grey[400],
            ),
            prefixIcon: Icon(
              Icons.search,
              size: width * 0.05,
              color: Colors.grey[500],
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: width * 0.04),
          ),
          style: TextStyle(fontSize: width * 0.038 * textScale),
        ),
      ),
    );
  }

  Widget _buildJobsList(double width, double height, double textScale) {
    return Obx(() {
      if (controller.isLoading.value && controller.jobs.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value.isNotEmpty && controller.jobs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: width * 0.15,
                color: Colors.grey[400],
              ),
              SizedBox(height: width * 0.04),
              Text(
                'Failed to load jobs',
                style: TextStyle(
                  fontSize: width * 0.04 * textScale,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: width * 0.02),
              Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: width * 0.035 * textScale,
                  color: Colors.grey[500],
                ),
              ),
              SizedBox(height: width * 0.04),
              ElevatedButton(
                onPressed: controller.refreshJobs,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D1026),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: width * 0.038 * textScale,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      if (controller.filteredJobs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.work_outline,
                size: width * 0.15,
                color: Colors.grey[400],
              ),
              SizedBox(height: width * 0.04),
              Text(
                controller.selectedStatus.value == null
                    ? 'No jobs found'
                    : 'No ${controller.getStatusText(controller.selectedStatus.value!).toLowerCase()} jobs',
                style: TextStyle(
                  fontSize: width * 0.04 * textScale,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: width * 0.02),
              Text(
                controller.selectedStatus.value == null
                    ? 'Post your first job to get started'
                    : 'Try selecting a different filter',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: width * 0.035 * textScale,
                  color: Colors.grey[500],
                ),
              ),
              if (controller.selectedStatus.value == null)
                Padding(
                  padding: EdgeInsets.only(top: width * 0.04),
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed('/post-job'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D1026),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Post a Job',
                      style: TextStyle(
                        fontSize: width * 0.038 * textScale,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshJobs,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.04,
            vertical: width * 0.02,
          ),
          itemCount:
              controller.filteredJobs.length +
              (controller.hasMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.filteredJobs.length) {
              return controller.isLoadingMore.value
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: width * 0.04),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : SizedBox(
                      height: width * 0.1,
                      child: Center(
                        child: Text(
                          'No more jobs',
                          style: TextStyle(
                            fontSize: width * 0.035 * textScale,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    );
            }

            final job = controller.filteredJobs[index];
            return _buildJobCard(job, width, textScale);
          },
        ),
      );
    });
  }

  Widget _buildJobCard(JobResponse job, double width, double textScale) {
    return GestureDetector(
      onTap: () => controller.viewJobDetails(job),
      child: Container(
        margin: EdgeInsets.only(bottom: width * 0.03),
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
          children: [
            // Job Header
            Container(
              padding: EdgeInsets.all(width * 0.04),
              decoration: BoxDecoration(
                color: controller.getStatusColor(job.status).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: width * 0.042 * textScale,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0D1026),
                          ),
                        ),
                        SizedBox(height: width * 0.01),
                        Row(
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: width * 0.04,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: width * 0.01),
                            Text(
                              controller.getCategoryText(job.tradeCategory),
                              style: TextStyle(
                                fontSize: width * 0.034 * textScale,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.03,
                      vertical: width * 0.01,
                    ),
                    decoration: BoxDecoration(
                      color: controller.getStatusColor(job.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      controller.getStatusText(job.status),
                      style: TextStyle(
                        fontSize: width * 0.03 * textScale,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Job Details
            Padding(
              padding: EdgeInsets.all(width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    job.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: width * 0.036 * textScale,
                      color: Colors.grey[700],
                    ),
                  ),

                  SizedBox(height: width * 0.03),

                  // Details Row
                  Row(
                    children: [
                      // Location
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: width * 0.04,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: width * 0.01),
                            Expanded(
                              child: Text(
                                job.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: width * 0.034 * textScale,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Budget
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.attach_money_outlined,
                              size: width * 0.04,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: width * 0.01),
                            Expanded(
                              child: Text(
                                '${controller.formatCurrency(job.budgetMin)} - ${controller.formatCurrency(job.budgetMax)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: width * 0.034 * textScale,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: width * 0.03),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Urgency
                      Row(
                        children: [
                          Icon(
                            controller.getUrgencyIcon(job.urgencyLevel),
                            size: width * 0.04,
                            color: controller.getUrgencyColor(job.urgencyLevel),
                          ),
                          SizedBox(width: width * 0.01),
                          Text(
                            job.urgencyLevel.name,
                            style: TextStyle(
                              fontSize: width * 0.032 * textScale,
                              color: controller.getUrgencyColor(
                                job.urgencyLevel,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      // Time & Bids
                      Row(
                        children: [
                          // Time
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_outlined,
                                size: width * 0.04,
                                color: Colors.grey[500],
                              ),
                              SizedBox(width: width * 0.01),
                              Text(
                                controller.formatDate(job.createdAt),
                                style: TextStyle(
                                  fontSize: width * 0.032 * textScale,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(width: width * 0.03),

                          // Bids
                          Row(
                            children: [
                              Icon(
                                Icons.handyman_outlined,
                                size: width * 0.04,
                                color: Colors.grey[500],
                              ),
                              SizedBox(width: width * 0.01),
                              Text(
                                '${job.bidsCount} bids',
                                style: TextStyle(
                                  fontSize: width * 0.032 * textScale,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action Buttons
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: width * 0.02,
              ),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
              ),
              child: Row(
                children: [
                  // View Details Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => controller.viewJobDetails(job),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: width * 0.035 * textScale,
                          color: const Color(0xFF0D1026),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: width * 0.02),

                  // More Options Menu
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      _handleJobAction(value, job);
                    },
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: width * 0.05),
                            SizedBox(width: width * 0.02),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: width * 0.05,
                              color: Colors.red,
                            ),
                            SizedBox(width: width * 0.02),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                      if (job.status == JobStatus.ACTIVE)
                        PopupMenuItem(
                          value: 'cancel',
                          child: Row(
                            children: [
                              Icon(
                                Icons.cancel_outlined,
                                size: width * 0.05,
                                color: Colors.orange,
                              ),
                              SizedBox(width: width * 0.02),
                              Text(
                                'Cancel',
                                style: TextStyle(color: Colors.orange),
                              ),
                            ],
                          ),
                        ),
                      if (job.status == JobStatus.IN_PROGRESS)
                        PopupMenuItem(
                          value: 'complete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: width * 0.05,
                                color: Colors.green,
                              ),
                              SizedBox(width: width * 0.02),
                              Text(
                                'Mark Complete',
                                style: TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleJobAction(String action, JobResponse job) {
    switch (action) {
      case 'edit':
        Get.toNamed('/post-job', arguments: job.id);
        break;
      case 'delete':
        controller.deleteJob(job.id);
        break;
      case 'cancel':
        controller.updateJobStatus(job.id, JobStatus.CANCELLED);
        break;
      case 'complete':
        controller.updateJobStatus(job.id, JobStatus.COMPLETED);
        break;
    }
  }

  void _showSortOptions() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1026),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: const Center(
                child: Text(
                  'Sort By',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.access_time_outlined),
              title: const Text('Date Posted (Newest First)'),
              onTap: () {
                Get.back();
                // Implement sort logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time_outlined),
              title: const Text('Date Posted (Oldest First)'),
              onTap: () {
                Get.back();
                // Implement sort logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money_outlined),
              title: const Text('Budget (High to Low)'),
              onTap: () {
                Get.back();
                // Implement sort logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money_outlined),
              title: const Text('Budget (Low to High)'),
              onTap: () {
                Get.back();
                // Implement sort logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_red_eye_outlined),
              title: const Text('Most Views'),
              onTap: () {
                Get.back();
                // Implement sort logic
              },
            ),
          ],
        ),
      ),
    );
  }
}
