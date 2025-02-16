import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final int points;
  final int rank;
  final String level;
  final bool anonymousPosting;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.points = 0,
    this.rank = 0,
    this.level = 'Beginner',
    this.anonymousPosting = false,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      points: data['points'] ?? 0,
      rank: data['rank'] ?? 0,
      level: _determineLevel(data['points'] ?? 0),
      anonymousPosting: data['anonymousPosting'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'points': points,
      'rank': rank,
      'level': level,
      'anonymousPosting': anonymousPosting,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    int? points,
    int? rank,
    String? level,
    bool? anonymousPosting,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      points: points ?? this.points,
      rank: rank ?? this.rank,
      level: level ?? this.level,
      anonymousPosting: anonymousPosting ?? this.anonymousPosting,
    );
  }

  // Static method to determine level based on points
  static String _determineLevel(int points) {
    if (points < 50) return 'Beginner';
    if (points < 100) return 'Eco Warrior';
    if (points < 150) return 'Clean-up Champion';
    if (points < 200) return 'Environmental Hero';
    return 'Sustainability Legend';
  }
}
