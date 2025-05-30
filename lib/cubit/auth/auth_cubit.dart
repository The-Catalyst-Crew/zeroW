import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:zerow/data/models/user_model.dart';
import 'package:zerow/data/repository/auth_repository.dart';
import 'package:zerow/data/repository/user_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  AuthCubit(this._authRepository, this._userRepository) : super(AuthInitial());

  Future<void> checkUser() async {
    try {
      emit(AuthLoading());
      final User? user = _authRepository.currentUser;
      if (user != null) {
        final UserModel? firestoreUser =
            await _userRepository.getFirestoreUser(user.uid);
        emit(Authenticated(firestoreUser));
      } else {
        emit(Unauthenticated());
      }
    } catch (error) {
      emit(AuthError(error.toString())); // Handle errors
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      emit(AuthLoading());
      final User? user = await _authRepository.signInWithEmail(email, password);
      final UserModel? firestoreUser =
          await _userRepository.getFirestoreUser(user!.uid);
      emit(Authenticated(firestoreUser));
    } catch (e) {
      emit(AuthError("Login failed: ${e.toString()}"));
    }
  }

  Future<void> signUpWithEmail(
      String name, String email, String password) async {
    try {
      emit(AuthLoading());
      final User? user = await _authRepository.signUpWithEmail(email, password);
      user!.updateDisplayName(name);
      await _userRepository.createUser(user);
      emit(ApprovalRequestSent());
    } catch (e) {
      emit(AuthError("Signup failed: ${e.toString()}"));
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      emit(AuthLoading());
      final User? user = await _authRepository.signInWithGoogle();
      UserModel? firestoreUser =
          await _userRepository.getFirestoreUser(user!.uid);
      if (firestoreUser == null) {
        await _userRepository.createUser(user);
        firestoreUser = await _userRepository.getFirestoreUser(user.uid);
      }
      emit(Authenticated(firestoreUser));
    } catch (e) {
      emit(AuthError("Google sign-in failed: ${e.toString()}"));
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    emit(Unauthenticated());
  }
}
