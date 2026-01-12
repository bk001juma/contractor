import 'package:contractor/app/auth/login/model/login_model.dart';
import 'package:contractor/app/routes/app_route.dart';
import 'package:contractor/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final model = LoginModel().obs;
  final AuthService _authService = AuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  void togglePasswordVisibility() {
    model.update((val) {
      val!.obscurePassword = !val.obscurePassword;
    });
  }

  void toggleRememberMe(bool? value) {
    model.update((val) {
      val!.rememberMe = value ?? false;
    });
  }

  void clearError() {
    errorMessage.value = '';
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Update model
    model.update((val) {
      val!.email = emailController.text.trim().toLowerCase();
      val.password = passwordController.text;
    });

    // Start loading
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Call API
      await _authService.login(
        email: model.value.email,
        password: model.value.password,
      );

      // **NO SNACKBAR - Just navigate**
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      // Handle error - Show in errorMessage only
      errorMessage.value = e.toString().replaceAll('ApiException: ', '');

      // You can update the UI to show this error in a Text widget
      // Or use a simple dialog instead
      Get.dialog(
        AlertDialog(
          title: const Text('Login Failed'),
          content: Text(errorMessage.value),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('OK')),
          ],
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
