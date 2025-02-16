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
}
