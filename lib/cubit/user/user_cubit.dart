import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:zerow/data/models/user_model.dart';
import 'package:zerow/data/repository/user_repository.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository _userRepository;

  UserCubit(this._userRepository) : super(UserInitial());

  Future<void> loadUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userModel =
            await _userRepository.getFirestoreUser(currentUser.uid);
        if (userModel != null) {
          emit(UserLoaded(userModel));
        } else {
          emit(UserError('User data not found'));
        }
      } else {
        emit(UserError('No authenticated user'));
      }
    } catch (error) {
      emit(UserError('Failed to load user data: ${error.toString()}'));
    }
  }

  Future<void> toggleAnonymousPosting() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(UserError('No authenticated user'));
        return;
      }

      final userModel = await _userRepository.getFirestoreUser(currentUser.uid);
      if (userModel == null) {
        emit(UserError('User data not found'));
        return;
      }

      // Toggle the anonymous posting preference
      final updatedUser = userModel.copyWith(
        anonymousPosting: !userModel.anonymousPosting,
      );

      // Update in Firestore
      await _userRepository.updateUser(updatedUser);

      // Reload and emit updated user data
      emit(UserLoaded(updatedUser));
    } catch (error) {
      emit(
          UserError('Failed to toggle anonymous posting: ${error.toString()}'));
    }
  }
}
