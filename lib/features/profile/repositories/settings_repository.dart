import 'package:dio/dio.dart';

import '../../../constants/api_constants.dart';
import '../../../services/dio_service.dart';
import '../../../services/logger_service.dart';

class SettingsRepository {
  SettingsRepository({Dio? dio}) : _dio = dio ?? DioService.instance.client;

  final Dio _dio;

  Future<SettingsActionResult> setPushNotificationsEnabled(
    bool isEnabled,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.pushNotificationToggleEndpoint,
        data: {'is_push_notification': isEnabled ? 1 : 0},
      );
      final payload = response.data as Map<String, dynamic>? ?? {};
      final rawStatus = payload['status'];
      final success = rawStatus is bool
          ? rawStatus
          : rawStatus?.toString().toLowerCase() == 'true';
      final message = payload['message']?.toString() ?? '';
      return SettingsActionResult(
        success: success,
        message: message,
      );
    } catch (e, stackTrace) {
      logger.error(
        'Failed to update push notification preference',
        error: e,
        stackTrace: stackTrace,
      );
      return const SettingsActionResult(
        success: false,
        message: 'Unable to update notifications. Please try again.',
      );
    }
  }

  Future<SettingsActionResult> sendDeleteAccountOtp() async {
    try {
      final response =
          await _dio.post(ApiConstants.sendDeleteAccountOtpEndpoint);
      final payload = response.data as Map<String, dynamic>? ?? {};
      final rawStatus = payload['status'];
      final success = rawStatus is bool
          ? rawStatus
          : rawStatus?.toString().toLowerCase() == 'true';
      final message = payload['message']?.toString() ?? '';
      return SettingsActionResult(success: success, message: message);
    } catch (e, stackTrace) {
      logger.error(
        'Failed to send delete account OTP',
        error: e,
        stackTrace: stackTrace,
      );
      return const SettingsActionResult(
        success: false,
        message: 'Unable to send OTP. Please try again.',
      );
    }
  }

  Future<SettingsActionResult> verifyDeleteAccountOtp(String otp) async {
    try {
      final response = await _dio.post(
        ApiConstants.verifyDeleteAccountOtpEndpoint,
        data: {'otp': otp},
      );
      final payload = response.data as Map<String, dynamic>? ?? {};
      final rawStatus = payload['status'];
      final success = rawStatus is bool
          ? rawStatus
          : rawStatus?.toString().toLowerCase() == 'true';
      final message = payload['message']?.toString() ?? '';
      return SettingsActionResult(success: success, message: message);
    } catch (e, stackTrace) {
      logger.error(
        'Failed to verify delete account OTP',
        error: e,
        stackTrace: stackTrace,
      );
      return const SettingsActionResult(
        success: false,
        message: 'Unable to verify OTP. Please try again.',
      );
    }
  }
}

class SettingsActionResult {
  const SettingsActionResult({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;
}
