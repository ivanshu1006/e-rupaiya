import 'profile_model.dart';

class ProfileState {
  const ProfileState({
    this.isFetching = false,
    this.isUpdating = false,
    this.profile,
    this.errorMessage,
    this.updateErrorMessage,
  });

  final bool isFetching;
  final bool isUpdating;
  final ProfileModel? profile;
  final String? errorMessage;
  final String? updateErrorMessage;

  static const _sentinel = Object();

  ProfileState copyWith({
    bool? isFetching,
    bool? isUpdating,
    Object? profile = _sentinel,
    Object? errorMessage = _sentinel,
    Object? updateErrorMessage = _sentinel,
  }) {
    return ProfileState(
      isFetching: isFetching ?? this.isFetching,
      isUpdating: isUpdating ?? this.isUpdating,
      profile:
          profile == _sentinel ? this.profile : profile as ProfileModel?,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      updateErrorMessage: updateErrorMessage == _sentinel
          ? this.updateErrorMessage
          : updateErrorMessage as String?,
    );
  }
}
