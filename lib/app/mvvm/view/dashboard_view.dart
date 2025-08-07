import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../config/app_colors.dart';
import '../model/firebase_models/project_model.dart';
import '../view_model/auth_controller.dart';
import '../view_model/project_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProjectController>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('JeuxBoard Dashboard', style: TextStyle(color: AppColors.text)),
        backgroundColor: AppColors.glass,
        actions: [
          if (authController.user.value?.role == 'admin')
            IconButton(
              icon: Icon(Icons.add, color: AppColors.primary),
              onPressed: () => Get.toNamed('/project_form'),
            ),
          IconButton(
            icon: Icon(Icons.calendar_today, color: AppColors.accent),
            onPressed: () => Get.toNamed('/calendar'),
          ),
          IconButton(
            icon: Icon(Icons.people, color: AppColors.accent),
            onPressed: () => Get.toNamed('/members'),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.accent),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Obx(
            () => SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Projects Overview',
                style: TextStyle(fontSize: 20.sp, color: AppColors.text, fontWeight: FontWeight.bold),
              ).animate().fadeIn(duration: 500.ms),
              SizedBox(height: 16.h),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'dev').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return SizedBox();
                  final devs = snapshot.data!.docs;
                  return Row(
                    children: [
                      DropdownButton<String>(
                        hint: Text('Filter by Status', style: TextStyle(color: AppColors.text)),
                        value: controller.filterStatus.value.isEmpty ? null : controller.filterStatus.value,
                        items: ['not_started', 'in_progress', 'blocked', 'done']
                            .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status[0].toUpperCase() + status.substring(1), style: TextStyle(color: AppColors.text)),
                        ))
                            .toList(),
                        onChanged: (value) => controller.applyFilters(value, controller.filterSprint.value, controller.filterDev.value),
                      ),
                      SizedBox(width: 16.w),
                      DropdownButton<String>(
                        hint: Text('Filter by Dev', style: TextStyle(color: AppColors.text)),
                        value: controller.filterDev.value.isEmpty ? null : controller.filterDev.value,
                        items: devs
                            .map((dev) => DropdownMenuItem(
                          value: dev.id,
                          child: Text(dev['name'] ?? dev['email'], style: TextStyle(color: AppColors.text)),
                        ))
                            .toList(),
                        onChanged: (value) => controller.applyFilters(controller.filterStatus.value, controller.filterSprint.value, value),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 16.h),
              SfCartesianChart(
                primaryXAxis: CategoryAxis(labelStyle: TextStyle(color: AppColors.text)),
                primaryYAxis: NumericAxis(labelStyle: TextStyle(color: AppColors.text)),
                series: <CartesianSeries<ProjectModel, String>>[
                  BarSeries<ProjectModel, String>(
                    dataSource: controller.projects,
                    xValueMapper: (ProjectModel project, _) => project.title ?? 'Untitled',
                    yValueMapper: (ProjectModel project, _) =>
                    project.status == 'done' ? 100.0 : project.status == 'in_progress' ? 50.0 : 0.0,
                    color: AppColors.primary,
                  ),
                ],
              ).animate().fadeIn(duration: 600.ms).slideY(),

              SizedBox(height: 16.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ScreenUtil().screenWidth > 600 ? 3 : 2,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                  childAspectRatio: 1.5,
                ),
                itemCount: controller.projects.length,
                itemBuilder: (context, index) {
                  final project = controller.projects[index];
                  return GestureDetector(
                    onTap: () => Get.toNamed('/project_detail', arguments: project.id),
                    child: Container(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.title ?? 'Untitled',
                            style: TextStyle(fontSize: 16.sp, color: AppColors.text, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'ETA: ${project.eta?.toString().substring(0, 10) ?? 'N/A'}',
                            style: TextStyle(fontSize: 14.sp, color: AppColors.text.withOpacity(0.7)),
                          ),
                          Text(
                            'Status: ${project.status ?? 'Not Started'}',
                            style: TextStyle(fontSize: 14.sp, color: _getStatusColor(project.status)),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 700.ms + (index * 100).ms).slideY();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'in_progress':
        return Colors.yellow;
      case 'blocked':
        return Colors.red;
      case 'done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}