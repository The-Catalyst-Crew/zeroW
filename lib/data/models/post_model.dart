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

  PostModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.context,
    required this.imageUrl,
    this.location,
    required this.createdAt,
    this.status = 'pending',
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
    };
  }
}
