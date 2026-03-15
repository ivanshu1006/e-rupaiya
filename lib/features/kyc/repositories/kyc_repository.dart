import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../constants/api_constants.dart';
import '../../../services/dio_service.dart';
import '../../../services/logger_service.dart';

class KycRepository {
  KycRepository({Dio? dio}) : _dio = dio ?? DioService.instance.client;

  final Dio _dio;

  Future<KycPanResponse> verifyPan({
    required String panNumber,
    required String deviceId,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.kycPanVerifyEndpoint,
        data: {
          'pan_number': panNumber,
          'device_id': deviceId,
        },
      );
      final payload = _asMap(response.data);
      return KycPanResponse.fromJson(payload);
    } catch (e, stackTrace) {
      logger.error(
        'Failed to verify PAN',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<KycAadhaarOtpResponse> sendAadhaarOtp({
    required String userId,
    required String aadhaar,
    required String deviceId,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.kycAadhaarSendOtpEndpoint,
        data: {
          'user_id': userId,
          'aadhaar': aadhaar,
          'device_id': deviceId,
        },
      );
      final payload = _asMap(response.data);
      return KycAadhaarOtpResponse.fromJson(payload);
    } catch (e, stackTrace) {
      logger.error(
        'Failed to send Aadhaar OTP',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<KycVerifyOtpResponse> verifyAadhaarOtp({
    required String userId,
    required String referenceId,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.kycAadhaarVerifyOtpEndpoint,
        data: {
          'user_id': userId,
          'reference_id': referenceId,
          'otp': otp,
        },
      );
      final payload = _asMap(response.data);
      return KycVerifyOtpResponse.fromJson(payload);
    } catch (e, stackTrace) {
      logger.error(
        'Failed to verify Aadhaar OTP',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

class KycPanResponse {
  const KycPanResponse({
    required this.valid,
    required this.message,
  });

  factory KycPanResponse.fromJson(Map<String, dynamic> json) {
    return KycPanResponse(
      valid: json['valid'] == true,
      message: (json['message'] ?? '').toString(),
    );
  }

  final bool valid;
  final String message;
}

class KycAadhaarOtpResponse {
  const KycAadhaarOtpResponse({
    required this.success,
    required this.message,
    required this.referenceId,
    required this.maskedAadhaar,
  });

  factory KycAadhaarOtpResponse.fromJson(Map<String, dynamic> json) {
    final ref = json['reference_id'] ??
        (json['data'] is Map<String, dynamic>
            ? (json['data'] as Map<String, dynamic>)['reference_id']
            : null);
    final status = json['status'];
    final valid = json['valid'] == true;
    final success = valid ||
        status == true ||
        status?.toString().toUpperCase() == 'SUCCESS';
    final aadhaar = json['aadhaar_number'] ??
        (json['data'] is Map<String, dynamic>
            ? (json['data'] as Map<String, dynamic>)['aadhaar_number']
            : null);
    return KycAadhaarOtpResponse(
      success: success,
      message: (json['message'] ?? '').toString(),
      referenceId: (ref ?? '').toString(),
      maskedAadhaar: (aadhaar ?? '').toString(),
    );
  }

  final bool success;
  final String message;
  final String referenceId;
  final String maskedAadhaar;
}

class KycVerifyOtpResponse {
  const KycVerifyOtpResponse({
    required this.success,
    required this.message,
  });

  factory KycVerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    final status = json['status'];
    final success = status == true ||
        status?.toString().toUpperCase() == 'SUCCESS';
    return KycVerifyOtpResponse(
      success: success,
      message: (json['message'] ?? '').toString(),
    );
  }

  final bool success;
  final String message;
}

Map<String, dynamic> _asMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is String && data.isNotEmpty) {
    final decoded = jsonDecode(data);
    if (decoded is Map<String, dynamic>) return decoded;
  }
  return <String, dynamic>{};
}
