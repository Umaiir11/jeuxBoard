import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../model/firebase_models/project_model.dart';

class DashboardController extends GetxController {
  final RxList<ProjectModel> projects = <ProjectModel>[].obs;
  final RxString filterStatus = ''.obs;
  final RxString filterSprint = ''.obs;
  final RxString filterDev = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProjects();
  }

  void fetchProjects() {
    FirebaseFirestore.instance.collection('projects').snapshots().listen((snapshot) {
      projects.value = snapshot.docs
          .map((doc) => ProjectModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    });
  }

  void applyFilters(String? status, String? sprint, String? dev) {
    filterStatus.value = status ?? '';
    filterSprint.value = sprint ?? '';
    filterDev.value = dev ?? '';
  }
}