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
  }) async {
    state = state.copyWith(isUpdating: true, updateErrorMessage: null);
    try {
      final updated = await _repository.updateProfile(
        name: name,
        email: email,
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
      state = state.copyWith(
        isUpdating: false,
        updateErrorMessage: 'Failed to update profile. Please try again.',
      );
      return false;
    }
  }
}
