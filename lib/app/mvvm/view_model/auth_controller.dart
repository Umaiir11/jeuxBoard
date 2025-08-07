import 'package:get/get.dart';
import 'package:get_it/get_it.dart';


import '../../repository/firebase/auth_repo.dart';
import '../model/firebase_models/user_model.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = GetIt.I<AuthRepository>();
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  Future<void> loadUser() async {
    final loadedUser = await _authRepository.getCurrentUser();
    user.value = loadedUser;
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    isLoading.value = true;
    try {
      final newUser = await _authRepository.signUp(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      user.value = newUser;
      Get.offAllNamed('/dashboard');
    } catch (e) {
      Get.snackbar('Error', 'Signup failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      final loggedUser = await _authRepository.login(email, password);
      user.value = loggedUser;
      Get.offAllNamed('/dashboard');
    } catch (e) {
      Get.snackbar('Error', 'Login failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    user.value = null;
    Get.offAllNamed('/login');
  }
}