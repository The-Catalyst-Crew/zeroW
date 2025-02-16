part of 'post_cubit.dart';

abstract class PostState {
  const PostState();
}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostsLoaded extends PostState {
  final List<PostModel> posts;

  PostsLoaded(this.posts);
}

class PostError extends PostState {
  final String message;

  PostError(this.message);
}

class PostCreated extends PostState {
  final PostModel post;

  const PostCreated(this.post);
}
