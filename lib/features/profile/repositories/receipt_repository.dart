import 'package:dio/dio.dart';

import '../../../constants/api_constants.dart';
import '../../../services/dio_service.dart';
import '../../../services/logger_service.dart';

class ReceiptRepository {
  ReceiptRepository({Dio? dio}) : _dio = dio ?? DioService.instance.client;

  final Dio _dio;

  Future<String> fetchReceiptHtml({required String transactionId}) async {
    try {
      final response = await _dio.post(
        ApiConstants.shareDownloadReceiptEndpoint,
        data: {'transaction_id': transactionId},
      );
      final payload = response.data as Map<String, dynamic>? ?? {};
      final success = payload['success'] == true;
      if (!success) {
        final message =
            payload['message'] as String? ?? 'Failed to generate receipt.';
        throw Exception(message);
      }
      return payload['receipt_html']?.toString() ?? '';
    } catch (e, stackTrace) {
      logger.error(
        'Receipt generation failed: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
