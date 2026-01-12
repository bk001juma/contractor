import 'package:contractor/app/auth/register/model/register_model.dart';
import 'package:contractor/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final model = RegisterModel().obs;
  final AuthService _authService = AuthService();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Format phone number to Tanzanian format
  String _formatPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // If starts with 0, replace with 255
    if (cleaned.startsWith('0')) {
      cleaned = '255${cleaned.substring(1)}';
    }
    
    // If starts with 7 or 6 (Tanzanian mobile), add 255
    if (cleaned.startsWith('7') || cleaned.startsWith('6')) {
      cleaned = '255$cleaned';
    }
    
    return cleaned;
  }

  void togglePasswordVisibility() {
    model.update((val) {
      val!.obscurePassword = !val.obscurePassword;
    });
  }

  void toggleConfirmPasswordVisibility() {
    model.update((val) {
      val!.obscureConfirmPassword = !val.obscureConfirmPassword;
    });
  }

  void clearError() {
    errorMessage.value = '';
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Update model
    model.update((val) {
      val!.name = nameController.text.trim();
      val.email = emailController.text.trim().toLowerCase();
      val.phone = _formatPhoneNumber(phoneController.text.trim());
      val.password = passwordController.text;
      val.confirmPassword = confirmPasswordController.text;
    });

    // Start loading
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Call API
      // ignore: unused_local_variable
      final response = await _authService.register(
        fullName: model.value.name,
        email: model.value.email,
        phoneNumber: model.value.phone,
        password: model.value.password,
        userType: 'CLIENT', // Default for now
      );

      // Success
      Get.back(); // Close register screen
      Get.snackbar(
        'Registration Successful!',
        'Welcome to FundiSmart! Please verify your email.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      // Navigate to login
      Get.offNamed('/login');

    } catch (e) {
      // Handle error
      errorMessage.value = e.toString().replaceAll('ApiException: ', '');
      
      Get.snackbar(
        'Registration Failed',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}