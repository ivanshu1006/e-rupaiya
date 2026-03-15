import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../utils/utils.dart';
import '../models/auth_flow.dart';
import '../models/auth_state.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(
    repository: ref.watch(authRepositoryProvider),
  ),
);

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required AuthRepository repository,
    bool shouldCheckInitialAuth = true,
  })  : _repository = repository,
        super(AuthState.initial()) {
    if (shouldCheckInitialAuth) {
      _checkInitialAuth();
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  final AuthRepository _repository;

  String _messageFromException(Object error, String fallback) {
    final raw = error.toString();
    if (raw.startsWith('Exception: ')) {
      return raw.replaceFirst('Exception: ', '');
    }
    return fallback;
  }

  Future<void> _checkInitialAuth() async {
    final isAuthenticated = await Utils.checkAuthentication();
    if (isAuthenticated) {
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        isSubmitting: false,
        errorMessage: null,
      );
      return;
    }

    final refreshed = await _repository.refreshSession();
    state = state.copyWith(
      isAuthenticated: refreshed,
      isLoading: false,
      isSubmitting: false,
      errorMessage: null,
    );
  }

  Future<AuthFlow?> checkLogin({
    required String mobile,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final flow = await _repository.checkLogin(
        mobile: mobile,
      );
      state = state.copyWith(
        isSubmitting: false,
        pendingMobile: mobile,
        errorMessage: null,
      );
      return flow;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _messageFromException(
          e,
          'Failed to continue. Please try again.',
        ),
      );
      return null;
    }
  }

  Future<bool> login({
    required String mobile,
    required String pin,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await _repository.login(mobile: mobile, pin: pin);
      state = state.copyWith(
        isAuthenticated: true,
        isSubmitting: false,
        pendingMobile: null,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _messageFromException(
          e,
          'Login failed. Please try again.',
        ),
      );
      return false;
    }
  }

  Future<bool> pinLock({
    required String mobile,
    required String pin,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await _repository.pinLock(mobile: mobile, pin: pin);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _messageFromException(
          e,
          'PIN validation failed. Please try again.',
        ),
      );
      return false;
    }
  }

  Future<bool> verifyOtp({
    required String otp,
    String? userId,
  }) async {
    final storedUserId = await _repository.secureStorage.read(key: 'userId');
    final resolvedUserId = storedUserId ?? '';
    if (resolvedUserId.isEmpty) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Missing user ID. Please try again.',
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await _repository.verifyOtp(
        userId: resolvedUserId,
        otp: otp,
      );
      state = state.copyWith(
        isSubmitting: false,
        pendingMobile: resolvedUserId,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _messageFromException(
          e,
          'OTP verification failed. Please try again.',
        ),
      );
      return false;
    }
  }

  Future<String?> setPin({
    required String pin,
    String? userId,
  }) async {
    final storedUserId = await _repository.secureStorage.read(key: 'userId');
    final resolvedUserId = userId ?? storedUserId ?? state.pendingMobile;
    if (resolvedUserId == null || resolvedUserId.isEmpty) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Missing user ID. Please try again.',
      );
      return null;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final message = await _repository.setPin(
        userId: resolvedUserId,
        pin: pin,
      );
      state = state.copyWith(
        isSubmitting: false,
        pendingMobile: null,
        errorMessage: null,
      );
      return message;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _messageFromException(
          e,
          'Failed to set PIN. Please try again.',
        ),
      );
      return null;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = state.copyWith(
      isAuthenticated: false,
      pendingMobile: null,
      errorMessage: null,
    );
  }

  Future<String?> requestForgotPinOtp({
    String? userId,
  }) async {
    final storedUserId = await _repository.secureStorage.read(key: 'userId');
    final resolvedUserId = userId ?? storedUserId;
    if (resolvedUserId == null || resolvedUserId.isEmpty) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Missing user ID. Please try again.',
      );
      return null;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final message = await _repository.requestForgotPinOtp(
        userId: resolvedUserId,
      );
      state = state.copyWith(isSubmitting: false, errorMessage: null);
      return message;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _messageFromException(
          e,
          'Failed to request OTP. Please try again.',
        ),
      );
      return null;
    }
  }

  Future<String?> forgotPin({
    required String otp,
    required String pin,
    String? userId,
  }) async {
    final storedUserId = await _repository.secureStorage.read(key: 'userId');
    final resolvedUserId = userId ?? storedUserId;
    if (resolvedUserId == null || resolvedUserId.isEmpty) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Missing user ID. Please try again.',
      );
      return null;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final message = await _repository.forgotPin(
        userId: resolvedUserId,
        otp: otp,
        pin: pin,
      );
      state = state.copyWith(isSubmitting: false, errorMessage: null);
      return message;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _messageFromException(
          e,
          'Failed to reset PIN. Please try again.',
        ),
      );
      return null;
    }
  }
}
