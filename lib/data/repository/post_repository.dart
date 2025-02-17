import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zerow/data/models/post_model.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<PostModel>> getPosts({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => PostModel.fromFirestore(doc))
          .toList();
    } catch (error) {
      rethrow;
    }
  }

  Future<List<PostModel>> getUserPosts(String userId, {int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => PostModel.fromFirestore(doc))
          .toList();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> createPost(PostModel post) async {
    try {
      await _firestore.collection('posts').add(post.toMap());
    } catch (error) {
      rethrow;
    }
  }

  Future<void> likePost(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      await postRef.update({
        'likes': FieldValue.arrayUnion([userId])
      });
    } catch (error) {
      rethrow;
    }
  }

  Future<void> unlikePost(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      await postRef.update({
        'likes': FieldValue.arrayRemove([userId])
      });
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> isPostLikedByUser(String postId, String userId) async {
    try {
      final postDoc = await _firestore.collection('posts').doc(postId).get();
      final postData = postDoc.data();
      return postData?['likes']?.contains(userId) ?? false;
    } catch (error) {
      rethrow;
    }
  }
}
