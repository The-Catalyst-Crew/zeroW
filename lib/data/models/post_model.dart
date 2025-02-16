import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String title;
  final String context;
  final String imageUrl;
  final GeoPoint? location;
  final Timestamp createdAt;
  final String status;
  final List<String> likes;
  final String username;

  PostModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.context,
    required this.imageUrl,
    this.location,
    required this.createdAt,
    this.status = 'pending',
    this.likes = const [],
    this.username = 'Anonymous',
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      context: data['context'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      location: data['location'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      status: data['status'] ?? 'pending',
      likes: List<String>.from(data['likes'] ?? []),
      username: data['username'] ?? 'Anonymous',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'context': context,
      'imageUrl': imageUrl,
      'location': location,
      'createdAt': createdAt,
      'status': status,
      'likes': likes,
      'username': username,
    };
  }

  PostModel copyWith({
    String? id,
    String? title,
    String? context,
    String? imageUrl,
    String? userId,
    GeoPoint? location,
    Timestamp? createdAt,
    List<String>? likes,
    String? username,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      context: context ?? this.context,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      status: this.status,
      likes: likes ?? this.likes,
      username: username ?? this.username,
    );
  }
}
