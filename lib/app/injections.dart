import 'package:get_it/get_it.dart';
import 'package:untitled/app/repository/firebase/auth_repo.dart';
import 'package:untitled/app/repository/firebase/members_repo.dart';
import 'package:untitled/app/repository/firebase/project_repo.dart';

import 'mvvm/view_model/auth_controller.dart';
import 'mvvm/view_model/members_controller.dart';
import 'mvvm/view_model/project_controller.dart';
import 'mvvm/view_model/project_managemnt_controller.dart';

final GetIt getIt = GetIt.instance;

void configureDependencies() {
  // Repositories
  getIt.registerSingleton<AuthRepository>(AuthRepository());
  getIt.registerSingleton<ProjectRepository>(ProjectRepository());
  getIt.registerSingleton<MembersRepository>(MembersRepository());

  // Controllers
  getIt.registerSingleton<AuthController>(AuthController());
  getIt.registerSingleton<ProjectController>(ProjectController());
  getIt.registerSingleton<MembersController>(MembersController());
}
