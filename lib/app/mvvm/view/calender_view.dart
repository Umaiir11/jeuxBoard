import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:table_calendar/table_calendar.dart';

import '../../config/app_colors.dart';
import '../view_model/project_controller.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProjectController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar View', style: TextStyle(color: AppColors.text)),
        backgroundColor: AppColors.glass,
      ),
      body: Obx(
            () => SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              TableCalendar(
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
              ).animate().fadeIn(duration: 500.ms).slideY(),
            ],
          ),
        ),
      ),
    );
  }
}