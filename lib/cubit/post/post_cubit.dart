import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zerow/data/models/post_model.dart';
import 'package:zerow/data/repository/post_repository.dart';

part 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepository _postRepository;

  PostCubit(this._postRepository) : super(PostInitial());

  Future<void> loadPosts() async {
    try {
      emit(PostLoading());
      final posts = await _postRepository.getPosts();
      emit(PostsLoaded(posts));
    } catch (error) {
      emit(PostError('Failed to load posts: ${error.toString()}'));
    }
  }

  Future<void> loadUserPosts() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(PostError('No authenticated user'));
        return;
      }

      emit(PostLoading());
      final posts = await _postRepository.getUserPosts(currentUser.uid);
      emit(PostsLoaded(posts));
    } catch (error) {
      emit(PostError('Failed to load user posts: ${error.toString()}'));
    }
  }

  Future<void> createPost(PostModel post) async {
    try {
      emit(PostLoading());
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        emit(PostError('No authenticated user'));
        return;
      }

      // Ensure post has user ID
      post = post.copyWith(userId: currentUser.uid);

      await _postRepository.createPost(post);

      // Reload user posts after creating a new post
      await loadUserPosts();

      emit(PostCreated(post));
    } catch (error) {
      emit(PostError('Failed to create post: ${error.toString()}'));
    }
  }

  Future<void> likePost(PostModel post) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(PostError('User must be logged in to like a post'));
        return;
      }

      await _postRepository.likePost(post.id, currentUser.uid);

      // Reload posts to reflect the like
      await loadPosts();
    } catch (error) {
      emit(PostError('Failed to like post: ${error.toString()}'));
    }
  }

  Future<void> unlikePost(PostModel post) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(PostError('User must be logged in to unlike a post'));
        return;
      }

      await _postRepository.unlikePost(post.id, currentUser.uid);

      // Reload posts to reflect the unlike
      await loadPosts();
    } catch (error) {
      emit(PostError('Failed to unlike post: ${error.toString()}'));
    }
  }

  Future<bool> isPostLikedByCurrentUser(PostModel post) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return false;
      }

      return await _postRepository.isPostLikedByUser(post.id, currentUser.uid);
    } catch (error) {
      return false;
    }
  }
}
