import 'package:contractor/app/auth/register/controller/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// Header
            Container(
              height: height * 0.28,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: width * 0.06),
              decoration: const BoxDecoration(
                color: Color(0xFF0D1026),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(-20),
                  bottomRight: Radius.circular(-20),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * 0.07,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please sign up to get started',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: width * 0.04,
                    ),
                  ),
                ],
              ),
            ),

            /// Form
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.08,
                  vertical: height * 0.03,
                ),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Name
                      const Text('NAME'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: controller.nameController,
                        decoration: _inputDecoration('John Doe'),
                        validator: (value) =>
                            value!.isEmpty ? 'Name is required' : null,
                      ),

                      const SizedBox(height: 16),

                      /// Email
                      const Text('EMAIL'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: controller.emailController,
                        decoration: _inputDecoration('example@gmail.com'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value!.isEmpty ? 'Email is required' : null,
                      ),

                      const SizedBox(height: 16),

                      /// Phone
                      const Text('PHONE'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: controller.phoneController,
                        decoration: _inputDecoration('07XXXXXXXX'),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone number is required';
                          }
                          if (value.length < 9) {
                            return 'Enter a valid phone number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      /// Password
                      const Text('PASSWORD'),
                      const SizedBox(height: 6),
                      Obx(
                        () => TextFormField(
                          controller: controller.passwordController,
                          obscureText: controller.model.value.obscurePassword,
                          decoration: _inputDecoration(
                            '********',
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.model.value.obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: controller.togglePasswordVisibility,
                            ),
                          ),
                          validator: (value) => value!.length < 6
                              ? 'Password must be at least 6 characters'
                              : null,
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// Confirm Password
                      const Text('RE-TYPE PASSWORD'),
                      const SizedBox(height: 6),
                      Obx(
                        () => TextFormField(
                          controller: controller.confirmPasswordController,
                          obscureText:
                              controller.model.value.obscureConfirmPassword,
                          decoration: _inputDecoration(
                            '********',
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.model.value.obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed:
                                  controller.toggleConfirmPasswordVisibility,
                            ),
                          ),
                          validator: (value) =>
                              value != controller.passwordController.text
                              ? 'Passwords do not match'
                              : null,
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// Register Button
                      SizedBox(
                        width: double.infinity,
                        height: height * 0.065,
                        child: Obx(
                          () => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: controller.isLoading.value
                                  ? Colors.grey
                                  : Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.register,
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'SIGN UP',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}
