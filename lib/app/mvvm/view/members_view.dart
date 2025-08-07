import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


import '../../config/app_colors.dart';
import '../view_model/members_controller.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MembersController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Members', style: TextStyle(color: AppColors.text)),
        backgroundColor: AppColors.glass,
      ),
      body: Obx(
            () => SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Team Members',
                style: TextStyle(fontSize: 20.sp, color: AppColors.text, fontWeight: FontWeight.bold),
              ).animate().fadeIn(duration: 500.ms),
              SizedBox(height: 16.h),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.users.length,
                itemBuilder: (context, index) {
                  final user = controller.users[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.glass,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8.r,
                          spreadRadius: 2.r,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(12.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name ?? user.email ?? 'Unknown',
                              style: TextStyle(fontSize: 16.sp, color: AppColors.text),
                            ),
                            Text(
                              'Role: ${user.role ?? 'N/A'}',
                              style: TextStyle(fontSize: 14.sp, color: AppColors.text.withOpacity(0.7)),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            DropdownButton<String>(
                              value: user.role,
                              items: ['admin', 'dev', 'pm', 'lead', 'cto', 'designer']
                                  .map((role) => DropdownMenuItem(
                                value: role,
                                child: Text(role[0].toUpperCase() + role.substring(1), style: TextStyle(color: AppColors.text)),
                              ))
                                  .toList(),
                              onChanged: (value) => controller.updateUserRole(user.id, value!),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => controller.deleteUser(user.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms + (index * 100).ms).slideY();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}