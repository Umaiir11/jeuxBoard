import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../repository/firebase/project_repo.dart';
import '../model/firebase_models/project_model.dart';
import '../model/firebase_models/project_module_model.dart';
import '../model/firebase_models/user_model.dart';


class ProjectController extends GetxController {
  final ProjectRepository _projectRepository = GetIt.I<ProjectRepository>();
  final RxList<ProjectModel> projects = <ProjectModel>[].obs;
  final RxList<ProjectModuleModel> modules = <ProjectModuleModel>[].obs;
  final RxList<UserModel> devs = <UserModel>[].obs;
  final RxString filterStatus = ''.obs;
  final RxString filterSprint = ''.obs;
  final RxString filterDev = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProjects();
    fetchDevs();
  }

  void fetchProjects() {
    _projectRepository.getProjects().listen((projectList) {
      projects.value = projectList;
    });
  }

  void fetchModules(String projectId) {
    _projectRepository.getModules(projectId).listen((moduleList) {
      modules.value = moduleList;
    });
  }

  void fetchDevs() {
    _projectRepository.getDevs().listen((devList) {
      devs.value = devList;
    });
  }

  void applyFilters(String? status, String? sprint, String? dev) {
    filterStatus.value = status ?? '';
    filterSprint.value = sprint ?? '';
    filterDev.value = dev ?? '';
  }

  Future<void> createOrUpdateProject(ProjectModel project, List<String> assignedDevs) async {
    isLoading.value = true;
    try {
      await _projectRepository.createOrUpdateProject(project, assignedDevs);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save project: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateModule(ProjectModuleModel module) async {
    isLoading.value = true;
    try {
      await _projectRepository.updateModule(module);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update module: $e');
    } finally {
      isLoading.value = false;
    }
  }
}