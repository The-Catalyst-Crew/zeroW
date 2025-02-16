part of 'user_cubit.dart';

@immutable
abstract class UserState {}

class UserInitial extends UserState {}

class UserLoaded extends UserState {
  final UserModel userModel;

  UserLoaded(this.userModel);
}

class UserError extends UserState {
  final String message;

  UserError(this.message);
}
