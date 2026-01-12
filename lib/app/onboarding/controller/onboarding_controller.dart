import 'package:contractor/app/onboarding/model/onboarding_model.dart';
import 'package:contractor/app/routes/app_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentIndex = 0.obs;

  final List<OnboardingModel> pages = [
    OnboardingModel(
      title: 'Manage Your Projects',
      description:
          'Track construction jobs, materials, and progress from one central platform.',
      image: 'assets/images/11.jpg',
    ),
    OnboardingModel(
      title: 'Record Transactions Easily',
      description:
          'Keep accurate records of payments, expenses, and commissions.',
      image: 'assets/images/11.jpg',
    ),
    OnboardingModel(
      title: 'Run Your Business Efficiently',
      description:
          'Simplify daily operations and focus on delivering quality work.',
      image: 'assets/images/11.jpg',
    ),
  ];

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  void nextPage() {
    if (currentIndex.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.offAllNamed(AppRoutes.loginScreen);
    }
  }

  void skip() {
    Get.offAllNamed(AppRoutes.loginScreen);
  }
}
