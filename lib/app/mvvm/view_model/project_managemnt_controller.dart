import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';


import '../model/firebase_models/project_model.dart';
import '../model/firebase_models/project_module_model.dart';
import '../model/firebase_models/user_model.dart';

  final RxList<ProjectModuleModel> modules = <ProjectModuleModel>[].obs;
  final RxList<UserModel> devs = <UserModel>[].obs;

  void fetchModules(String projectId) {
    FirebaseFirestore.instance
        .collection('project_modules')
        .where('project_id', isEqualTo: projectId)
        .snapshots()
        .listen((snapshot) {
      modules.value = snapshot.docs
          .map((doc) => ProjectModuleModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    });
  }

  void fetchDevs() {
    FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'dev')
        .snapshots()
        .listen((snapshot) {
      devs.value = snapshot.docs
          .map((doc) => UserModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    });
  }

  Future<void> createOrUpdateProject(ProjectModel project, List<String> assignedDevs) async {
    try {
      await FirebaseFirestore.instance.collection('projects').doc(project.id).set(project.toJson());
      for (var devId in assignedDevs) {
        await FirebaseFirestore.instance.collection('project_members').add({
          'project_id': project.id,
          'user_id': devId,
          'role_in_project': 'dev',
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save project: $e');
    }
  }

  Future<void> updateModule(ProjectModuleModel module) async {
    try {
      await FirebaseFirestore.instance
          .collection('project_modules')
          .doc(module.id)
          .update(module.toJson());
    } catch (e) {
      Get.snackbar('Error', 'Failed to update module: $e');
    }
  }
