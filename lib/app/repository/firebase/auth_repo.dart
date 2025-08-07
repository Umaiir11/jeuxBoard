import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../mvvm/model/firebase_models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        role: role,
      );
      await _firestore.collection('users').doc(user.id).set(user.toJson());
      return user;
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final doc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (doc.exists) {
        return UserModel.fromJson({'id': userCredential.user!.uid, ...doc.data()!});
      }
      return null;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromJson({'id': user.uid, ...doc.data()!});
      }
    }
    return null;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}