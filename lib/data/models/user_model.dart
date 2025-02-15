import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;

  final String avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
    };
  }
}
