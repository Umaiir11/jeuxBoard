import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../config/app_colors.dart';
import '../model/firebase_models/project_module_model.dart';
import '../model/firebase_models/user_model.dart';
import '../view_model/auth_controller.dart';
import '../view_model/project_controller.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProjectController>();
    final authController = Get.find<AuthController>();
    final projectId = Get.arguments as String;
    controller.fetchModules(projectId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Project Details', style: TextStyle(color: AppColors.text)),
        backgroundColor: AppColors.glass,
        actions: [
          if (authController.user.value?.role == 'admin')
            IconButton(
              icon: Icon(Icons.add, color: AppColors.primary),
              onPressed: () {
                // Add module form (simplified for brevity)
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Modules',
              style: TextStyle(fontSize: 20.sp, color: AppColors.text, fontWeight: FontWeight.bold),
            ).animate().fadeIn(duration: 500.ms),
            SizedBox(height: 16.h),
            Obx(
                  () => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16.w,
                  columns: [
                    DataColumn(label: Text('Module Name', style: TextStyle(color: AppColors.text))),
                    DataColumn(label: Text('Status', style: TextStyle(color: AppColors.text))),
                    DataColumn(label: Text('ETA', style: TextStyle(color: AppColors.text))),
                    DataColumn(label: Text('Assigned Dev', style: TextStyle(color: AppColors.text))),
                    DataColumn(label: Text('Notes', style: TextStyle(color: AppColors.text))),
                  ],
                  rows: controller.modules.map((module) {
                    final canEdit = _canEditField(authController.user.value?.role, module);
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(module.moduleName ?? 'N/A', style: TextStyle(color: AppColors.text)),
                          onTap: canEdit['module_name']!
                              ? () => _editField(context, module, 'module_name', module.moduleName)
                              : null,
                        ),
                        DataCell(
                          DropdownButton<String>(
                            value: module.status,
                            items: ['not_started', 'in_progress', 'blocked', 'done']
                                .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status[0].toUpperCase() + status.substring(1), style: TextStyle(color: AppColors.text)),
                            ))
                                .toList(),
                            onChanged: canEdit['status']!
                                ? (value) {
                              controller.updateModule(module.copyWith(status: value));
                            }
                                : null,
                          ),
                        ),
                        DataCell(
                          Text(module.eta != null ? DateFormat('yyyy-MM-dd').format(module.eta!) : 'N/A', style: TextStyle(color: AppColors.text)),
                          onTap: canEdit['eta']!
                              ? () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: module.eta ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030),
                            );
                            if (pickedDate != null) {
                              controller.updateModule(module.copyWith(eta: pickedDate));
                            }
                          }
                              : null,
                        ),
                        DataCell(
                          Text(controller.devs.firstWhere((dev) => dev.id == module.assignedDevId, orElse: () => UserModel(id: '')).name ?? 'N/A',
                              style: TextStyle(color: AppColors.text)),
                          onTap: canEdit['assigned_dev_id']!
                              ? () {
                            _editDev(context, module, controller);
                          }
                              : null,
                        ),
                        DataCell(
                          Text(module.notes ?? 'N/A', style: TextStyle(color: AppColors.text)),
                          onTap: canEdit['notes']!
                              ? () => _editField(context, module, 'notes', module.notes)
                              : null,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(),
            ),
            SizedBox(height: 16.h),
            Text(
              'Calendar View',
              style: TextStyle(fontSize: 20.sp, color: AppColors.text, fontWeight: FontWeight.bold),
            ).animate().fadeIn(duration: 700.ms),
            SizedBox(height: 16.h),
            Obx(
                  () => TableCalendar(
                firstDay: DateTime.now().subtract(Duration(days: 365)),
                lastDay: DateTime.now().add(Duration(days: 365)),
                focusedDay: DateTime.now(),
                calendarFormat: CalendarFormat.month,
                eventLoader: (day) {
                  return controller.modules
                      .where((module) => module.eta != null && isSameDay(module.eta!, day))
                      .map((module) => module.moduleName ?? 'Event')
                      .toList();
                },
                calendarStyle: CalendarStyle(
                  defaultTextStyle: TextStyle(color: AppColors.text),
                  weekendTextStyle: TextStyle(color: AppColors.text),
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  titleTextStyle: TextStyle(color: AppColors.text),
                  formatButtonTextStyle: TextStyle(color: AppColors.text),
                  leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.text),
                  rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.text),
                ),
              ).animate().fadeIn(duration: 800.ms).slideY(),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, bool> _canEditField(String? role, ProjectModuleModel module) {
    final userId = Get.find<AuthController>().user.value?.id;
    return {
      'module_name': role == 'admin',
      'status': role == 'admin' || role == 'pm' || (role == 'dev' && module.assignedDevId == userId),
      'eta': role == 'admin' || role == 'pm',
      'assigned_dev_id': role == 'admin',
      'notes': true,
      'design_locked_date': role == 'admin' || role == 'designer',
      'dev_start_date': role == 'admin' || (role == 'dev' && module.assignedDevId == userId),
      'self_qa_date': role == 'admin' || (role == 'dev' && module.assignedDevId == userId),
      'lead_signoff_date': role == 'admin' || role == 'lead',
      'pm_review_date': role == 'admin' || role == 'pm',
      'cto_review_status': role == 'admin' || role == 'cto',
      'client_ready_status': role == 'admin' || role == 'pm',
    };
  }

  void _editField(BuildContext context, ProjectModuleModel module, String field, String? currentValue) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.glass,
        title: Text('Edit $field', style: TextStyle(color: AppColors.text)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: AppColors.text),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.glass,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.accent)),
          ),
          TextButton(
            onPressed: () {
              Get.find<ProjectController>().updateModule(module.copyWithMap({field: controller.text}));
              Navigator.pop(context);
            },
            child: Text('Save', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _editDev(BuildContext context, ProjectModuleModel module, ProjectController controller) {
    final selectedDev = RxString(module.assignedDevId ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.glass,
        title: Text('Assign Developer', style: TextStyle(color: AppColors.text)),
        content: Obx(
              () => DropdownButton<String>(
            value: selectedDev.value.isEmpty ? null : selectedDev.value,
            items: controller.devs
                .map((dev) => DropdownMenuItem(
              value: dev.id,
              child: Text(dev.name ?? dev.email ?? 'Unknown', style: TextStyle(color: AppColors.text)),
            ))
                .toList(),
            onChanged: (value) => selectedDev.value = value!,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.accent)),
          ),
          TextButton(
            onPressed: () {
              controller.updateModule(module.copyWith(assignedDevId: selectedDev.value));
              Navigator.pop(context);
            },
            child: Text('Save', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

extension on ProjectModuleModel {
  ProjectModuleModel copyWith({
    String? moduleName,
    String? status,
    DateTime? eta,
    String? assignedDevId,
    String? notes,
    DateTime? designLockedDate,
    DateTime? devStartDate,
    DateTime? selfQaDate,
    DateTime? leadSignoffDate,
    DateTime? pmReviewDate,
    String? ctoReviewStatus,
    String? clientReadyStatus,
  }) {
    return ProjectModuleModel(
      id: id,
      projectId: projectId,
      moduleName: moduleName ?? this.moduleName,
      platformStack: platformStack,
      assignedDevId: assignedDevId ?? this.assignedDevId,
      designLockedDate: designLockedDate ?? this.designLockedDate,
      devStartDate: devStartDate ?? this.devStartDate,
      selfQaDate: selfQaDate ?? this.selfQaDate,
      leadSignoffDate: leadSignoffDate ?? this.leadSignoffDate,
      pmReviewDate: pmReviewDate ?? this.pmReviewDate,
      ctoReviewStatus: ctoReviewStatus ?? this.ctoReviewStatus,
      clientReadyStatus: clientReadyStatus ?? this.clientReadyStatus,
      status: status ?? this.status,
      eta: eta ?? this.eta,
      sprint: sprint,
      notes: notes ?? this.notes,
    );
  }

  ProjectModuleModel copyWithMap(Map<String, dynamic> updates) {
    return ProjectModuleModel(
      id: id,
      projectId: projectId,
      moduleName: updates['module_name'] ?? moduleName,
      platformStack: platformStack,
      assignedDevId: updates['assigned_dev_id'] ?? assignedDevId,
      designLockedDate: updates['design_locked_date'] ?? designLockedDate,
      devStartDate: updates['dev_start_date'] ?? devStartDate,
      selfQaDate: updates['self_qa_date'] ?? selfQaDate,
      leadSignoffDate: updates['lead_signoff_date'] ?? leadSignoffDate,
      pmReviewDate: updates['pm_review_date'] ?? pmReviewDate,
      ctoReviewStatus: updates['cto_review_status'] ?? ctoReviewStatus,
      clientReadyStatus: updates['client_ready_status'] ?? clientReadyStatus,
      status: updates['status'] ?? status,
      eta: updates['eta'] ?? eta,
      sprint: updates['sprint'] ?? sprint,
      notes: updates['notes'] ?? notes,
    );
  }
}