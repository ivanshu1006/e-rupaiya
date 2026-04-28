import 'dart:io';

import 'package:dio/dio.dart';

import '../../../constants/api_constants.dart';
import '../../../services/dio_service.dart';
import '../../../services/logger_service.dart';

class SupportTicketRepository {
  SupportTicketRepository({Dio? dio}) : _dio = dio ?? DioService.instance.client;

  final Dio _dio;

  Future<bool> createTicket({
    required String transactionId,
    required String service,
    required String issueType,
    required bool isTransactionRelated,
    required String description,
    File? screenshot,
  }) async {
    try {
      final form = FormData.fromMap({
        'transaction_id': transactionId,
        'service': service,
        'issue_type': issueType,
        'is_transaction_related': isTransactionRelated ? 'Y' : 'N',
        'description': description,
        if (screenshot != null)
          'screenshot': await MultipartFile.fromFile(
            screenshot.path,
            filename: screenshot.uri.pathSegments.isNotEmpty
                ? screenshot.uri.pathSegments.last
                : 'screenshot.jpg',
          ),
      });

      final response = await _dio.post(
        ApiConstants.supportCreateTicketEndpoint,
        data: form,
      );

      final payload = response.data;
      if (payload is Map) {
        final status = payload['status'] == true || payload['success'] == true;
        return status;
      }
      return true;
    } catch (e, stackTrace) {
      logger.error(
        'Failed to create support ticket',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

