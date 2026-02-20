import 'package:dio/dio.dart';

import '../../../constants/api_constants.dart';
import '../../../services/dio_service.dart';
import '../../../services/logger_service.dart';
import '../models/quick_action_model.dart';

class HomeRepository {
  HomeRepository({Dio? dio}) : _dio = dio ?? DioService.instance.client;

  final Dio _dio;

  Future<List<QuickActionCategory>> fetchQuickActions() async {
    try {
      final response = await _dio.get(ApiConstants.quickActionsEndpoint);
      final payload = response.data as Map<String, dynamic>?;
      final success = payload?['success'] == true;
      if (!success) {
        final message =
            payload?['message'] as String? ?? 'Failed to fetch quick actions';
        throw Exception(message);
      }
      final dataList = payload?['data'] as List<dynamic>? ?? [];
      return dataList
          .map((e) => QuickActionCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logger.error('Failed to fetch quick actions: $e', error: e);
      rethrow;
    }
  }
}
