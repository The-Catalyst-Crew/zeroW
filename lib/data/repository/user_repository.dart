import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zerow/data/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference _usersRef =
      FirebaseFirestore.instance.collection('users');

  Future<void> createUser(User? user) async {
    try {
      if (user != null) {
        UserModel createdUser = UserModel(
          id: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          avatarUrl: user.photoURL ?? '',
        );
        await _usersRef.doc(createdUser.id).set(createdUser.toMap());
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<UserModel?> getFirestoreUser(String uid) async {
    try {
      DocumentSnapshot doc = await _usersRef.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _usersRef.doc(user.id).update(user.toMap());
    } catch (error) {
      rethrow;
    }
  }
}
