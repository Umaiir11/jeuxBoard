import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


import '../../config/app_colors.dart';
import '../view_model/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, Colors.grey[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.glass,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10.r,
                  spreadRadius: 2.r,
                ),
              ],
            ),
            width: 400.w,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Login to JeuxBoard',
                    style: TextStyle(
                      fontSize: 24.sp,
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: AppColors.text.withOpacity(0.7)),
                      filled: true,
                      fillColor: AppColors.glass,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    style: TextStyle(color: AppColors.text),
                    validator: (value) => value!.isEmpty ? 'Enter an email' : null,
                  ).animate().fadeIn(duration: 600.ms).slideY(),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: AppColors.text.withOpacity(0.7)),
                      filled: true,
                      fillColor: AppColors.glass,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    obscureText: true,
                    style: TextStyle(color: AppColors.text),
                    validator: (value) => value!.length < 6 ? 'Password must be 6+ characters' : null,
                  ).animate().fadeIn(duration: 700.ms).slideY(),
                  SizedBox(height: 24.h),
                  Obx(
                        () => controller.isLoading.value
                        ? CircularProgressIndicator(color: AppColors.primary)
                        : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          await controller.login(
                            emailController.text,
                            passwordController.text,
                          );
                        }
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(fontSize: 16.sp, color: AppColors.text),
                      ),
                    ).animate().fadeIn(duration: 800.ms).slideY(),
                  ),
                  SizedBox(height: 16.h),
                  TextButton(
                    onPressed: () => Get.toNamed('/signup'),
                    child: Text(
                      'Need an account? Sign Up',
                      style: TextStyle(color: AppColors.accent),
                    ),
                  ).animate().fadeIn(duration: 900.ms).slideY(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}