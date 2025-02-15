part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}
class ApprovalRequestSent extends AuthState {}

class ApprovalPending extends AuthState {}

class Authenticated extends AuthState {
  final UserModel? user;

  Authenticated(this.user);
}

class UnknownDevice extends AuthState {}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}
