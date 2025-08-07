import 'package:get/get.dart';
import 'package:get_it/get_it.dart';


import '../../repository/firebase/members_repo.dart';
import '../model/firebase_models/user_model.dart';

class MembersController extends GetxController {
  final MembersRepository _membersRepository = GetIt.I<MembersRepository>();
  final RxList<UserModel> users = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  void fetchUsers() {
    _membersRepository.getUsers().listen((userList) {
      users.value = userList;
    });
  }

  Future<void> updateUserRole(String userId, String role) async {
    try {
      await _membersRepository.updateUserRole(userId, role);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update role: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _membersRepository.deleteUser(userId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete user: $e');
    }
  }
}