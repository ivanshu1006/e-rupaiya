import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_rupaiya/features/profile/models/api_response_model.dart';

import '../../../constants/api_constants.dart';
import '../../../services/dio_service.dart';
import '../../../services/logger_service.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  ProfileRepository({Dio? dio}) : _dio = dio ?? DioService.instance.client;

  final Dio _dio;

  Future<ProfileModel> fetchProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profileEndpoint);
      final payload = response.data as Map<String, dynamic>?;
      final success = payload?['success'] == true;
      if (!success) {
        final message =
            payload?['message'] as String? ?? 'Failed to fetch profile';
        throw Exception(message);
      }
      final data = payload?['data'] as Map<String, dynamic>? ?? {};
      return ProfileModel.fromJson(data);
    } catch (e) {
      logger.error('Failed to fetch profile: $e', error: e);
      rethrow;
    }
  }

  Future<ProfileModel> updateProfile({
    required String name,
    required String email,
    required String address,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.profileUpdateEndpoint,
        data: FormData.fromMap({
          'name': name,
          'email': email,
          'address': address,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );
      final payload = response.data as Map<String, dynamic>?;
      final success = payload?['success'] == true ||
          (payload?['status']?.toString().toUpperCase() == 'SUCCESS');
      if (!success) {
        final message =
            payload?['message'] as String? ?? 'Failed to update profile';
        throw Exception(message);
      }
      final data = payload?['data'] as Map<String, dynamic>? ??
          payload?['payload'] as Map<String, dynamic>? ??
          {};
      return ProfileModel.fromJson(data);
    } catch (e) {
      if (e is DioException) {
        final data = e.response?.data;
        final message = (data is Map ? data['message'] as String? : null) ??
            'Failed to update profile';
        logger.error('Failed to update profile: $message', error: e);
        throw Exception(message);
      }
      logger.error('Failed to update profile: $e', error: e);
      rethrow;
    }
  }

  Future<ProfileModel> updateProfileImage(File image) async {
    try {
      final formData = FormData.fromMap({
        'profile_photo': await MultipartFile.fromFile(image.path),
      });
      final response = await _dio.post(
        ApiConstants.profileUpdateEndpoint,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final payload = response.data as Map<String, dynamic>?;
      final success = payload?['success'] == true ||
          (payload?['status']?.toString().toUpperCase() == 'SUCCESS');
      if (!success) {
        final message =
            payload?['message'] as String? ?? 'Failed to update profile image';
        throw Exception(message);
      }
      final data = payload?['data'] as Map<String, dynamic>? ??
          payload?['payload'] as Map<String, dynamic>? ??
          {};
      return ProfileModel.fromJson(data);
    } catch (e) {
      logger.error('Failed to update profile image: $e', error: e);
      rethrow;
    }
  }

  Future<ApiResponse> updateMobile(String mobileNo) async {
    final response = await _dio.post(
        '${ApiConstants.baseUrl}/api/user/profile/request-contact-update',
        data: {
          'type': 'mobile',
          'value': mobileNo,
        });

    return ApiResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ApiResponse> verifyMobileOtp(String otp) async {
    final response = await _dio.post(
      ApiConstants.profileVerifyContactUpdateEndpoint,
      data: {
        'type': 'mobile',
        'otp': otp,
      },
    );

    return ApiResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ApiResponse> updateEmail(String email) async {
    final response = await _dio.post(
      '${ApiConstants.baseUrl}/api/user/profile/request-contact-update',
      data: {
        'type': 'email',
        'value': email,
      },
    );

    return ApiResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ApiResponse> verifyEmailOtp(String otp) async {
    final response = await _dio.post(
      ApiConstants.profileVerifyContactUpdateEndpoint,
      data: {
        'type': 'email',
        'otp': otp,
      },
    );

    return ApiResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ApiResponse> updateDeviceToken(String token) async {
    final response = await _dio.post(
      ApiConstants.profileUpdateDeviceTokenEndpoint,
      data: {
        'device_token': token,
      },
    );

    return ApiResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
