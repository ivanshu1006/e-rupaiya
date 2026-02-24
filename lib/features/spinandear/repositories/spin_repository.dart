import 'package:dio/dio.dart';

import '../../../constants/api_constants.dart';
import '../../../services/dio_service.dart';
import '../../../services/logger_service.dart';

class SpinRepository {
  SpinRepository({Dio? dio}) : _dio = dio ?? DioService.instance.client;

  final Dio _dio;
  String? _cachedUserId;

  Future<String> _getUserId() async {
    if (_cachedUserId != null) return _cachedUserId!;

    final response = await _dio.get(ApiConstants.profileEndpoint);
    final payload = response.data as Map<String, dynamic>?;
    final data = payload?['data'] as Map<String, dynamic>? ?? {};
    final id = data['id']?.toString();
    if (id == null || id.isEmpty) {
      throw Exception('User ID not found in profile');
    }
    _cachedUserId = id;
    return id;
  }

  /// Returns a map of category → list of coin values.
  /// e.g. {"Normal": [2,4,6,8], "Jackpot Spin": [25,50,75,100]}
  Future<Map<String, List<int>>> fetchSpinOptions() async {
    try {
      final response = await _dio.get(ApiConstants.spinOptionsEndpoint);
      final payload = response.data as Map<String, dynamic>? ?? {};
      final data = payload['data'] as Map<String, dynamic>? ?? {};
      return data.map((key, value) {
        final list = (value as List?)
                ?.map((e) => (e as num).toInt())
                .toList() ??
            [];
        return MapEntry(key, list);
      });
    } catch (e, stackTrace) {
      logger.error(
        'Failed to fetch spin options',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> recordSpin({
    required String spinType,
    required int rewardValue,
  }) async {
    try {
      final userId = await _getUserId();

      await _dio.post(
        ApiConstants.spinEndpoint,
        data: {
          'user_id': userId,
          'spin_type': spinType,
          'reward_value': rewardValue,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
    } catch (e, stackTrace) {
      logger.error(
        'Failed to record spin',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
