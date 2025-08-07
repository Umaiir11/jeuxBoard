import 'package:cloud_firestore/cloud_firestore.dart';
import '../../mvvm/model/firebase_models/project_model.dart';
import '../../mvvm/model/firebase_models/project_module_model.dart';
import '../../mvvm/model/firebase_models/user_model.dart';

class ProjectRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ProjectModel>> getProjects() {
    return _firestore.collection('projects').snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => ProjectModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList(),
    );
  }

  Stream<List<ProjectModuleModel>> getModules(String projectId) {
    return _firestore
        .collection('project_modules')
        .where('project_id', isEqualTo: projectId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => ProjectModuleModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList(),
    );
  }

  Stream<List<UserModel>> getDevs() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'dev')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => UserModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList(),
    );
  }

  Future<void> createOrUpdateProject(ProjectModel project, List<String> assignedDevs) async {
    try {
      await _firestore.collection('projects').doc(project.id).set(project.toJson());
      for (var devId in assignedDevs) {
        await _firestore.collection('project_members').add({
          'project_id': project.id,
          'user_id': devId,
          'role_in_project': 'dev',
        });
      }
    } catch (e) {
      throw Exception('Failed to save project: $e');
    }
  }

  Future<void> updateModule(ProjectModuleModel module) async {
    try {
      await _firestore.collection('project_modules').doc(module.id).update(module.toJson());
    } catch (e) {
      throw Exception('Failed to update module: $e');
    }
  }
}