import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../services/logger_service.dart';
import '../models/profile_state.dart';
import '../repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(),
);

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>(
  (ref) => ProfileController(
    repository: ref.watch(profileRepositoryProvider),
  ),
);

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController({required ProfileRepository repository})
      : _repository = repository,
        super(const ProfileState());

  final ProfileRepository _repository;

  Future<void> fetchProfile() async {
    state = state.copyWith(isFetching: true, errorMessage: null);
    try {
      final profile = await _repository.fetchProfile();
      state = state.copyWith(
        isFetching: false,
        profile: profile,
        errorMessage: null,
      );
    } catch (e, stackTrace) {
      logger.error(
        'Failed to fetch profile',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isFetching: false,
        errorMessage: 'Failed to fetch profile. Please try again.',
      );
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    required String address,
  }) async {
    state = state.copyWith(isUpdating: true, updateErrorMessage: null);
    try {
      final updated = await _repository.updateProfile(
        name: name,
        email: email,
        address: address,
      );
      state = state.copyWith(
        isUpdating: false,
        profile: updated,
        updateErrorMessage: null,
      );
      return true;
    } catch (e, stackTrace) {
      logger.error(
        'Failed to update profile',
        error: e,
        stackTrace: stackTrace,
      );
      final msg = e.toString().startsWith('Exception: ')
          ? e.toString().substring('Exception: '.length)
          : 'Failed to update profile. Please try again.';
      state = state.copyWith(
        isUpdating: false,
        updateErrorMessage: msg,
      );
      return false;
    }
  }

  Future<bool> updateProfileImage(File image) async {
    state = state.copyWith(isUpdating: true, updateErrorMessage: null);
    try {
      final updated = await _repository.updateProfileImage(image);
      state = state.copyWith(
        isUpdating: false,
        profile: updated,
        updateErrorMessage: null,
      );
      return true;
    } catch (e, stackTrace) {
      logger.error(
        'Failed to update profile image',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isUpdating: false,
        updateErrorMessage: 'Failed to update profile image. Please try again.',
      );
      return false;
    }
  }

  Future<bool> updateMobile(String mobileNo) async {
    try {
      final response = await _repository.updateMobile(mobileNo);
      if (response.success) {
        state = state.copyWith(updateErrorMessage: null);
        return true;
      } else {
        state = state.copyWith(
          updateErrorMessage: response.message,
        );
        return false;
      }
    } catch (e, stackTrace) {
      logger.error(
        'Failed to update mobile number',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<bool> verifyMobileOtp(String otp) async {
    try {
      final response = await _repository.verifyMobileOtp(otp);
      if (response.success) {
        state = state.copyWith(updateErrorMessage: null);
        return true;
      } else {
        state = state.copyWith(
          updateErrorMessage: response.message,
        );
        return false;
      }
    } catch (e, stackTrace) {
      logger.error(
        'Failed to verify mobile OTP',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<bool> updateEmail(String email) async {
    try {
      final response = await _repository.updateEmail(email);
      if (response.success) {
        state = state.copyWith(updateErrorMessage: null);
        return true;
      } else {
        state = state.copyWith(
          updateErrorMessage: response.message,
        );
        return false;
      }
    } catch (e, stackTrace) {
      logger.error(
        'Failed to update email',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<bool> verifyEmailOtp(String otp) async {
    try {
      final response = await _repository.verifyEmailOtp(otp);
      if (response.success) {
        state = state.copyWith(updateErrorMessage: null);
        return true;
      } else {
        state = state.copyWith(
          updateErrorMessage: response.message,
        );
        return false;
      }
    } catch (e, stackTrace) {
      logger.error(
        'Failed to verify email OTP',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
