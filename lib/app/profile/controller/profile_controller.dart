// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:contractor/app/home/controller/home_controller.dart';
import '../model/profile_model.dart';

class ProfileController extends GetxController {
  /// REUSE HOME CONTROLLER (single source of truth)
  final HomeController home = Get.find<HomeController>();

  /// USER DATA (NO HARDCODE)
  final RxString userName = ''.obs;
  final RxString userRole = ''.obs;
  final RxString profileImageUrl = ''.obs; // optional if available later

  /// MENU ITEMS
  final RxList<ProfileMenuItem> menuItems = <ProfileMenuItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _bindUserData();
    _buildMenu();
  }

  void _bindUserData() {
    /// INITIAL VALUES
    userName.value = home.model.value.userName;
    userRole.value = home.model.value.userType;

    /// AUTO UPDATE IF HOME DATA CHANGES
    ever(home.model, (_) {
      userName.value = home.model.value.userName;
      userRole.value = home.model.value.userType;
    });
  }

  void _buildMenu() {
    menuItems.assignAll([
      ProfileMenuItem(
        title: 'My Profile',
        route: '/edit-profile',
        icon: Icons.person_outline,
      ),
      ProfileMenuItem(
        title: 'Language',
        route: '/language',
        icon: Icons.language,
      ),
      ProfileMenuItem(
        title: userRole.value == 'CLIENT' ? 'My Jobs' : 'Posted Jobs',
        route: '/my-jobs',
        icon: Icons.work_outline,
      ),
      ProfileMenuItem(
        title: 'Settings',
        route: '/settings',
        icon: Icons.settings_outlined,
      ),
      ProfileMenuItem(
        title: 'Help Center',
        route: '/help',
        icon: Icons.help_outline,
      ),
      ProfileMenuItem(
        title: 'Privacy Policy',
        route: '/privacy',
        icon: Icons.lock_outline,
      ),

      ProfileMenuItem(
        title: 'Logout',
        route: '/logout',
        icon: Icons.logout,
        isLogout: true,
      ),
    ]);
  }

  void onMenuTap(ProfileMenuItem item) {
    if (item.isLogout) {
      _showLogoutDialog();
    } else {
      Get.toNamed(item.route);
    }
  }

  void _showLogoutDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// ICON
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, color: Colors.red, size: 28),
              ),

              const SizedBox(height: 16),

              /// TITLE
              const Text(
                'Log out',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              /// MESSAGE
              Text(
                'Are you sure you want to log out of your account?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),

              const SizedBox(height: 24),

              /// ACTIONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 38, 33, 13),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        home.logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Yes, Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
