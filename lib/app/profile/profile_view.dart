// ignore_for_file: deprecated_member_use

import 'package:contractor/app/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final textScale = media.textScaleFactor.clamp(0.9, 1.1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: EdgeInsets.all(width * 0.06),
          child: Column(
            children: [
              /// PROFILE IMAGE
              Stack(
                children: [
                  CircleAvatar(
                    radius: width * 0.15,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: controller.profileImageUrl.isNotEmpty
                        ? NetworkImage(controller.profileImageUrl.value)
                        : null,
                    child: controller.profileImageUrl.isEmpty
                        ? Icon(
                            Icons.person,
                            size: width * 0.15,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: width * 0.045,
                      backgroundColor: const Color(0xFF0D1026),
                      child: Icon(
                        Icons.edit,
                        size: width * 0.04,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: width * 0.04),

              /// NAME
              Text(
                controller.userName.value,
                style: TextStyle(
                  fontSize: width * 0.055 * textScale,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: width * 0.015),

              /// ROLE BADGE
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: width * 0.015,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  controller.userRole.value,
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                    fontSize: width * 0.035,
                  ),
                ),
              ),

              SizedBox(height: width * 0.08),

              /// MENU LIST
              ...controller.menuItems.map(
                (item) => _profileTile(item, width, textScale),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileTile(item, double width, double textScale) {
    return GestureDetector(
      onTap: () => controller.onMenuTap(item),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: width * 0.045),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: width * 0.06,
              color: item.isLogout ? Colors.orange : Colors.orange,
            ),
            SizedBox(width: width * 0.04),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontSize: width * 0.045 * textScale,
                  color: item.isLogout ? Colors.black : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
