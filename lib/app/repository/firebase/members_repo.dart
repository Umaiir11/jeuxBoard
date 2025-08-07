import 'package:cloud_firestore/cloud_firestore.dart';

import '../../mvvm/model/firebase_models/user_model.dart';

class MembersRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<UserModel>> getUsers() {
    return _firestore.collection('users').snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => UserModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList(),
    );
  }

  Future<void> updateUserRole(String userId, String role) async {
    try {
      await _firestore.collection('users').doc(userId).update({'role': role});
    } catch (e) {
      throw Exception('Failed to update role: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}