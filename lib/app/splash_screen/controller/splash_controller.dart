import 'dart:async';
import 'package:contractor/app/routes/app_route.dart';
import 'package:contractor/app/splash_screen/model/splash_model.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  late SplashModel model;

  @override
  void onInit() {
    super.onInit();

    model = SplashModel(logoPath: 'assets/images/11.jpg');

    _navigateNext();
  }

  void _navigateNext() {
    Timer(const Duration(seconds: 3), () {
      // Change route as needed
      Get.offAllNamed(AppRoutes.onboarding);
    });
  }
}
