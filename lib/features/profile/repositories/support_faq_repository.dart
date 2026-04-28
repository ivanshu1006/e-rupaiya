import 'package:dio/dio.dart';

import '../../../constants/api_constants.dart';
import '../../../services/dio_service.dart';
import '../../../services/logger_service.dart';
import '../models/support_faq_item.dart';

class SupportFaqRepository {
  SupportFaqRepository({Dio? dio}) : _dio = dio ?? DioService.instance.client;

  final Dio _dio;

  Future<List<SupportFaqItem>> fetchFaqs({required String category}) async {
    try {
      final response = await _dio.get(
        ApiConstants.faqsEndpoint,
        queryParameters: {'category': category},
      );
      final payload = response.data as Map<String, dynamic>? ?? {};
      final data = payload['data'];
      if (data is List) return SupportFaqItem.fromJsonList(data);
      return const <SupportFaqItem>[];
    } catch (e, stackTrace) {
      logger.error(
        'Failed to fetch FAQs',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

