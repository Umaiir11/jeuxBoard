import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/config/app_colors.dart';
import 'app/injections.dart';
import 'app/mvvm/view/calender_view.dart';
import 'app/mvvm/view/dashboard_view.dart';
import 'app/mvvm/view/login_view.dart';
import 'app/mvvm/view/members_view.dart';
import 'app/mvvm/view/project_details_view.dart';
import 'app/mvvm/view/project_form_view.dart';
import 'app/mvvm/view/signup_view.dart';
import 'app/mvvm/view_model/auth_controller.dart';
import 'app/mvvm/view_model/members_controller.dart';
import 'app/mvvm/view_model/project_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  configureDependencies();
  runApp(const JeuxBoardApp());
}

class JeuxBoardApp extends StatelessWidget {
  const JeuxBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          title: 'JeuxBoard',
          theme: ThemeData(
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.background,
            textTheme: GoogleFonts.interTextTheme().apply(
              bodyColor: AppColors.text,
              displayColor: AppColors.text,
            ),
            useMaterial3: true,
          ),
          initialRoute: '/login',
            getPages: [
              GetPage(
                name: '/login',
                page: () => const LoginScreen(),
                binding: AuthBinding(),
              ),
              GetPage(
                name: '/signup',
                page: () => const SignUpScreen(),
                binding: AuthBinding(),
              ),
              GetPage(
                name: '/dashboard',
                page: () => const DashboardScreen(),
                binding: ProjectBinding(),
                middlewares: [AuthMiddleware()],
              ),
              GetPage(
                name: '/project_form',
                page: () => const ProjectFormScreen(),
                binding: ProjectBinding(),
                middlewares: [AuthMiddleware(allowedRoles: ['admin'])],
              ),
              GetPage(
                name: '/project_detail',
                page: () => const ProjectDetailScreen(),
                binding: ProjectBinding(),
                middlewares: [AuthMiddleware()],
              ),
              GetPage(
                name: '/members',
                page: () => const MembersScreen(),
                binding: MembersBinding(),
                middlewares: [AuthMiddleware(allowedRoles: ['admin'])],
              ),
              GetPage(
                name: '/calendar',
                page: () => const CalendarScreen(),
                binding: ProjectBinding(), // Change if calendar has a separate controller
                middlewares: [AuthMiddleware()],
              ),
            ]

        );
      },
    );
  }
}

class AuthMiddleware extends GetMiddleware {
  final List<String>? allowedRoles;

  AuthMiddleware({this.allowedRoles});

  @override
  RouteSettings? redirect(String? route) {
    final authController = GetIt.I<AuthController>();
    if (authController.user.value == null) {
      return const RouteSettings(name: '/login');
    }
    if (allowedRoles != null && !allowedRoles!.contains(authController.user.value!.role)) {
      return const RouteSettings(name: '/dashboard');
    }
    return null;
  }
}

// auth_binding.dart
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(GetIt.I<AuthController>(), permanent: true);
  }
}

// project_binding.dart
class ProjectBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ProjectController>(GetIt.I<ProjectController>(), permanent: true);
  }
}

// members_binding.dart
class MembersBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MembersController>(GetIt.I<MembersController>(), permanent: true);
  }
}
