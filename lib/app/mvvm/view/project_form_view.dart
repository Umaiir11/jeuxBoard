import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';

import '../../config/app_colors.dart';
import '../model/firebase_models/project_model.dart';
import '../view_model/project_controller.dart';

class ProjectFormScreen extends StatelessWidget {
  const ProjectFormScreen({super.key, this.project});

  final ProjectModel? project;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProjectController>();
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: project?.title);
    final stackController = TextEditingController(text: project?.stack);
    final sprintController = TextEditingController(text: project?.sprint);
    final notesController = TextEditingController(text: project?.notes);
    final eta = Rx<DateTime?>(project?.eta);
    final assignedDevs = RxList<String>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          project == null ? 'Add Project' : 'Edit Project',
          style: TextStyle(color: AppColors.text),
        ),
        backgroundColor: AppColors.glass,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Container(
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
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Project Title',
                    labelStyle: TextStyle(color: AppColors.text.withOpacity(0.7)),
                    filled: true,
                    fillColor: AppColors.glass,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  style: TextStyle(color: AppColors.text),
                  validator: (value) => value!.isEmpty ? 'Enter a title' : null,
                ).animate().fadeIn(duration: 500.ms).slideY(),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: stackController,
                  decoration: InputDecoration(
                    labelText: 'Stack / Platform',
                    labelStyle: TextStyle(color: AppColors.text.withOpacity(0.7)),
                    filled: true,
                    fillColor: AppColors.glass,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  style: TextStyle(color: AppColors.text),
                ).animate().fadeIn(duration: 600.ms).slideY(),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: sprintController,
                  decoration: InputDecoration(
                    labelText: 'Sprint',
                    labelStyle: TextStyle(color: AppColors.text.withOpacity(0.7)),
                    filled: true,
                    fillColor: AppColors.glass,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  style: TextStyle(color: AppColors.text),
                ).animate().fadeIn(duration: 700.ms).slideY(),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    labelStyle: TextStyle(color: AppColors.text.withOpacity(0.7)),
                    filled: true,
                    fillColor: AppColors.glass,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  style: TextStyle(color: AppColors.text),
                  maxLines: 3,
                ).animate().fadeIn(duration: 800.ms).slideY(),
                SizedBox(height: 16.h),
                Obx(
                      () => InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: eta.value ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (pickedDate != null) {
                        eta.value = pickedDate;
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'ETA',
                        labelStyle: TextStyle(color: AppColors.text.withOpacity(0.7)),
                        filled: true,
                        fillColor: AppColors.glass,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                      child: Text(
                        eta.value != null ? DateFormat('yyyy-MM-dd').format(eta.value!) : 'Select ETA',
                        style: TextStyle(color: AppColors.text),
                      ),
                    ),
                  ).animate().fadeIn(duration: 900.ms).slideY(),
                ),
                SizedBox(height: 16.h),
                Obx(
                      () => DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Assign Developers',
                      labelStyle: TextStyle(color: AppColors.text.withOpacity(0.7)),
                      filled: true,
                      fillColor: AppColors.glass,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    isExpanded: true,
                    items: controller.devs
                        .map((dev) => DropdownMenuItem(
                      value: dev.id,
                      child: Text(
                        dev.name ?? dev.email ?? 'Unknown',
                        style: TextStyle(color: AppColors.text),
                      ),
                    ))
                        .toList(),
                    onChanged: (value) {
                      if (!assignedDevs.contains(value)) {
                        assignedDevs.add(value!);
                      }
                    },
                  ).animate().fadeIn(duration: 1000.ms).slideY(),
                ),
                SizedBox(height: 16.h),
                Obx(
                      () => Wrap(
                    spacing: 8.w,
                    children: assignedDevs
                        .map((devId) => Chip(
                      label: Text(
                        controller.devs.firstWhere((dev) => dev.id == devId).name ?? 'Unknown',
                        style: TextStyle(color: AppColors.text),
                      ),
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      deleteIcon: Icon(Icons.close, color: AppColors.text),
                      onDeleted: () {
                        assignedDevs.remove(devId);
                      },
                    ))
                        .toList(),
                  ),
                ),
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
                        final newProject = ProjectModel(
                          id: project?.id ?? FirebaseFirestore.instance.collection('projects').doc().id,
                          title: titleController.text,
                          stack: stackController.text,
                          sprint: sprintController.text,
                          notes: notesController.text,
                          eta: eta.value,
                          createdBy: FirebaseAuth.instance.currentUser!.uid,
                          createdAt: DateTime.now(),
                          status: 'not_started',
                        );
                        await controller.createOrUpdateProject(newProject, assignedDevs);
                        Get.back();
                      }
                    },
                    child: Text(
                      project == null ? 'Create Project' : 'Update Project',
                      style: TextStyle(fontSize: 16.sp, color: AppColors.text),
                    ),
                  ).animate().fadeIn(duration: 1100.ms).slideY(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}