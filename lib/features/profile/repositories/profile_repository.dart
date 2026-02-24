import 'package:dio/dio.dart';

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
      final response = await _dio.put(
        ApiConstants.profileUpdateEndpoint,
        data: {
          'name': name,
          'email': email,
          'address': address,
        },
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
      logger.error('Failed to update profile: $e', error: e);
      rethrow;
    }
  }
}
