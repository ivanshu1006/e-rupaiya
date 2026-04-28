import 'package:dio/dio.dart';

import '../../../constants/api_constants.dart';
import '../../../services/dio_service.dart';
import '../../../services/logger_service.dart';
import '../models/policy_page.dart';

class PolicyPagesRepository {
  PolicyPagesRepository({Dio? dio}) : _dio = dio ?? DioService.instance.client;

  final Dio _dio;

  Future<PolicyPageData> fetchPage(String slug) async {
    try {
      final response = await _dio.get(ApiConstants.pageEndpoint(slug));
      final payload = response.data as Map<String, dynamic>? ?? {};
      final parsed = PolicyPageResponse.fromJson(payload);
      if (parsed.status != true || parsed.data == null) {
        throw Exception(parsed.message ?? 'Failed to fetch page.');
      }
      return parsed.data!;
    } catch (e, stackTrace) {
      logger.error(
        'Failed to fetch policy page: $slug',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
